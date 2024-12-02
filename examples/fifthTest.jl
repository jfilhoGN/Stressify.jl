import Pkg
Pkg.activate(".")
using Stressify

row = Stressify.random_csv_row("./examples/data/example.csv")
println("Linha aleatória: ", row[:nome])

#execute for the one VU for one iteration
Stressify.options(
    vus = 1,           
    iterations = 1,    
    duration = nothing  
)

results = Stressify.run_test(
    Stressify.http_post("https://httpbin.org/post"; payload="{\"nome\": \"$row[:nome]\"}", headers=Dict("Content-Type" => "application/json")),
)

println("Resultados: ", results)