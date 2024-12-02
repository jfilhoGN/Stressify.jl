import Pkg
Pkg.activate(".")
using Stressify

object = Stressify.random_json_object("./examples/data/example.json")
println("Linha aleatória: ", object["nome"])

#execute for the one VU for one iteration
Stressify.options(
    vus = 1,           
    iterations = 1,    
    duration = nothing  
)

results = Stressify.run_test(
    Stressify.http_post("https://httpbin.org/post"; payload="{\"nome\": \"$object['nome']\"}", headers=Dict("Content-Type" => "application/json")),
)

println("Resultados: ", results)