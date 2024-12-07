using Test
using Stressify

# Inclua os arquivos de teste
include("test_utils.jl")
include("test_report.jl")
include("test_core.jl")

# Execute os testes
@testset "Stressify Tests" begin
    include("test_utils.jl")
    include("test_report.jl")
    include("test_core.jl")
end
