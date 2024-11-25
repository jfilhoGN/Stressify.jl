import Pkg
Pkg.activate(".")
using JuliaPerformanceTest
# execute in unique thread

results = JuliaPerformanceTest.run_test("https://httpbin.org/get", "GET", iterations=10)
println(results)
