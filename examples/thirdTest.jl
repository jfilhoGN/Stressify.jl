import Pkg
Pkg.activate(".")
using JuliaPerformanceTest

#execution with 2 vus and 10 seconds duration with generating report and saving results to json
JuliaPerformanceTest.options(
    vus = 2,           
    iterations = nothing,    
    duration = 10.0  
)

results = JuliaPerformanceTest.run_test(
    JuliaPerformanceTest.http_get("https://httpbin.org/get"),
)
println("Resultados: ", results)
JuliaPerformanceTest.generate_report(results)
JuliaPerformanceTest.save_results_to_json(results, "report.json")