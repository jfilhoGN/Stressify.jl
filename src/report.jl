module Report

using Plots

"""
    generate_report(results::Dict)

Gera um gráfico de tempos de resposta.
"""
function generate_report(results::Dict)
    times = results["all_times"]
    plot(
        1:length(times), times,
        xlabel="Requisição", ylabel="Tempo (s)",
        title="Desempenho do Endpoint",
        legend=false
    )
end

export generate_report

end
