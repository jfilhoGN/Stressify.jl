using Documenter
using Stressify

makedocs(
    sitename = "Stressify.jl",
    pages = [
        "Home" => "index.md",
        "Guide" => "src/guide.md",
        "API" => "src/api.md"
    ]
)