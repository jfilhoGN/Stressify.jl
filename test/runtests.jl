using Coverage
using Test
using Stressify

# Inclua os arquivos de teste
include("test_utils.jl")
include("test_report.jl")
include("test_core.jl")

# Obtenha a cobertura de código
coverage_data = @coverage begin
    # Execute seus testes
    @testset "Stressify Tests" begin
        include("test_utils.jl")
        include("test_report.jl")
        include("test_core.jl")
    end
end

# Gere o relatório de cobertura em formato LCOV
lcov_file = joinpath(pwd(), "coverage.lcov")
write(lcov_file, LCOV.writeLcov(coverage_data))
println("Cobertura gerada em $lcov_file")
