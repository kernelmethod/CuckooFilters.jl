using CuckooFilters, Documenter, Test

@testset "CuckooFilter tests" begin
    @testset "Insertion tests" begin
        filter = CuckooFilter{AbstractVector{UInt8}}()
        @test b"hello, world!" ∉ filter
        @test b"goodbye!" ∉ filter

        @test insert!(filter, b"hello, world!")
        @test insert!(filter, b"goodbye!")

        @test b"hello, world!" ∈ filter
        @test b"hello, world" ∉ filter
        @test b"goodbye!" ∈ filter

        filter = CuckooFilter{Int64}()
        for ii = 1:256
            insert!(filter, ii)
        end

        @test all(x ∈ filter for x = 1:256)
    end

    @testset "Unique insertion tests" begin
        filter = CuckooFilter{AbstractVector{UInt8}}()
        @test insert_unique!(filter, b"hello, world!")
        @test b"hello, world!" ∈ filter

        # insert! returns whether or not the insertion was successful. If we're
        # performing unique insertions, then our second attempt at insertion
        # should return false.
        @test insert_unique!(filter, b"hello, world!") == false
    end

    @testset "Deletion tests" begin
        filter = CuckooFilter{AbstractVector{UInt8}}()
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
