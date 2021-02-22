using Documenter
using CuckooFilters

makedocs(
    sitename = "CuckooFilters",
    format = Documenter.HTML(),
    modules = [CuckooFilters]
)

deploydocs(
    repo = "github.com/kernelmethod/CuckooFilters.jl.git",
    devbranch = "main",
)
