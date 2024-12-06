using Coverage
using Test
using Stressify

Coverage.@coverage begin
    include("test_utils.jl")
    include("test_report.jl")
    include("test_core.jl") 
end

lcov_report = joinpath(pwd(), "coverage.lcov")
println("Saving coverage report to $lcov_report")
Coverage.lcov_write(lcov_report)