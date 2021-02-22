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

@testset "CuckooFilter with custom type" begin
    # Test operations on CuckooFilter using a custom type that supports the
    # fingerprint and fingerprint_type methods
    struct Foo
        x::Int64
        y::Int64
    end

    CuckooFilters.fingerprint(f::Foo) = UInt32((f.x ⊻ f.y) & 0xffff)
    CuckooFilters.fingerprint_type(::Type{Foo}) = UInt32

    @testset "Insertion tests" begin
        filter = CuckooFilter{Foo}()
        @test Foo(1, 2) ∉ filter
        @test Foo(2, 3) ∉ filter
        @test insert!(filter, Foo(1, 2))
        @test insert!(filter, Foo(2, 3))
        @test Foo(1, 2) ∈ filter
        @test Foo(2, 3) ∈ filter

        # Should not be able to insert another type into the CuckooFilter
        @test_throws MethodError insert!(filter, 5)
    end

    @testset "Deletion tests" begin
        filter = CuckooFilter{Foo}()
        @test Foo(-5, 18) ∉ filter
        @test delete!(filter, Foo(-5, 18)) == false
        @test insert!(filter, Foo(-5, 18))
        @test Foo(-5, 18) ∈ filter
        @test delete!(filter, Foo(-5, 18))
        @test Foo(-5, 18) ∉ filter
    end
end

@testset "CuckooFilter doctests" begin
    doctest(CuckooFilters)
end
