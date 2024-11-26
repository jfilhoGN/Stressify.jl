import Pkg
Pkg.activate(".")
using JuliaPerformanceTest
using HTTP
# execute in unique thread

results = JuliaPerformanceTest.run_test("https://httpbin.org/get", HTTP.get, iterations=10)
println(results)
