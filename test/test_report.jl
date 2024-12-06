using Test
using Stressify.Report

@testset "generate_report" begin

    @testset "with missing key" begin
        original_stdout = stdout
        (rd, wr) = redirect_stdout()
        
        try
            Report.generate_report(Dict(), "unused.png") 
            
            close(wr)
            
            output = String(readavailable(rd))
            @test occursin("Erro: Nenhum dado de tempo encontrado ou a chave 'all_times' não foi fornecida.", output)
        finally
            redirect_stdout(original_stdout)
        end
    end
    
    @testset "with data" begin
        temp_plot = mktemp()[1]
        results = Dict("all_times" => [1.0, 2.0, 3.0])
        Report.generate_report(results, temp_plot)
        
        @test isfile(temp_plot)
        
        rm(temp_plot)
    end

    @testset "custom file name" begin
        custom_name = "custom_plot.png"
        temp_plot = mktemp()[1]
        results = Dict("all_times" => [1.0, 2.0, 3.0])
        Report.generate_report(results, custom_name)
        
        @test isfile(custom_name)
        
        rm(custom_name)
    end
end