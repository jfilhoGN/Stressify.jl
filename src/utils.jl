module Utils

using JSON

"""
    save_results_to_json(results::Dict, filepath::String)

Salva resultados em um arquivo JSON.
"""
function save_results_to_json(results::Dict, filepath::String)
    open(filepath, "w") do file
        write(file, JSON.json(results))
    end
end

export save_results_to_json

end
