# Buckets implementation for the cuckoo filter

using Base.Iterators: enumerate

struct Bucket{F}
    buffer :: Vector{F}
end

Bucket{F}() where F = Bucket{F}(Vector{F}(undef, 0))

Base.length(b::Bucket) = length(b.buffer)
Base.in(x, b::Bucket) = x ∈ b.buffer
Base.insert!(b::Bucket, x) = append!(b.buffer, x)

function Base.delete!(b::Bucket, key)
    for (i, x) in enumerate(b.buffer)
        if x == key
            deleteat!(b.buffer, i)
            return true
        end
    end

    false
end

isfull(b::Bucket, max_size) = (length(b) ≥ max_size)
