module Core

using HTTP
using Statistics
using Base.Threads

"""
    run_test(endpoint::String, method::String="GET"; payload=nothing, headers=Dict(), iterations=10)

Executa testes de performance em um endpoint.
- `endpoint`: URL do endpoint.
- `method`: Método HTTP (GET, POST, etc.).
- `payload`: Dados para requisições POST/PUT.
- `headers`: Cabeçalhos HTTP.
- `iterations`: Número de requisições.

Retorna estatísticas sobre os tempos de resposta.
"""
function run_test(endpoint::String, method::String="GET"; payload=nothing, headers=Dict(), iterations::Int=10)
    if iterations <= 0
        error("O número de iterações deve ser um inteiro positivo.")
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
                try
                    elapsed_time = @elapsed begin
                        if method == "GET"
                            HTTP.get(endpoint, headers)
                        elseif method == "POST"
                            HTTP.post(endpoint, headers; body=payload)
                        elseif method == "PUT"
                            HTTP.put(endpoint, headers; body=payload)
                        elseif method == "DELETE"
                            HTTP.delete(endpoint, headers)
                        else
                            error("Método HTTP $method não suportado.")
                        end
                    end
                    push!(local_results[t], elapsed_time)
                    println("Requisição $global_iter finalizada no thread $thread_id (Tempo: $elapsed_time segundos)")
                catch e
                    local_errors[t] += 1
                    println("Erro na requisição $global_iter no thread $thread_id: ", e)
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
        "method" => method,
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