module CuckooFilters
using SHA: sha256

include("bucket.jl")
include("filter.jl")

fingerprint(x::AbstractVector{UInt8}) = sha256(x)[1]
fingerprint(x::Integer) = UInt8(x & 0xff)
fingerprint_type(::Type{<:AbstractVector{UInt8}}) = UInt8
fingerprint_type(::Type{<:Integer}) = UInt8

# Exports
export CuckooFilter
export insert_unique!

end # module
