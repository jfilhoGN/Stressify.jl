import Pkg
Pkg.activate(".")
using JuliaPerformanceTest
using Plots

# julia --project=. -t 50 examples/secondTest.jl

results = JuliaPerformanceTest.run_test("https://httpbin.org/get", "GET", iterations=10)
# generate simple view graph
JuliaPerformanceTest.generate_report(results)

#generate json report
JuliaPerformanceTest.save_results_to_json(results, "report.json")