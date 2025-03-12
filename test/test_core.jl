using Test
using HTTP
using Random
using Stressify
using Mocking
import .Core

@testset "compute_statistics" begin
    @testset "with empty data" begin
        all_times = Float64[]
        total_errors = Base.Threads.Atomic{Int}(0)
        total_requests = 0
        total_duration = 0.0
        vus = 1

        stats = Stressify.compute_statistics(all_times, total_errors, total_requests, total_duration, vus)
        @test isnan(stats["min_time"])
        @test isnan(stats["max_time"])
        @test isnan(stats["mean_time"])
        @test isnan(stats["median_time"])
        @test isnan(stats["std_time"])
        @test isnan(stats["p90_time"])
        @test isnan(stats["p95_time"])
        @test isnan(stats["p99_time"])
        @test isnan(stats["success_rate"])
        @test isnan(stats["error_rate"])
        @test isnan(stats["rps"])
        @test isnan(stats["tps"])
    end

    @testset "with data" begin
        all_times = [0.1, 0.2, 0.5, 0.1, 0.3]
        total_errors = Base.Threads.Atomic{Int}(1)
        total_requests = 5
        total_duration = 1.0
        vus = 1

        stats = Stressify.compute_statistics(all_times, total_errors, total_requests, total_duration, vus)
        @test stats["min_time"] ≈ 0.1
        @test stats["max_time"] ≈ 0.5
        @test stats["mean_time"] ≈ 0.24
        @test stats["median_time"] ≈ 0.2
        @test stats["std_time"] ≈ 0.1673 atol = 0.0001 
        @test stats["p90_time"] ≈ 0.5
        @test stats["p95_time"] ≈ 0.5
        @test stats["p99_time"] ≈ 0.5
        @test stats["success_rate"] ≈ 80.0
        @test stats["error_rate"] ≈ 20.0
        @test stats["rps"] ≈ 5.0
        @test stats["tps"] ≈ 4.0
    end
end

@testset "percentile" begin
    @testset "with empty data" begin
        data = Float64[]
        @test isnan(Stressify.percentile(data, 90))
    end

    @testset "with data" begin
        data = [0.1, 0.2, 0.3, 0.4, 0.5]
        @test Stressify.percentile(data, 90) ≈ 0.5
        @test Stressify.percentile(data, 50) ≈ 0.3
        @test Stressify.percentile(data, 10) ≈ 0.1
    end
end

@testset "format_results" begin
    results = Dict(
        "vus" => 1,
        "iterations" => 10,
        "success_rate" => 90.0,
        "error_rate" => 10.0,
        "rps" => 5.0,
        "tps" => 4.5,
        "errors" => 1,
        "min_time" => 0.1,
        "max_time" => 0.5,
        "mean_time" => 0.3,
        "median_time" => 0.3,
        "std_time" => 0.1,
        "p90_time" => 0.4,
        "p95_time" => 0.45,
        "p99_time" => 0.49,
        "all_times" => [0.1, 0.2, 0.3, 0.4, 0.5],
    )

    formatted = Stressify.format_results(results)
    @test occursin("VUs                    :          1", formatted)
    @test occursin("Iterações Totais       :         10", formatted)
    @test occursin("Taxa de Sucesso (%)    :       90.0", formatted)
    @test occursin("Taxa de Erros (%)      :       10.0", formatted)
    @test occursin("Requisições por Segundo:        5.0", formatted)
    @test occursin("Transações por Segundo :        4.5", formatted)
    @test occursin("Número de Erros        :          1", formatted)
    @test occursin("Tempo Mínimo           :        0.1", formatted)
    @test occursin("Tempo Máximo           :        0.5", formatted)
    @test occursin("Tempo Médio            :        0.3", formatted)
    @test occursin("Mediana                :        0.3", formatted)
    @test occursin("P90                    :        0.4", formatted)
    @test occursin("P95                    :       0.45", formatted)
    @test occursin("P99                    :       0.49", formatted)
    @test occursin("Desvio Padrão          :        0.1", formatted)
    @test occursin("Todos os Tempos (s)    : 0.1, 0.2, 0.3, 0.4, 0.5", formatted)
end

@testset "run_test" begin
    @testset "with GET requests" begin
        Stressify.options(
            vus = 1,
            format = "default",
            iterations = 1,
            duration = nothing,
        )

        requests = [Stressify.http_get("https://httpbin.org/get")]
        results = Stressify.run_test(requests...)
        @test results["iterations"] == 1
        @test results["errors"] == 0
    end

    @testset "with POST requests" begin
        Stressify.options(
            vus = 1,
            format = "default",
            iterations = 1,
            duration = nothing,
        )

        requests = [Stressify.http_post("https://httpbin.org/post", payload = "data")]
        results = Stressify.run_test(requests...)
        @test results["iterations"] == 1
        @test results["errors"] == 0
    end

    @testset "format vus-ramping with missing ramp_duration" begin

        @test_throws ErrorException Stressify.options(
            format = "vus-ramping",
            max_vus = 10,
            duration = 30.0,
        )
    end

    @testset "format vus-ramping with missing duration" begin
        @test_throws ErrorException Stressify.options(
            format = "vus-ramping",
            max_vus = 10,
            ramp_duration = 5.0,
        )
    end
end

@testset "RateLimiter and control_throughput" begin
    @testset "RateLimiter initialization" begin
        rate_limiter = Stressify.RateLimiter(2.0)
        @test rate_limiter.rps == 2.0
        @test rate_limiter.last_request_time == 0.0
    end

    @testset "control_throughput with no previous request" begin
        rate_limiter = Stressify.RateLimiter(2.0)
        t1 = time()
        Stressify.control_throughput(rate_limiter)
        @test time() - t1 < 0.1
    end

    @testset "control_throughput with previous request" begin
        rate_limiter = Stressify.RateLimiter(2.0)
        rate_limiter.last_request_time = time() - 0.3
        t1 = time()
        Stressify.control_throughput(rate_limiter)
        @test time() - t1 ≈ 0.2 atol = 0.1
    end
end

@testset "HTTP Methods with Rate Limiters" begin
    endpoint = "http://example.com"

    @testset "http_get with rate limiter" begin
        rate_limiter = Stressify.RateLimiter(5.0)  # 5 requisições por segundo
        result = Stressify.http_get(endpoint, rate_limiter = rate_limiter)
        @test result isa NamedTuple
        @test result.method == HTTP.get
        @test result.url == endpoint
        @test result.payload === nothing
        @test result.headers == Dict()
        @test result.checks == []
        @test result.rate_limiter === rate_limiter
    end

    @testset "http_post with rate limiter" begin
        rate_limiter = Stressify.RateLimiter(2.0)  # 2 requisições por segundo
        payload = "some data"
        headers = Dict("Content-Type" => "application/json")
        result = Stressify.http_post(endpoint, payload = payload, headers = headers, rate_limiter = rate_limiter)
        @test result isa NamedTuple
        @test result.method == HTTP.post
        @test result.url == endpoint
        @test result.payload == payload
        @test result.headers == headers
        @test result.checks == []
        @test result.rate_limiter === rate_limiter
    end

    @testset "http_put with rate limiter" begin
        rate_limiter = Stressify.RateLimiter(3.0)  # 3 requisições por segundo
        payload = "updated data"
        result = Stressify.http_put(endpoint, payload = payload, rate_limiter = rate_limiter)
        @test result isa NamedTuple
        @test result.method == HTTP.put
        @test result.url == endpoint
        @test result.payload == payload
        @test result.headers == Dict()
        @test result.checks == []
        @test result.rate_limiter === rate_limiter
    end

    @testset "http_patch with rate limiter" begin
        rate_limiter = Stressify.RateLimiter(1.0)  # 1 requisição por segundo
        payload = "partial update"
        result = Stressify.http_patch(endpoint, payload = payload, rate_limiter = rate_limiter)
        @test result isa NamedTuple
        @test result.method == HTTP.patch
        @test result.url == endpoint
        @test result.payload == payload
        @test result.headers == Dict()
        @test result.checks == []
        @test result.rate_limiter === rate_limiter
    end

    @testset "http_delete with rate limiter" begin
        rate_limiter = Stressify.RateLimiter(4.0)  # 4 requisições por segundo
        headers = Dict("Authorization" => "Bearer token")
        result = Stressify.http_delete(endpoint, headers = headers, rate_limiter = rate_limiter)
        @test result isa NamedTuple
        @test result.method == HTTP.delete
        @test result.url == endpoint
        @test result.payload === nothing
        @test result.headers == headers
        @test result.checks == []
        @test result.rate_limiter === rate_limiter
    end

    @testset "unsupported HTTP method" begin
        request = (
            method = (url, headers) -> "UNSUPPORTED_METHOD",
            url = "http://example.com",
            payload = nothing,
            headers = Dict(),
            checks = [],
            rate_limiter = nothing,
        )

        @test_throws "Método HTTP não suportado. Use: GET, POST, PUT, DELETE ou PATCH." Stressify.perform_request(request)
    end

end

@testset "Rate Limiter Control" begin
    @testset "control_throughput" begin
        rate_limiter = Stressify.RateLimiter(2.0)

        t1 = time()
        Stressify.control_throughput(rate_limiter)
        @test time() - t1 < 0.1

        t2 = time()
        Stressify.control_throughput(rate_limiter)
        @test time() - t2 ≈ 0.5 atol = 0.1
    end
end

@testset "perform_request with Rate Limiter" begin
    endpoint = "http://example.com"

    @testset "GET request with rate limiter" begin
        rate_limiter = Stressify.RateLimiter(5.0)  # 5 requisições por segundo
        request = Stressify.http_get(endpoint, rate_limiter = rate_limiter)

        # Mock da função HTTP.get para simular uma resposta
        Mocking.@patch HTTP.get(endpoint) = HTTP.Response(200)

        response = Stressify.perform_request(request)
        @test response.status == 200
    end
end

@testset "check function" begin
    response = HTTP.Response(200)

    success_check = Stressify.Check("Status is 200", r -> r.status == 200)
    fail_check = Stressify.Check("Status is 404", r -> r.status == 404)
    error_check = Stressify.Check("Throws an error", r -> error("Something went wrong"))

    @testset "successful check" begin
        Stressify.CHECK_RESULTS[] = []

        Stressify.check(response, "GET", [success_check])

        @test Stressify.CHECK_RESULTS[] == ["✔️ GET - Status is 200 - Success"]
    end

    @testset "failed check" begin
        Stressify.CHECK_RESULTS[] = []

        Stressify.check(response, "GET", [fail_check])

        @test Stressify.CHECK_RESULTS[] == ["❌ GET - Status is 404 - Failed"]
    end

    @testset "check that throws an error" begin
        Stressify.CHECK_RESULTS[] = []

        Stressify.check(response, "GET", [error_check])

        @test startswith(Stressify.CHECK_RESULTS[][1], "⚠️ GET - Throws an error - Error:")
    end
end