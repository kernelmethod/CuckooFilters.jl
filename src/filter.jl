# Definition of CuckooFilter and associated methods

"""
    CuckooFilter{F}

A cuckoo filter. `F` is the type of fingerprint used by the filter (defaults
to `UInt8`).

# Examples

```jldoctest; setup = :(using CuckooFilters)
julia> filter = CuckooFilter{AbstractVector{UInt8}}();

julia> b"hello, world!" ∈ filter
false

julia> insert!(filter, b"hello, world!")
true

julia> b"hello, world!" ∈ filter
true

julia> delete!(filter, b"hello, world!")
true

julia> b"hello, world!" ∈ filter
false
```
"""
struct CuckooFilter{T,F}
    buckets :: Array{Bucket{F},1}
    max_bucket_kicks :: Int64
    max_bucket_size :: Int64
end

CuckooFilter{T}() where T = CuckooFilter{T, fingerprint_type(T)}()

function CuckooFilter{T,F}(;
    n_buckets = 1000,
    max_bucket_kicks = 100,
    max_bucket_size = 4
) where {T,F}
    buckets = [Bucket{F}() for i = 1:n_buckets]
    CuckooFilter{T,F}(buckets, 100, 4)
end

function getbucket(filter, i)
    n_buckets = length(filter.buckets)
    i = (i % n_buckets) + 1
    return filter.buckets[i]
end

insert_unique!(filter::CuckooFilter, key) = insert!(filter, key, true)

function Base.insert!(
    filter::CuckooFilter{T},
    key::T,
    unique = false
) where T
    if unique && key ∈ filter
        return false
    end

    f = fingerprint(key)
    h₁ = hash(key)

    # Probe first bucket to see if it has an empty entry
    b₁ = getbucket(filter, h₁)
    if !isfull(b₁, filter.max_bucket_size)
        insert!(b₁, f)
        return true
    end

    # Probe second bucket to see if it has an empty entry
    h₂ = h₁ ⊻ hash(f)
    b₂ = getbucket(filter, h₂)
    if !isfull(b₂, filter.max_bucket_size)
        insert!(b₂, f)
        return true
    end

    # If both buckets are full, we need to relocate an existing
    # item from one of the two buckets and move it to another
    # bucket
    b, h = rand(((h₁, b₁), (h₂, b₂)))
    for i = 1:filter.max_bucket_kicks
        original_f = f

        # Swap the fingerprint f with a random fingerprint from
        # the bucket
        rand_idx = rand(1:length(b))
        f = b[rand_idx]
        b[rand_idx] = original_f

        # Attempt to insert the fingerprint into a new bucket
        h = h ⊻ hash(f)
        b = getbucket(f, h)
        if !isfull(b)
            insert!(b, f)
            return true
        end
    end

    # If we've reached this point, we've gone through the maximum
    # number of possible iterations to try and kick fingerprints
    # through the cuckoo filter. We treat the hash table as full.
    error("Cuckoo filter is full")
end

function Base.delete!(filter::CuckooFilter{T}, key::T) where T
    # Delete the key from its first possible bucket if it is inside
    # of that bucket
    f = fingerprint(key)
    h₁ = hash(key)
    b₁ = getbucket(filter, h₁)
    if delete!(b₁, f)
        return true
    end

    # If the first deletion failed, then we attempt to delete the
    # key from its second bucket
    h₂ = h₁ ⊻ hash(f)
    b₂ = getbucket(filter, h₂)
    delete!(b₂, f)
end

function Base.in(key::T, filter::CuckooFilter{T}) where T
    # Check whether the key's fingerprint is in its first possible
    # bucket
    f = fingerprint(key)
    h₁ = hash(key)
    if f ∈ getbucket(filter, h₁)
        return true
    end

    # Check whether the fingerprint is in its second possible bucket
    h₂ = h₁ ⊻ hash(f)
    f ∈ getbucket(filter, h₂)
end


