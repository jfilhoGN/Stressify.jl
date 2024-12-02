import Pkg
Pkg.activate(".")
using Stressify

object = Stressify.random_json_object("./examples/data/example.json")

#execute for the one VU for one iteration
Stressify.options(
    vus = 3,           
    iterations = 10,    
    duration = nothing  
)

# Criar checks
checks = [
    Stressify.Check("Status é 200", x -> x.status == 200),
]

# Configurar requisição com checks
req = Stressify.http_get("https://httpbin.org/get"; checks=checks)
req1 = Stressify.http_post("https://httpbin.org/post"; payload="{\"nome\": \"$object['nome']\"}", headers=Dict("Content-Type" => "application/json"), checks=checks)

# Executar requisição
response = Stressify.run_test(req, req1)

