import Pkg
Pkg.activate(".")
using JuliaPerformanceTest

results = JuliaPerformanceTest.run_test("https://httpbin.org/get", "GET", iterations=10)
println(results)
# JuliaPerformanceTest.save_results_to_json(results, "results.json")

# JuliaPerformanceTest.generate_report(results)