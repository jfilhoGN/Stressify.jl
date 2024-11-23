module Core

using HTTP
using Statistics

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

    times = Float64[]  # Para armazenar tempos de resposta
    errors = 0  # Contador de erros

    for i in 1:iterations
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
            push!(times, elapsed_time)
        catch e
            errors += 1
            println("Erro na requisição $i: ", e)
        end
    end

    return Dict(
        "endpoint" => endpoint,
        "method" => method,
        "iterations" => iterations,
        "min_time" => isempty(times) ? NaN : minimum(times),
        "max_time" => isempty(times) ? NaN : maximum(times),
        "mean_time" => isempty(times) ? NaN : mean(times),
        "median_time" => isempty(times) ? NaN : median(times),
        "std_time" => isempty(times) ? NaN : std(times),
        "all_times" => times,
        "errors" => errors
    )
end

export run_test

end