using Test
using CSV
using Random
using JSON
using DataFrames
using Stressify.Utils

@testset "save_results_to_json" begin
    results = Dict("test" => 123)
    filepath = mktemp()[1]  
    Utils.save_results_to_json(results, filepath)
    @test isfile(filepath)
    loaded_results = JSON.parsefile(filepath)
    @test loaded_results == results
    rm(filepath)  
end

@testset "random_csv_row" begin
    test_data = DataFrame(col1 = [1, 2, 3], col2 = ["a", "b", "c"])
    temp_csv = mktemp()[1]
    CSV.write(temp_csv, test_data)

    random_row = Utils.random_csv_row(temp_csv)
    @test isa(random_row, DataFrameRow)
    
    for col in names(test_data)
        @test random_row[col] in test_data[!, col]
    end
    
    rm(temp_csv)
    @test_throws ArgumentError Utils.random_csv_row("non_existent.csv")
end

@testset "random_json_object" begin
    
    test_json = Dict("key1" => "value1", "key2" => "value2")
    temp_json = mktemp()[1]
    open(temp_json, "w") do f
        JSON.print(f, test_json)
    end

    random_obj = Utils.random_json_object(temp_json)
    @test any(v -> v == random_obj, values(test_json)) 
    @test typeof(random_obj) <: Any

    test_json_array = ["a", "b", "c"]
    open(temp_json, "w") do f
        JSON.print(f, test_json_array)
    end

    @testset "Unsupported JSON structure" begin
        file_path = "unsupported.json"
        
        unsupported_data = "12345" 
        open(file_path, "w") do f
            write(f, unsupported_data)
        end
        
        try
            @test_throws ArgumentError random_json_object(file_path)
        finally
            isfile(file_path) && rm(file_path)
        end
    end

    random_obj_array = Utils.random_json_object(temp_json)
    @test random_obj_array in test_json_array

    @test_throws ArgumentError Utils.random_json_object("non_existent.json")

    rm(temp_json) 
end