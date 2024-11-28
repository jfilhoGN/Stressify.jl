module Core

using HTTP
using Statistics
using Base.Threads

# Armazena as opções globais
const GLOBAL_OPTIONS = Dict{Symbol, Any}()

"""
    options(; vus::Int=1, iterations::Union{Int, Nothing}=nothing, duration::Union{Float64, Nothing}=nothing)

Configura opções globais para os testes de performance.

- `vus`: Número de usuários virtuais (threads).
- `iterations`: Número total de iterações a serem realizadas.
- `duration`: Tempo máximo (em segundos) para a execução dos testes.
"""
function options(; vus::Int=1, iterations::Union{Int, Nothing}=nothing, duration::Union{Float64, Nothing}=nothing)
    GLOBAL_OPTIONS[:vus] = vus
    GLOBAL_OPTIONS[:iterations] = iterations
    GLOBAL_OPTIONS[:duration] = duration
end

"""
    http_get(endpoint::String)

Cria uma requisição GET para o endpoint fornecido.

- `endpoint`: URL do endpoint.
"""
function http_get(endpoint::String)
    return (method=HTTP.get, url=endpoint, payload=nothing, headers=Dict())
end

"""
    http_post(endpoint::String; payload=nothing, headers=Dict())

Cria uma requisição POST para o endpoint fornecido.

- `endpoint`: URL do endpoint.
- `payload`: Dados do corpo da requisição.
- `headers`: Cabeçalhos HTTP.
"""
function http_post(endpoint::String; payload=nothing, headers=Dict())
    return (method=HTTP.post, url=endpoint, payload=payload, headers=headers)
end

"""
    http_put(endpoint::String; payload=nothing, headers=Dict())

Cria uma requisição PUT para o endpoint fornecido.

- `endpoint`: URL do endpoint.
- `payload`: Dados do corpo da requisição.
- `headers`: Cabeçalhos HTTP.
"""
function http_put(endpoint::String; payload=nothing, headers=Dict())
    return (method=HTTP.put, url=endpoint, payload=payload, headers=headers)
end

"""
    http_patch(endpoint::String; payload=nothing, headers=Dict())

Cria uma requisição PATCH para o endpoint fornecido.

- `endpoint`: URL do endpoint.
- `payload`: Dados do corpo da requisição.
- `headers`: Cabeçalhos HTTP.
"""
function http_patch(endpoint::String; payload=nothing, headers=Dict())
    return (method=HTTP.patch, url=endpoint, payload=payload, headers=headers)
end

"""
    http_delete(endpoint::String; headers=Dict())

Cria uma requisição DELETE para o endpoint fornecido.

- `endpoint`: URL do endpoint.
- `headers`: Cabeçalhos HTTP.
"""
function http_delete(endpoint::String; headers=Dict())
    return (method=HTTP.delete, url=endpoint, payload=nothing, headers=headers)
end

"""
    perform_request(request::NamedTuple)

Executa uma requisição HTTP com base em um `NamedTuple` que define o método, URL, payload e headers.

- `request`: NamedTuple contendo `method`, `url`, `payload` e `headers`.
"""
function perform_request(request::NamedTuple)
    method, url, payload, headers = request.method, request.url, request.payload, request.headers
    if method in (HTTP.get, HTTP.delete)
        return method(url, headers)
    elseif method in (HTTP.post, HTTP.put, HTTP.patch)
        return method(url, headers; body=payload)
    else
        error("Método HTTP não suportado. Use: GET, POST, PUT, DELETE ou PATCH.")
    end
end

"""
    compute_statistics(all_times::Vector{Float64}, total_errors::Atomic{Int})

Calcula e retorna as estatísticas de desempenho a partir do vetor de tempos de resposta.

- `all_times`: Vetor contendo todos os tempos de resposta.
- `total_errors`: Contador de erros no teste.

Retorna um `Dict` com as estatísticas de desempenho.
"""
function compute_statistics(all_times::Vector{Float64}, total_errors::Atomic{Int})
    return Dict(
        "iterations" => length(all_times),
        "errors" => total_errors[],
        "min_time" => isempty(all_times) ? NaN : minimum(all_times),
        "max_time" => isempty(all_times) ? NaN : maximum(all_times),
        "mean_time" => isempty(all_times) ? NaN : mean(all_times),
        "median_time" => isempty(all_times) ? NaN : median(all_times),
        "std_time" => isempty(all_times) ? NaN : std(all_times),
        "all_times" => all_times
    )
end

"""
    run_test(requests::Vararg{NamedTuple})

Executa testes de performance com base nas requisições fornecidas.

- `requests`: Um ou mais objetos retornados por `http_get`, `http_post`, `http_put`, `http_patch` ou `http_delete`.
"""
function run_test(requests::Vararg{NamedTuple})
    vus = get(GLOBAL_OPTIONS, :vus, 1)
    iterations = get(GLOBAL_OPTIONS, :iterations, nothing)
    duration = get(GLOBAL_OPTIONS, :duration, nothing)

    if iterations === nothing && duration === nothing
        error("Você deve especificar 'iterations' ou 'duration' nas opções globais.")
    end

    num_threads = vus
    local_results = [Float64[] for _ in 1:num_threads]
    total_errors = Atomic{Int}(0)

    start_time = time()
    stop_test = () -> duration !== nothing && (time() - start_time) >= duration

    tasks = []
    for t in 1:num_threads
        thread_id = t  # Identificador de thread controlado manualmente
        push!(tasks, Threads.@spawn begin
            println("Thread $thread_id inicializada.")
            request_idx = 1

            i = 0
            while (iterations === nothing || i < iterations) && !stop_test()
                global_iter = iterations === nothing ? i + 1 : i + 1
                current_request = requests[request_idx]

                try
                    elapsed_time = @elapsed begin
                        perform_request(current_request)
                    end
                    push!(local_results[thread_id], elapsed_time)
                    
                    # Captura o método HTTP como string
                    method_name = string(current_request.method) |> x -> split(x, ".")[end]
                    println("Requisição $global_iter (Método: $method_name) finalizada no thread $thread_id (Tempo: $elapsed_time segundos)")
                catch e
                    atomic_add!(total_errors, 1)
                    println("Erro na requisição $global_iter no thread $thread_id: ", e)
                end

                request_idx = (request_idx % length(requests)) + 1
                i += 1
            end
        end)
    end

    foreach(wait, tasks)

    all_times = vcat(local_results...)
    return compute_statistics(all_times, total_errors)
end

export options, http_get, http_post, http_put, http_patch, http_delete, run_test, compute_statistics

end
