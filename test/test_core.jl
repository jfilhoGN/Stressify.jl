using Test
using HTTP
using Stressify
using Test
import .Core

@testset "HTTP Methods" begin
    endpoint = "http://example.com"

    @testset "http_get" begin
        result = Stressify.http_get(endpoint)
        @test result isa NamedTuple
        @test result.method == HTTP.get
        @test result.url == endpoint
        @test result.payload === nothing
        @test result.headers == Dict()
        @test result.checks == []
    end

    @testset "http_get with checks" begin
        checks = [Stressify.Check("Check if status is 200", r -> r.status == 200)]
        result = Stressify.http_get(endpoint, checks=checks)
        @test result.checks == checks
    end

    @testset "http_post" begin
        payload = "some data"
        headers = Dict("Content-Type" => "application/json")
        result = Stressify.http_post(endpoint, payload=payload, headers=headers)
        @test result isa NamedTuple
        @test result.method == HTTP.post
        @test result.url == endpoint
        @test result.payload == payload
        @test result.headers == headers
        @test result.checks == []
    end

    @testset "http_put" begin
        payload = "updated data"
        result = Stressify.http_put(endpoint, payload=payload)
        @test result isa NamedTuple
        @test result.method == HTTP.put
        @test result.url == endpoint
        @test result.payload == payload
        @test result.headers == Dict()
        @test result.checks == []
    end

    @testset "http_patch" begin
        payload = "partial update"
        result = Stressify.http_patch(endpoint, payload=payload)
        @test result isa NamedTuple
        @test result.method == HTTP.patch
        @test result.url == endpoint
        @test result.payload == payload
        @test result.headers == Dict()
        @test result.checks == []
    end

    @testset "http_delete" begin
        headers = Dict("Authorization" => "Bearer token")
        result = Stressify.http_delete(endpoint, headers=headers)
        @test result isa NamedTuple
        @test result.method == HTTP.delete
        @test result.url == endpoint
        @test result.payload === nothing
        @test result.headers == headers
        @test result.checks == []
    end

    @testset "Check with all HTTP methods" begin
        checks = [Stressify.Check("Check if response is successful", r -> r.status < 400)]
        for func in [Stressify.http_get, Stressify.http_post, Stressify.http_put, Stressify.http_patch, Stressify.http_delete]
            result = func(endpoint, checks=checks)
            @test result.checks == checks
        end
    end
end

@testset "format_results" begin
    mock_results = Dict(
        "vus" => 5,
        "iterations" => 100,
        "success_rate" => 98.5,
        "error_rate" => 1.5,
        "rps" => 15.2,
        "tps" => 14.9,
        "errors" => 2,
        "min_time" => 0.01,
        "max_time" => 2.5,
        "mean_time" => 0.5,
        "median_time" => 0.3,
        "p90_time" => 1.0,
        "p95_time" => 1.5,
        "p99_time" => 2.0,
        "std_time" => 0.4,
        "all_times" => [0.1, 0.2, 0.3, 0.4, 0.5]
    )

    formatted = Stressify.format_results(mock_results)
    
    @testset "Header Format" begin
        @test occursin("================== Stressify ==================", formatted)
    end

    @testset "Basic Information" begin
        @test occursin("VUs                    :          5", formatted)
        @test occursin("Iterações Totais       :        100", formatted)
        @test occursin("Taxa de Sucesso (%)    :       98.5", formatted)  
        @test occursin("Taxa de Erros (%)      :        1.5", formatted) 
        @test occursin("Requisições por Segundo:       15.2", formatted)
        @test occursin("Transações por Segundo :       14.9", formatted)
        @test occursin("Número de Erros        :          2", formatted)
    end

    @testset "Time Metrics" begin
        @test occursin("Tempo Mínimo           :       0.01", formatted) 
        @test occursin("Tempo Máximo           :        2.5", formatted)
        @test occursin("Tempo Médio            :        0.5", formatted)
        @test occursin("Mediana                :        0.3", formatted)
        @test occursin("P90                    :        1.0", formatted)
        @test occursin("P95                    :        1.5", formatted)
        @test occursin("P99                    :        2.0", formatted)
        @test occursin("Desvio Padrão          :        0.4", formatted)
    end

    @testset "All Times" begin
        @test occursin("Todos os Tempos (s)    : 0.1, 0.2, 0.3, 0.4, 0.5", formatted)
    end

    @testset "Footer Format" begin
        @test occursin("==========================================================", formatted)
    end
end


@testset "compute_statistics" begin
    # Teste com dados
    @testset "with data" begin
        all_times = [0.1, 0.2, 0.5, 0.1, 0.3]
        total_errors = Base.Threads.Atomic{Int}(1)
        total_requests = 5
        total_duration = 1.0
        vus = 5

        stats = Stressify.compute_statistics(all_times, total_errors, total_requests, total_duration, vus)

        @test stats["iterations"] == 5
        @test stats["errors"] == 1
        @test stats["success_rate"] ≈ 80.0
        @test stats["error_rate"] ≈ 20.0 
        @test stats["min_time"] ≈ 0.1
        @test stats["max_time"] ≈ 0.5
        @test stats["mean_time"] ≈ (0.1 + 0.2 + 0.5 + 0.1 + 0.3) / 5
        @test stats["median_time"] ≈ 0.2
        @test stats["vus"] == vus
        @test stats["rps"] ≈ 5.0
        @test stats["tps"] ≈ 4.0
        @test stats["all_times"] == all_times
    end
end
