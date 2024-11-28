import Pkg
Pkg.activate(".")
using JuliaPerformanceTest

#execute for the one VU for one iteration
JuliaPerformanceTest.options(
    vus = 1,           
    iterations = 1,    
    duration = nothing  
)

results = JuliaPerformanceTest.run_test(
    JuliaPerformanceTest.http_get("https://httpbin.org/get"),
)

println("Resultados: ", results)
