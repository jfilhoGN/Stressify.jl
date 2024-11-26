import Pkg
Pkg.activate(".")
using JuliaPerformanceTest
using HTTP

# intercalated methods GET and POST in single execution
results = JuliaPerformanceTest.run_test(
    "https://httpbin.org/anything", 
    [HTTP.get, HTTP.post]; 
    payload="{\"key\": \"value\"}", 
    headers=Dict("Content-Type" => "application/json"), 
    iterations=10
)

println("Resultados: ", results)