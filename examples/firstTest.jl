import Pkg
Pkg.activate(".")
using Stressify

#execute for the one VU for one iteration
Stressify.options(
    vus = 1,           
    iterations = 1,    
    duration = nothing  
)

results = Stressify.run_test(
    Stressify.http_get("https://httpbin.org/get"),
)

println("Resultados: ", results)
