using Pkg
Pkg.activate(".")  # Ative o ambiente local
using JuliaPerformanceTest

# Configurar as opções globais
JuliaPerformanceTest.options(
    vus = 5,
    iterations = 10,
    duration = nothing
)

# Executar requisições em sequência
results = JuliaPerformanceTest.run_test(
    JuliaPerformanceTest.http_get("https://httpbin.org/get"),
    JuliaPerformanceTest.http_post("https://httpbin.org/post"; payload="{\"key\": \"value\"}", headers=Dict("Content-Type" => "application/json")),
    JuliaPerformanceTest.http_put("https://httpbin.org/put"; payload="{\"update\": \"data\"}", headers=Dict("Content-Type" => "application/json")),
    JuliaPerformanceTest.http_patch("https://httpbin.org/patch"; payload="{\"patch\": \"data\"}", headers=Dict("Content-Type" => "application/json")),
    JuliaPerformanceTest.http_delete("https://httpbin.org/delete")
)

println("Resultados: ", results)