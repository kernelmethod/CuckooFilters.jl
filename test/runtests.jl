using CuckooFilters, Documenter, Test

@testset "CuckooFilter tests" begin
    @testset "Insertion tests" begin
        filter = CuckooFilter()
        insert!(filter, b"hello, world!")
        insert!(filter, b"goodbye!")

        @test b"hello, world!" ∈ filter
        @test b"goodbye!" ∈ filter
    end

    @testset "Deletion tests" begin
        filter = CuckooFilter()
        insert!(filter, b"hello, world!")
        insert!(filter, b"goodbye!")
        delete!(filter, b"hello, world!")

        @test b"hello, world!" ∉ filter
        @test b"goodbye!" ∈ filter
    end
end

@testset "CuckooFilter doctests" begin
    doctest(CuckooFilters)
end
