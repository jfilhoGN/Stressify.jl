using Test
using Stressify

results = Stressify.run_test("https://httpbin.org/get", "GET", iterations=10)
println(results)
Stressify.save_results_to_json(results, "results.json")