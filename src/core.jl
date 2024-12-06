module Core

using HTTP
using Statistics
using Base.Threads
using Printf

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
	options(; vus::Int=1, format::String="default", ramp_duration::Union{Float64, Nothing}=nothing,
			  max_vus::Union{Int, Nothing}=nothing, iterations::Union{Int, Nothing}=nothing, 
			  duration::Union{Float64, Nothing}=nothing)

Configura opções globais para os testes de performance.
"""
function options(; vus::Int = 1, format::String = "default", max_vus::Union{Int, Nothing} = nothing,
	ramp_duration::Union{Float64, Nothing} = nothing, iterations::Union{Int, Nothing} = nothing,
	duration::Union{Float64, Nothing} = nothing)
	GLOBAL_OPTIONS[:vus] = vus
	GLOBAL_OPTIONS[:format] = format
	GLOBAL_OPTIONS[:max_vus] = max_vus
	GLOBAL_OPTIONS[:ramp_duration] = ramp_duration
	GLOBAL_OPTIONS[:iterations] = iterations
	GLOBAL_OPTIONS[:duration] = duration

	if format == "vus-ramping" && (max_vus === nothing || duration === nothing || ramp_duration === nothing)
		error("Para o formato 'vus-ramping', você deve especificar 'max_vus', 'ramp_duration' e 'duration'.")
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
				println("✔️ $(method) - $(chk.description) - Success")
			else
				push!(CHECK_RESULTS[], "❌ $(method) - $(chk.description) - Failed")
				println("❌ $(method) - $(chk.description) - Failed")
			end
		catch e
			push!(CHECK_RESULTS[], "⚠️ $(method) - $(chk.description) - Error: $e")
			println("⚠️ $(method) - $(chk.description) - Error: $e")
		end
	end
end

# Funções de criação de requisições HTTP
function http_get(endpoint::String; checks = Vector{Check}())
	return (method = HTTP.get, url = endpoint, payload = nothing, headers = Dict(), checks = checks)
end

function http_post(endpoint::String; payload = nothing, headers = Dict(), checks = Vector{Check}())
	return (method = HTTP.post, url = endpoint, payload = payload, headers = headers, checks = checks)
end

function http_put(endpoint::String; payload = nothing, headers = Dict(), checks = Vector{Check}())
	return (method = HTTP.put, url = endpoint, payload = payload, headers = headers, checks = checks)
end

function http_patch(endpoint::String; payload = nothing, headers = Dict(), checks = Vector{Check}())
	return (method = HTTP.patch, url = endpoint, payload = payload, headers = headers, checks = checks)
end

function http_delete(endpoint::String; headers = Dict(), checks = Vector{Check}())
	return (method = HTTP.delete, url = endpoint, payload = nothing, headers = headers, checks = checks)
end

"""
	perform_request(request::NamedTuple)

Executa uma requisição HTTP com base em um `NamedTuple` que define o método, URL, payload e headers.

- `request`: NamedTuple contendo `method`, `url`, `payload`, `headers` e `checks`.
"""
function perform_request(request::NamedTuple)
	method, url, payload, headers, checks =
		request.method, request.url, request.payload, request.headers, request.checks

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
function run_test(requests::Vararg{NamedTuple})
    vus = get(GLOBAL_OPTIONS, :vus, 1)
    format = get(GLOBAL_OPTIONS, :format, "default")
    max_vus = get(GLOBAL_OPTIONS, :max_vus, nothing)
    ramp_duration = get(GLOBAL_OPTIONS, :ramp_duration, 0.0)
    iterations = get(GLOBAL_OPTIONS, :iterations, nothing)
    duration = get(GLOBAL_OPTIONS, :duration, nothing)

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
                    duration + ramp_duration,  # Duração total inclui ramping
                    iterations,
                    requests,
                    local_results,
                    total_errors
                ))
            end
            
            # Adiciona novos VUs gradualmente durante o ramp_duration
            for new_vu in (vus + 1):max_vus
                sleep(interval)
                current_vus = new_vu
                atomic_add!(active_vus, 1)
                println("Ramp-up: Incrementando VUs para $current_vus")

                push!(tasks, spawn_vu_task(
                    new_vu,
                    start_time,
                    duration + ramp_duration - (time() - start_time),  # Ajusta duração restante
                    iterations,
                    requests,
                    local_results,
                    total_errors
                ))
            end
            
            println("Ramp-up concluído. Total de VUs ativos: $(active_vus[])")
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
                total_errors
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
    println(format_results(results))
    println("\n---------- Resultados dos Checks ----------")
    println(join(CHECK_RESULTS[], "\n"))
    
    return results
end

function spawn_vu_task(vu_id, start_time, duration, iterations, requests, local_results, total_errors)
    return Threads.@spawn begin
        println("Thread $vu_id inicializada.")
        request_idx = 1
        iteration_count = 0
        
        while true
            current_time = time() - start_time
            
            # Verifica condições de parada
            if iterations !== nothing && iteration_count >= iterations
                break
            end
            
            if duration !== nothing && current_time >= duration
                break
            end
            
            try
                elapsed_time = @elapsed begin
                    perform_request(requests[request_idx])
                end
                push!(local_results[vu_id], elapsed_time)
                iteration_count += 1

                method_name = string(requests[request_idx].method) |> x -> split(x, ".")[end]
                println("Requisição (Método: $method_name) finalizada no thread $vu_id (Tempo: $elapsed_time segundos)")
            catch e
                atomic_add!(total_errors, 1)
                println("Erro na requisição no thread $vu_id: ", e)
            end

            request_idx = (request_idx % length(requests)) + 1
        end
        
        println("Thread $vu_id finalizada após $iteration_count iterações.")
    end
end

export options, http_get, http_post, http_put, http_patch, http_delete, run_test, Check, format_results, compute_statistics

end
