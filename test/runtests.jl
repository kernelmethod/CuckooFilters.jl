using Cuckoo, Test

@testset "CuckooFilter tests" begin
    @testset "Insertion tests" begin
        filter = CuckooFilter()
        insert!(filter, b"hello, world!")
        insert!(filter, b"goodbye!")

        @assert b"hello, world!" ∈ filter
        @assert b"goodbye!" ∈ filter
    end
end
