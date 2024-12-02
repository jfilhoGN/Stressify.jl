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
Stressify.generate_report(results, "./examples/reports/grafico.png")
Stressify.save_results_to_json(results, "./examples/reports/report.json")
