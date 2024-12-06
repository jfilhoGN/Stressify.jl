module Report

using Plots

"""
    generate_report(results::Dict)

Gera um gráfico de tempos de resposta.
"""
function generate_report(results::Dict, file_name::String="grafico.png")
    times = get(results, "all_times", [])
    
    if isempty(times)
        println("Erro: Nenhum dado de tempo encontrado ou a chave 'all_times' não foi fornecida.")
        return
    end
    
    p = plot(
        1:length(times), times,
        xlabel="Requisição", ylabel="Tempo (s)",
        title="Desempenho do Endpoint",
        legend=false
    )

    savefig(p, file_name)
    println("Gráfico salvo em: $file_name")
end


export generate_report

end
