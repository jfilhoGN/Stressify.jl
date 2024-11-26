module Core

using HTTP
using Statistics
using Base.Threads

"""
    perform_request(endpoint::String, method::Function; payload=nothing, headers=Dict())

Executa uma requisição HTTP usando a função de método fornecida (e.g., HTTP.get, HTTP.post).
- `endpoint`: URL do endpoint.
- `method`: Função do método HTTP (e.g., HTTP.get, HTTP.post).
- `payload`: Dados para requisições que suportam corpo (e.g., POST, PUT, PATCH).
- `headers`: Cabeçalhos HTTP.

Retorna a resposta HTTP ou lança um erro em caso de falha.
"""
function perform_request(endpoint::String, method::Function; payload=nothing, headers=Dict())
    if method in (HTTP.get, HTTP.delete)
        return method(endpoint, headers)
    elseif method in (HTTP.post, HTTP.put, HTTP.patch)
        return method(endpoint, headers; body=payload)
    else
        error("Método HTTP não suportado. Use: GET, POST, PUT, DELETE ou PATCH.")
    end
end

"""
    run_test(endpoint::String, method::Function=HTTP.get; payload=nothing, headers=Dict(), iterations::Int=10)

Executa testes de performance em um endpoint utilizando o método HTTP especificado.
- `endpoint`: URL do endpoint.
- `method`: Função do método HTTP (e.g., HTTP.get, HTTP.post).
- `payload`: Dados para requisições que suportam corpo (e.g., POST, PUT, PATCH).
- `headers`: Cabeçalhos HTTP.
- `iterations`: Número de requisições a serem realizadas.

Retorna estatísticas sobre os tempos de resposta.
"""
function run_test(
    endpoint::String, 
    methods::Union{Function, Vector{Function}}; 
    payload=nothing, 
    headers=Dict(), 
    iterations::Int=10
)
    if iterations <= 0
        error("O número de iterações deve ser um inteiro positivo.")
    end

    # Normalizar `methods` para um vetor
    methods = methods isa Function ? [methods] : methods

    # Validação dos métodos
    for method in methods
        if method ∉ [HTTP.get, HTTP.post, HTTP.put, HTTP.delete, HTTP.patch]
            error("Método HTTP não suportado. Use: GET, POST, PUT, DELETE ou PATCH.")
        end
    end

    num_threads = min(nthreads(), iterations)
    iterations_per_thread = floor(Int, iterations / num_threads)
    remaining_iterations = iterations % num_threads

    local_results = [Float64[] for _ in 1:num_threads]
    local_errors = zeros(Int, num_threads)

    tasks = []
    for t in 1:num_threads
        push!(tasks, Threads.@spawn begin
            thread_id = Threads.threadid()
            println("Thread $thread_id inicializada.")

            total_iterations = iterations_per_thread + (t <= remaining_iterations ? 1 : 0)

            for i in 1:total_iterations
                global_iter = (t - 1) * iterations_per_thread + i
                method = methods[mod(global_iter - 1, length(methods)) + 1]  # Seleciona o método com base na iteração
                try
                    elapsed_time = @elapsed perform_request(endpoint, method; payload=payload, headers=headers)
                    push!(local_results[t], elapsed_time)
                    println("Requisição $global_iter finalizada no thread $thread_id com método $(string(method)) (Tempo: $elapsed_time segundos)")
                catch e
                    local_errors[t] += 1
                    println("Erro na requisição $global_iter no thread $thread_id com método $(string(method)): ", e)
                end
            end
        end)
    end

    foreach(wait, tasks)

    all_times = vcat(local_results...)
    total_errors = sum(local_errors)

    println("Depuração - Tempos por thread:")
    for i in 1:num_threads
        println("Thread $i: $(local_results[i])")
    end

    return Dict(
        "endpoint" => endpoint,
        "methods" => [string(m) for m in methods],
        "iterations" => iterations,
        "min_time" => isempty(all_times) ? NaN : minimum(all_times),
        "max_time" => isempty(all_times) ? NaN : maximum(all_times),
        "mean_time" => isempty(all_times) ? NaN : mean(all_times),
        "median_time" => isempty(all_times) ? NaN : median(all_times),
        "std_time" => isempty(all_times) ? NaN : std(all_times),
        "all_times" => all_times,
        "errors" => total_errors
    )
end

export run_test

end