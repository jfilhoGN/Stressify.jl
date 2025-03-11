using Test
using HTTP
using Random
using Stressify
using Mocking
import .Core

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