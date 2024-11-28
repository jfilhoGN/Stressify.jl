import Pkg
Pkg.activate(".")
using JuliaPerformanceTest
using Plots
using HTTP

#execution with 2 Vus for 10 iterations with generating report and saving results to json
JuliaPerformanceTest.options(
    vus = 2,           
    iterations = 10,    
    duration = nothing  
)

results = JuliaPerformanceTest.run_test(
    JuliaPerformanceTest.http_get("https://httpbin.org/get"),
)
println("Resultados: ", results)
JuliaPerformanceTest.generate_report(results)
JuliaPerformanceTest.save_results_to_json(results, "report.json")
