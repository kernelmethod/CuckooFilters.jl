# CuckooFilters.jl

## Installation

You can add this package to your Julia project with

```julia
using Pkg

Pkg.add(url="https://github.com/kernelmethod/CuckooFilters.jl", rev="main")
```

Alternatively, if you're using the Julia REPL, you can add it with

```julia
pkg> add https://github.com/kernelmethod/CuckooFilters.jl#main
```

## Usage

```jldoctest
julia> using CuckooFilters

julia> # Create a filter to store arbitrary byte vectors

julia> filter = CuckooFilter{AbstractVector{UInt8}}();

julia> # Insert some items into the filter

julia> insert!(filter, b"hello, world!");

julia> insert!(filter, b"foo bar baz");

julia> # Insert some items but don't re-insert them if they already exist

julia> insert_unique!(filter, b"hello, world!")
false

julia> insert_unique!(filter, b"goodbye!")
true

julia> # Delete items from the filter

julia> delete!(filter, b"hello, world!")
true

julia> delete!(filter, b"CuckooFilters.jl")
false

julia> # Test whether or not a byte string has been stored in the filter

julia> b"foo bar baz" in filter
true

julia> b"CuckooFilters.jl" in filter
false
```
