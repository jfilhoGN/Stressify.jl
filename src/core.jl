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
    run_test(
        endpoint::String, 
        methods::Union{Function, Vector{Function}}=HTTP.get; 
        payload=nothing, 
        headers=Dict(), 
        iterations::Union{Int, Nothing}=nothing, 
        duration::Union{Float64, Nothing}=nothing
    )

Executa testes de performance em um endpoint utilizando um ou mais métodos HTTP especificados. 

### Parâmetros
- `endpoint::String`: URL do endpoint que será testado.
- `methods::Union{Function, Vector{Function}}`: Um método HTTP (e.g., `HTTP.get`) ou uma lista de métodos (e.g., `[HTTP.get, HTTP.post]`) a serem alternados durante o teste.
- `payload=nothing`: Dados para requisições que suportam corpo (e.g., POST, PUT, PATCH). Ignorado para métodos como GET e DELETE.
- `headers=Dict()`: Cabeçalhos HTTP a serem enviados com cada requisição.
- `iterations::Union{Int, Nothing}=nothing`: Número total de requisições a serem realizadas. O teste será encerrado após atingir esse número, se especificado.
- `duration::Union{Float64, Nothing}=nothing`: Tempo máximo (em segundos) para a execução do teste. O teste será encerrado após atingir esse tempo, se especificado.

Retorna estatísticas sobre os tempos de resposta.
"""
function run_test(endpoint::String, methods::Union{Function, Vector{Function}}=HTTP.get; 
                  payload=nothing, headers=Dict(), 
                  iterations::Union{Int, Nothing}=nothing, 
                  duration::Union{Float64, Nothing}=nothing)

    if iterations === nothing && duration === nothing
        error("Você deve especificar 'iterations' ou 'duration'.")
    end

    num_threads = nthreads()
    local_results = [Float64[] for _ in 1:num_threads]
    total_errors = Atomic{Int}(0)

    start_time = time()
    stop_test = () -> duration !== nothing && (time() - start_time) >= duration

    tasks = []
    for t in 1:num_threads
        push!(tasks, Threads.@spawn begin
            thread_id = Threads.threadid()
            println("Thread $thread_id inicializada.")
            method_idx = 1

            i = 0
            while (iterations === nothing || i < iterations) && !stop_test()
                global_iter = iterations === nothing ? i + 1 : (t - 1) * div(iterations, num_threads) + i + 1
                current_method = methods[method_idx]

                try
                    elapsed_time = @elapsed begin
                        perform_request(endpoint, current_method; payload=payload, headers=headers)
                    end
                    push!(local_results[t], elapsed_time)
                    println("Requisição $global_iter finalizada no thread $thread_id (Tempo: $elapsed_time segundos)")
                catch e
                    atomic_add!(total_errors, 1)
                    println("Erro na requisição $global_iter no thread $thread_id: ", e)
                end

                method_idx = (method_idx % length(methods)) + 1
                i += 1
            end
        end)
    end

    foreach(wait, tasks)

    all_times = vcat(local_results...)
    return Dict(
        "endpoint" => endpoint,
        "methods" => methods,
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

export run_test

end