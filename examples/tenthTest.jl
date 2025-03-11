using Pkg
Pkg.activate(".")
using Stressify

# Configura as opções globais
Stressify.options(
    vus = 5,        
    iterations = 10, 
    duration = nothing
)

# Cria rate limiters diferentes para GET e POST
rate_limiter_get = Stressify.RateLimiter(5.0)  # 5 requisições por segundo para GET
rate_limiter_post = Stressify.RateLimiter(2.0) # 2 requisições por segundo para POST

# Cria as requisições HTTP com rate limiters específicos
requests = [
    Stressify.http_get("https://httpbin.org/get", rate_limiter = rate_limiter_get),  
    Stressify.http_post(                                                            
        "https://httpbin.org/post",
        payload = """{"key": "value"}""",
        headers = Dict("Content-Type" => "application/json"),
        rate_limiter = rate_limiter_post
    )
]

# Executa o teste de performance
Stressify.run_test(requests...)
