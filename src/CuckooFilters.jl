module CuckooFilters
using SHA: sha256

include("bucket.jl")
include("filter.jl")

fingerprint(x::AbstractVector{UInt8}) = sha256(x)[1]
fingerprint(x::Integer) = UInt8(x & 0xff)

# Exports
export CuckooFilter
export insert_unique!

end # module
