import Pkg
Pkg.activate(".")
using Stressify
using Plots
using HTTP

#execution with 2 Vus for 10 iterations with generating report and saving results to json
Stressify.options(
    vus = 2,           
    iterations = 10,    
    duration = nothing  
)

results = Stressify.run_test(
    Stressify.http_get("https://httpbin.org/get"),
)
println("Resultados: ", results)
Stressify.generate_report(results)
Stressify.save_results_to_json(results, "report.json")
