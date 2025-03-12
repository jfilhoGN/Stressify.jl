import Pkg
Pkg.activate(".")
Pkg.add("Faker")
using Faker
using Stressify

# For more information use the documentation https://neomatrixcode.gitbook.io/faker
name_faker = Faker.first_name()
email_faker = Faker.email()
address_faker = Faker.street_name()

object = Dict(
    "nome" => name_faker,
    "email" => email_faker,
    "endereco" => address_faker
)

Stressify.options(
    vus = 3,        
    iterations = 10,
    duration = nothing
)

checks = [
    Stressify.Check("Status é 200", x -> x.status == 200),
]

req = Stressify.http_get("https://httpbin.org/get"; checks=checks)

req1 = Stressify.http_post(
    "https://httpbin.org/post";
    payload="{\"nome\": \"$(object["nome"])\", \"email\": \"$(object["email"])\", \"endereco\": \"$(object["endereco"])\"}",
    headers=Dict("Content-Type" => "application/json"),
    checks=checks
)

response = Stressify.run_test(req, req1)