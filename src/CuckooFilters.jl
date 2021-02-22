module CuckooFilters

const MAX_BUCKET_SIZE = 4

include("bucket.jl")

function fingerprint(x::AbstractVector{UInt8})
    if length(x) == 0
        error("Input vector must have length > 0")
    end

    x[1]
end

function fingerprint(x::AbstractString)
end

struct CuckooFilter{F}
    buckets :: Array{Bucket{F},1}
    max_bucket_kicks :: Int64
    max_bucket_size :: Int64
end

CuckooFilter() = CuckooFilter{UInt8}()

function CuckooFilter{F}(n_buckets = 100) where F
    buckets = [Bucket{F}() for _ = 1:n_buckets]
    CuckooFilter{F}(buckets, 100, 4)
end

function getbucket(filter, i)
    n_buckets = length(filter.buckets)
    i = (i % n_buckets) + 1
    return filter.buckets[i]
end

function Base.insert!(filter::CuckooFilter, key)
    f = fingerprint(key)
    h₁ = hash(key)

    # Probe first bucket to see if it has an empty entry
    b₁ = getbucket(filter, h₁)
    if !isfull(b₁, filter.max_bucket_size)
        insert!(b₁, f)
        return
    end

    # Probe second bucket to see if it has an empty entry
    h₂ = h₁ ⊻ hash(f)
    b₂ = getbucket(filter, h₂)
    if !isfull(b₂, filter.max_bucket_size)
        insert!(b₂, f)
        return
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
            return
        end
    end

    # If we've reached this point, we've gone through the maximum
    # number of possible iterations to try and kick fingerprints
    # through the cuckoo filter. We treat the hash table as full.
    error("Cuckoo filter is full")
end

function Base.delete!(filter::CuckooFilter, key)
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

function Base.in(key, filter::CuckooFilter)
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

# Exports
export CuckooFilter

end # module
