import Pkg
Pkg.activate(".")
using JuliaPerformanceTest
using HTTP

#using iterations 
results = JuliaPerformanceTest.run_test(
    "https://httpbin.org/anything",
    [HTTP.get, HTTP.post]; 
    payload="{\"key\": \"value\"}",
    headers=Dict("Content-Type" => "application/json"),
    iterations=10
)
println("Resultados Baseado em Iterações: ", results)

#using duration
results = JuliaPerformanceTest.run_test(
    "https://httpbin.org/anything",
    [HTTP.get, HTTP.post]; 
    payload="{\"key\": \"value\"}",
    headers=Dict("Content-Type" => "application/json"),
    duration=5.0  # Executa por 5 segundos
)
println("Resultados Baseado em Duração: ", results)

#using both iterations and duration
results = JuliaPerformanceTest.run_test(
    "https://httpbin.org/anything",
    [HTTP.get, HTTP.post]; 
    payload="{\"key\": \"value\"}",
    headers=Dict("Content-Type" => "application/json"),
    iterations=20,
    duration=10.0  # Termina após 20 iterações ou 10 segundos, o que ocorrer primeiro
)
println("Resultados Combinados: ", results)