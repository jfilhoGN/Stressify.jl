module Core

using HTTP
using Statistics
using Base.Threads
using Printf
using ArgParse
using JSON

# Armazena as opções globais
const GLOBAL_OPTIONS = Dict{Symbol, Any}()

struct Check
	description::String
	condition::Function
end

# Registra resultados globais dos checks
const CHECK_RESULTS = Ref(Vector{String}())
const CHECK_LOCK = ReentrantLock()

"""
	send_to_influx(measurement::String, fields::Dict{String, Any}, tags::Dict{String, String}=Dict())

	Envia dados para o InfluxDB.
"""	
function send_to_influx(measurement::String, fields::Dict{String, Any}, tags::Dict{String, String}=Dict())
    if STRESSIFY_ARGS["output"] != "influxdb"
        return
    end

    influxdb_url = STRESSIFY_ARGS["influxdb-url"]
    influxdb_bucket = STRESSIFY_ARGS["influxdb-bucket"]
    influxdb_org = STRESSIFY_ARGS["influxdb-org"]
    influxdb_token = STRESSIFY_ARGS["influxdb-token"]

    if isempty(influxdb_token)
        error("Token do InfluxDB não fornecido. Use --influxdb-token para especificar um token válido.")
    end

    timestamp = Int64(round(time() * 1e9)) 

    tags_str = join(["$k=$v" for (k,v) in tags], ",")
    fields_str = join(["$k=$v" for (k,v) in fields], ",")
    line = "$measurement,$tags_str $fields_str $timestamp"

    headers = Dict(
        "Authorization" => "Token $influxdb_token",
        "Content-Type"  => "text/plain; charset=utf-8"
    )

    try
        response = HTTP.post("$influxdb_url/api/v2/write?org=$influxdb_org&bucket=$influxdb_bucket&precision=ns",
                            headers, line)
        if response.status != 204
            println("Erro ao enviar dados para o InfluxDB. Status: ", response.status)
            println("Resposta: ", String(response.body))
        end
    catch e
        println("Erro ao enviar dados para o InfluxDB: ", e)
    end
end

"""
	report_metrics(latency::Float64, error_occurred::Bool)

	Envia métricas de desempenho para o InfluxDB.
"""
function report_metrics(latency, error_occurred)
    if STRESSIFY_ARGS["output"] != "influxdb"
        return
    end

    send_to_influx("performance",
        Dict(
            "latency_ms" => latency * 1000,
            "error" => error_occurred ? 1 : 0
        ),
        Dict(
            "test" => "stressify_test"
        )
    )
end

"""
	parse_cli_args!()

	Parses the command line arguments for the stressify script.
"""
function parse_cli_args!()
    for arg in ARGS
        if occursin("--output=", arg)
            output_value = split(arg, "=")[2]
            println("🚀 Argumento capturado: output=$output_value")
            STRESSIFY_ARGS["output"] = output_value 
        end
    end
end

"""
	save_results_to_json(results, filename)

	Salva os resultados em um arquivo JSON.

	- `results`: Dicionário de resultados.
	- `filename`: Nome do arquivo JSON.
"""
function save_results_to_json(results, filename)
    try
        open(filename, "w") do f
            JSON.print(f, results, 2)
        end
        println("Arquivo JSON salvo em: ", filename)
    catch e
        println("Erro ao salvar JSON: ", e)
    end
end

"""
    parse_stressify_args() 

Parses the command line arguments for the stressify script.
"""
function parse_stressify_args()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "--output"
            help = "Formato de saída (grafana, json, influxdb, default)"
            arg_type = String
            default = "default"
        "--influxdb-url"
            help = "URL do InfluxDB (ex: http://localhost:8086)"
            arg_type = String
            default = "http://localhost:8086"
        "--influxdb-bucket"
            help = "Nome do bucket no InfluxDB"
            arg_type = String
            default = "stressify"
        "--influxdb-org"
            help = "Organização no InfluxDB"
            arg_type = String
            default = "Stressify"
    end
    args = parse_args(s; as_symbols=false)
    
    args["influxdb-token"] = get(ENV, "INFLUXDB_TOKEN", "")
    return args
end

const STRESSIFY_ARGS = parse_stressify_args()

"""
	options(; vus::Int=1, format::String="default", ramp_duration::Union{Float64, Nothing}=nothing,
			  max_vus::Union{Int, Nothing}=nothing, iterations::Union{Int, Nothing}=nothing, 
			  duration::Union{Float64, Nothing}=nothing)

Configura opções globais para os testes de performance.
"""
function options(; vus::Int = 1, format::String = "default", max_vus::Union{Int, Nothing} = nothing,
    ramp_duration::Union{Float64, Nothing} = nothing, iterations::Union{Int, Nothing} = nothing,
    duration::Union{Float64, Nothing} = nothing, noDebug::Bool = false)
    GLOBAL_OPTIONS[:vus] = vus
    GLOBAL_OPTIONS[:format] = format
    GLOBAL_OPTIONS[:max_vus] = max_vus
    GLOBAL_OPTIONS[:ramp_duration] = ramp_duration
    GLOBAL_OPTIONS[:iterations] = iterations
    GLOBAL_OPTIONS[:duration] = duration
    GLOBAL_OPTIONS[:noDebug] = noDebug

    if format == "vus-ramping" && (max_vus === nothing || duration === nothing || ramp_duration === nothing)
        error("Para o formato 'vus-ramping', você deve especificar 'max_vus', 'ramp_duration' e 'duration'.")
    end
end

"""
	debug_log(msg::String)

Loga mensagens de depuração apenas se a opção `noDebug` estiver desativada.
"""
function debug_log(msg::String)
	if !get(GLOBAL_OPTIONS, :noDebug, false)
		println(msg)
	end
end

"""
	check(response, method::String, checks::Vector{Check})

Aplica uma lista de checks a uma resposta HTTP, incluindo o método HTTP.

- `response`: Objeto de resposta HTTP.
- `method`: Método HTTP usado na requisição (GET, POST, etc.).
- `checks`: Vetor de objetos `Check` com condições a serem avaliadas.
"""
function check(response, method::String, checks::Vector{Check})
	for chk in checks
		try
			if chk.condition(response)
				push!(CHECK_RESULTS[], "✔️ $(method) - $(chk.description) - Success")
				debug_log("✔️ $(method) - $(chk.description) - Success")
			else
				push!(CHECK_RESULTS[], "❌ $(method) - $(chk.description) - Failed")
				debug_log("❌ $(method) - $(chk.description) - Failed")
			end
		catch e
			push!(CHECK_RESULTS[], "⚠️ $(method) - $(chk.description) - Error: $e")
			debug_log("⚠️ $(method) - $(chk.description) - Error: $e")
		end
	end
end

# Funções de criação de requisições HTTP
function http_get(endpoint::String; checks = Vector{Check}(), rate_limiter = nothing)
	return (method = HTTP.get, url = endpoint, payload = nothing, headers = Dict(), checks = checks, rate_limiter = rate_limiter)
end

function http_post(endpoint::String; payload = nothing, headers = Dict(), checks = Vector{Check}(), rate_limiter = nothing)
	return (method = HTTP.post, url = endpoint, payload = payload, headers = headers, checks = checks, rate_limiter = rate_limiter)
end

function http_put(endpoint::String; payload = nothing, headers = Dict(), checks = Vector{Check}(), rate_limiter = nothing)
	return (method = HTTP.put, url = endpoint, payload = payload, headers = headers, checks = checks, rate_limiter = rate_limiter)
end

function http_patch(endpoint::String; payload = nothing, headers = Dict(), checks = Vector{Check}(), rate_limiter = nothing)
	return (method = HTTP.patch, url = endpoint, payload = payload, headers = headers, checks = checks, rate_limiter = rate_limiter)
end

function http_delete(endpoint::String; headers = Dict(), checks = Vector{Check}(), rate_limiter = nothing)
	return (method = HTTP.delete, url = endpoint, payload = nothing, headers = headers, checks = checks, rate_limiter = rate_limiter)
end

"""
	perform_request(request::NamedTuple)

Executa uma requisição HTTP com base em um `NamedTuple` que define o método, URL, payload e headers.

- `request`: NamedTuple contendo `method`, `url`, `payload`, `headers` e `checks`.
"""
function perform_request(request::NamedTuple)
	method, url, payload, headers, checks, rate_limiter =
		request.method, request.url, request.payload, request.headers, request.checks, request.rate_limiter

	# Aplica o rate limiter específico da requisição, se existir
	if rate_limiter !== nothing
		control_throughput(rate_limiter)
	end

	response = if method in (HTTP.get, HTTP.delete)
		method(url, headers)
	elseif method in (HTTP.post, HTTP.put, HTTP.patch)
		method(url, headers; body = payload)
	else
		error("Método HTTP não suportado. Use: GET, POST, PUT, DELETE ou PATCH.")
	end

	# Processar checks, se existirem
	if !isempty(checks)
		check(response, string(method), checks)
	end

	return response
end

"""
	compute_statistics(all_times::Vector{Float64}, total_errors::Atomic{Int}, total_requests::Int, total_duration::Float64)

Calcula e retorna as estatísticas de desempenho a partir do vetor de tempos de resposta.

- `all_times`: Vetor contendo todos os tempos de resposta.
- `total_errors`: Contador de erros no teste.
- `total_requests`: Número total de requisições realizadas.
- `total_duration`: Duração total do teste em segundos.

Retorna um `Dict` com as estatísticas de desempenho, incluindo P90, P95, P99, SuccessRate, ErrorRate, RPS e TPS.
"""
function compute_statistics(
	all_times::Vector{Float64},
	total_errors::Union{Int, Base.Threads.Atomic{Int}},
	total_requests::Int,
	total_duration::Float64,
	vus::Int,
)
	p90 = isempty(all_times) ? NaN : percentile(all_times, 90)
	p95 = isempty(all_times) ? NaN : percentile(all_times, 95)
	p99 = isempty(all_times) ? NaN : percentile(all_times, 99)
	success_rate = total_requests == 0 ? NaN : (1 - total_errors[] / total_requests) * 100
	error_rate = total_requests == 0 ? NaN : (total_errors[] / total_requests) * 100

	rps = total_duration == 0.0 ? NaN : total_requests / total_duration
	tps = total_duration == 0.0 ? NaN : (total_requests - total_errors[]) / total_duration

	return Dict(
		"iterations" => length(all_times),
		"errors" => total_errors[],
		"success_rate" => success_rate,  # Taxa de sucesso em porcentagem
		"error_rate" => error_rate,      # Taxa de erro em porcentagem
		"min_time" => isempty(all_times) ? NaN : minimum(all_times),
		"max_time" => isempty(all_times) ? NaN : maximum(all_times),
		"mean_time" => isempty(all_times) ? NaN : mean(all_times),
		"median_time" => isempty(all_times) ? NaN : median(all_times),
		"std_time" => isempty(all_times) ? NaN : std(all_times),
		"p90_time" => p90,
		"p95_time" => p95,
		"p99_time" => p99,
		"vus" => vus,
		"rps" => rps,  # Requests Per Second
		"tps" => tps,  # Transactions Per Second
		"all_times" => all_times,  # Adicionando a chave "all_times"
	)
end

"""
	percentile(data::Vector{Float64}, p::Real)

Calcula o valor do percentil `p` em um vetor de dados.

- `data`: Vetor de dados.
- `p`: Percentil (entre 0 e 100).

Retorna o valor do percentil ou `NaN` se o vetor estiver vazio.
"""
function percentile(data::Vector{Float64}, p::Real)
	if isempty(data)
		return NaN
	end
	sorted_data = sort(data)
	rank = ceil(Int, p / 100 * length(sorted_data))
	return sorted_data[min(rank, length(sorted_data))]
end

"""
	format_results(results::Dict{String, <:Any})

Formata o dicionário de resultados de métricas de desempenho em um resumo legível.

- `results`: Dicionário retornado pela função `compute_statistics`.

Retorna uma string formatada com as principais métricas.
"""
function format_results(results::Dict{String, <:Any})
    return """
    ================== Stressify ==================
        VUs                    : $(lpad(results["vus"], 10))
        Iterações Totais       : $(lpad(results["iterations"], 10))
        Taxa de Sucesso (%)    : $(lpad(round(results["success_rate"], digits=2), 10))
        Taxa de Erros (%)      : $(lpad(round(results["error_rate"], digits=2), 10))
        Requisições por Segundo: $(lpad(round(results["rps"], digits=2), 10))
        Transações por Segundo : $(lpad(round(results["tps"], digits=2), 10))
        Número de Erros        : $(lpad(results["errors"], 10))

    ---------- Métricas de Tempo (s) ----------
        Tempo Mínimo           : $(lpad(round(results["min_time"], digits=4), 10))
        Tempo Máximo           : $(lpad(round(results["max_time"], digits=4), 10))
        Tempo Médio            : $(lpad(round(results["mean_time"], digits=4), 10))
        Mediana                : $(lpad(round(results["median_time"], digits=4), 10))
        P90                    : $(lpad(round(results["p90_time"], digits=4), 10))
        P95                    : $(lpad(round(results["p95_time"], digits=4), 10))
        P99                    : $(lpad(round(results["p99_time"], digits=4), 10))
        Desvio Padrão          : $(lpad(round(results["std_time"], digits=4), 10))

    ---------- Detalhamento de Tempos ----------
        Todos os Tempos (s)    : $(join(round.(results["all_times"], digits=4), ", "))
    ==========================================================
    """
end

"""
	run_test(requests::Vararg{NamedTuple})

Executa os testes de performance com suporte ao formato `vus-ramping`, incluindo `ramp_duration`.
"""
function run_test(requests::Vararg{NamedTuple}; rate_limiter = nothing)
    parse_cli_args!()
	vus = get(GLOBAL_OPTIONS, :vus, 1)
	format = get(GLOBAL_OPTIONS, :format, "default")
	max_vus = get(GLOBAL_OPTIONS, :max_vus, nothing)
	ramp_duration = get(GLOBAL_OPTIONS, :ramp_duration, 0.0)
	iterations = get(GLOBAL_OPTIONS, :iterations, nothing)
	duration = get(GLOBAL_OPTIONS, :duration, nothing)

    output_mode = STRESSIFY_ARGS["output"]

	if iterations === nothing && duration === nothing
		error("Você deve especificar 'iterations' ou 'duration' nas opções globais.")
	end

	start_time = time()
	total_errors = Atomic{Int}(0)
	active_vus = Atomic{Int}(vus)
	tasks = Task[]

	# Inicializa o vetor de resultados com o número máximo possível de VUs
	local_results = [Float64[] for _ in 1:(max_vus === nothing ? vus : max_vus)]

	if format == "vus-ramping" && max_vus !== nothing && ramp_duration > 0.0 && duration !== nothing
		# Calcula quantos VUs precisamos adicionar
		vus_to_add = max_vus - vus

		# Calcula o intervalo entre adições de VUs para garantir distribuição uniforme
		if vus_to_add > 0
			interval = ramp_duration / vus_to_add
		else
			interval = ramp_duration
		end

		# Task para gerenciar o ramp-up
		ramp_task = @async begin
			current_vus = vus
			ramp_start = time()

			# Inicia as tasks para os VUs iniciais
			for t in 1:vus
				push!(tasks, spawn_vu_task(
					t,
					start_time,
					duration + ramp_duration,
					iterations,
					requests,
					local_results,
					total_errors,
					rate_limiter = rate_limiter,  # Passa o rate_limiter como argumento nomeado
				))
			end

			# Adiciona novos VUs gradualmente durante o ramp_duration
			for new_vu in (vus+1):max_vus
				sleep(interval)
				current_vus = new_vu
				atomic_add!(active_vus, 1)
				debug_log("Ramp-up: Incrementando VUs para $current_vus")

				push!(tasks, spawn_vu_task(
					new_vu,
					start_time,
					duration + ramp_duration - (time() - start_time),  # Ajusta duração restante
					iterations,
					requests,
					local_results,
					total_errors,
				))
			end

			debug_log("Ramp-up concluído. Total de VUs ativos: $(active_vus[])")
		end

		# Aguarda o término do ramp-up
		wait(ramp_task)

		# Aguarda o término da duração total
		remaining_time = duration + ramp_duration - (time() - start_time)
		if remaining_time > 0
			sleep(remaining_time)
		end
	else
		# Execução padrão sem ramping
		for t in 1:vus
			push!(tasks, spawn_vu_task(
				t,
				start_time,
				duration,
				iterations,
				requests,
				local_results,
				total_errors,
			))
		end

		if duration !== nothing
			sleep(duration)
		end
	end

	# Aguarda todas as tasks terminarem
	foreach(wait, tasks)

	# Processa os resultados
	all_times = vcat(local_results...)
	total_requests = length(all_times) + total_errors[]
	total_duration = time() - start_time

	results = compute_statistics(all_times, total_errors, total_requests, total_duration, active_vus[])

    if output_mode == "influxdb"
        # Remove o campo `all_times` do dicionário de resultados
        filtered_results = filter(pair -> pair.first != "all_times", results)

        # Converte os valores do dicionário para Any
        influx_fields = Dict{String, Any}()
        for (k, v) in filtered_results
            influx_fields[k] = v
        end

        send_to_influx("stressify_summary", influx_fields, Dict(
            "test" => "stressify_test"
        ))
    end

    if output_mode == "grafana"
        save_results_to_json(results, "stressify_grafana.json")
        println("Resultados salvos em 'stressify_grafana.json'")
    else
        println(format_results(results))
	    println("\n---------- Resultados dos Checks ----------")
	    println(join(CHECK_RESULTS[], "\n"))
    end
	
	return results
end

mutable struct RateLimiter
	rps::Float64
	last_request_time::Float64
end

function RateLimiter(rps::Float64)
	return RateLimiter(rps, 0.0)
end

function control_throughput(rate_limiter::RateLimiter)
	min_interval = 1.0 / rate_limiter.rps
	now = time()

	if rate_limiter.last_request_time == 0.0
		rate_limiter.last_request_time = now
		return
	end
	elapsed = now - rate_limiter.last_request_time

	if elapsed < min_interval
		sleep(min_interval - elapsed)
	end

	rate_limiter.last_request_time = time()
end

function spawn_vu_task(vu_id, start_time, duration, iterations, requests, local_results, total_errors; rate_limiter=nothing)
    return Threads.@spawn begin
        debug_log("Thread $vu_id inicializada.")
        request_idx = 1
        iteration_count = 0
        
        while true
            current_time = time() - start_time
            
            if iterations !== nothing && iteration_count >= iterations
                break
            end

            if duration !== nothing && current_time >= duration
                break
            end
            
            try
                request = requests[request_idx]
                if request.rate_limiter !== nothing
                    control_throughput(request.rate_limiter)
                elseif rate_limiter !== nothing
                    control_throughput(rate_limiter)
                end
                
                elapsed_time = @elapsed begin
                    perform_request(request)
                end
                push!(local_results[vu_id], elapsed_time)
                iteration_count += 1

                method_name = string(request.method) |> x -> split(x, ".")[end]
                debug_log("Requisição (Método: $method_name) finalizada no thread $vu_id (Tempo: $elapsed_time segundos)")
            catch e
                atomic_add!(total_errors, 1)
                println("Erro na requisição no thread $vu_id: ", e)
            end

            request_idx = (request_idx % length(requests)) + 1
        end
        
        debug_log("Thread $vu_id finalizada após $iteration_count iterações.")
    end
end

export options, http_get, http_post, http_put, http_patch, http_delete, run_test, Check, format_results, compute_statistics, RateLimiter, control_throughput, perform_request, percentile, check, CHECK_RESULTS, STRESSIFY_ARGS, parse_stressify_args

end
