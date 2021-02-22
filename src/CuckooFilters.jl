module Cuckoo

# Type definitions
struct CuckooFilter
end

function Base.insert!(f::CuckooFilter, key)
end

function Base.delete!(f::CuckooFilter, key)
end

function Base.in(key, f::CuckooFilter)
end

function Base.length(f::CuckooFilter)
    0
end

# Exports
export CuckooFilter

end # module
