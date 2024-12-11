import Pkg
Pkg.activate(".")
using Stressify

#execute for the one VU for one iteration
Stressify.options(
    vus = 2,           
    iterations = 10,    
    duration = nothing,
    noDebug = true  
)

results = Stressify.run_test(
    Stressify.http_get("https://httpbin.org/get"),
)
