import Pkg
Pkg.activate(".")
using Stressify

#execution with 2 vus and 10 seconds duration with generating report and saving results to json
Stressify.options(
    vus = 2,           
    iterations = nothing,    
    duration = 10.0  
)

results = Stressify.run_test(
    Stressify.http_get("https://httpbin.org/get"),
)
Stressify.generate_report(results, "./examples/reports/grafico.png")
Stressify.save_results_to_json(results, "./examples/reports/report.json")