import Pkg
Pkg.activate(".")
using JuliaPerformanceTest

# julia --project=. -t 50 examples/secondTest.jl

JuliaPerformanceTest.run_test("https://httpbin.org/get", "GET", iterations=1)
