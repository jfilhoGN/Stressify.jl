using Pkg
Pkg.activate(".")  # Ative o ambiente local
using Stressify

# Configurar as opções globais
Stressify.options(
    vus = 5,
    iterations = 10,
    duration = nothing
)

# Executar requisições em sequência
results = Stressify.run_test(
    Stressify.http_get("https://httpbin.org/get"),
    Stressify.http_post("https://httpbin.org/post"; payload="{\"key\": \"value\"}", headers=Dict("Content-Type" => "application/json")),
    Stressify.http_put("https://httpbin.org/put"; payload="{\"update\": \"data\"}", headers=Dict("Content-Type" => "application/json")),
    Stressify.http_patch("https://httpbin.org/patch"; payload="{\"patch\": \"data\"}", headers=Dict("Content-Type" => "application/json")),
    Stressify.http_delete("https://httpbin.org/delete")
)

println("Resultados: ", results)