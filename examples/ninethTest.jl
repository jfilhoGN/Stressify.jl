import Pkg
Pkg.activate(".")
using Stressify

Stressify.options(
    vus = 2,
    iterations = 10,   
    duration = nothing, 
    noDebug = true     
)

results = Stressify.run_test(
    Stressify.http_get("https://httpbin.org/get"),
)

println(results)