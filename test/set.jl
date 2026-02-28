@testset "set.jl" begin
    @testset "basic" begin
        s = AVLSet()
        items = ["anything", "anything2"]
        push!(s, items[1])
        r = collect(s)
        @test length(r) == 1
        @test items[1] in r
        push!(s, items[2])
        r = collect(s)
        @test length(r) == 2
        @test all(items .∈ Ref(s))
        @test all(items .∈ Ref(r))
        delete!(s, items[1])
        delete!(s, items[2])
        @test isempty(s)
    end

    @testset "constructor with AbstractVector input" begin
        items = rand(1_000)
        s = AVLSet(items)
        @test eltype(items) == eltype(s)
        @test all(items .∈ Ref(s))
        @test all(items .∈ Ref(collect(s)))
    end

    @testset "Base-like constructors" begin
        s = AVLSet(i for i in 1:3)
        @test s == AVLSet([1, 2, 3])
        @test typeof(s) == AVLSet{Int}

        s_empty = AVLSet(())
        @test isempty(s_empty)
        @test typeof(s_empty) == AVLSet{Any}
    end

    @testset "Base-like interface" begin
        s = AVLSet([3, 1, 2, 2])
        @test length(s) == 3
        @test 2 in s
        @test !("2" in s)
        @test last(s) == 3

        c = copy(s)
        @test c == s
        @test c !== s
        push!(c, 4)
        @test 4 in c
        @test !(4 in s)

        dst = AVLSet([99])
        copy!(dst, s)
        @test dst == s

        sim = similar(s)
        @test isa(sim, AVLSet{Int})
        @test isempty(sim)

        simf = similar(s, Float64)
        @test isa(simf, AVLSet{Float64})
        push!(simf, 1)
        @test 1.0 in simf

        emp = empty(s)
        @test isa(emp, AVLSet{Int})
        @test isempty(emp)

        emp_t = empty(AVLSet{Int})
        @test isa(emp_t, AVLSet{Int})
        @test isempty(emp_t)

        s2 = AVLSet([1, 2, 3])
        delete!(s2, "x")
        @test s2 == AVLSet([1, 2, 3])

        empty!(s2)
        @test isempty(s2)
    end

    @testset "Base-like equality" begin
        s1 = AVLSet([1, 2, 3])
        s2 = AVLSet([3, 2, 1])
        s3 = AVLSet([1, 2])

        @test s1 == s2
        @test isequal(s1, s2)
        @test s1 != s3
        @test !isequal(s1, s3)

        @test AVLSet{Int}() == AVLSet{Float64}()
        @test isequal(AVLSet{Int}(), AVLSet{Float64}())
    end

    @testset "Base-like subset relations" begin
        s = AVLSet([1, 2, 3])
        t = AVLSet([1, 2, 3, 4])
        u = AVLSet([2, 5])

        @test issubset(s, t)
        @test !issubset(t, s)
        @test !issubset(u, s)
        @test issubset(AVLSet{Int}(), s)

        @test s ⊆ t
        @test s ⊊ t
        @test !(t ⊆ s)
        @test !(s ⊊ s)
    end

    @testset "Base-like symmetric difference" begin
        a = rand(1:1000, 400)
        b = rand(1:1000, 400)

        avl_a = AVLSet(a)
        avl_b = AVLSet(b)
        sa = Set(a)
        sb = Set(b)

        @test symdiff(avl_a, avl_b) == symdiff(sa, sb)

        avl_c = copy(avl_a)
        sc = copy(sa)
        @test symdiff!(avl_c, avl_b) == symdiff!(sc, sb)

        @test avl_c == sc
    end

    @testset "Base-like filtering" begin
        s = AVLSet(1:10)

        even_avl = filter(iseven, s)
        even_set = filter(iseven, Set(1:10))
        @test even_avl == even_set
        @test s == AVLSet(1:10)

        filter!(x -> x ≤ 5, s)
        @test s == AVLSet(1:5)
    end

    @testset "Base-like first and pop!" begin
        s = AVLSet([4, 2, 9, 1])
        @test first(s) == 1
        @test last(s) == 9

        p = pop!(s)
        @test p == 1
        @test !(p in s)

        s2 = AVLSet([10, 20, 30])
        @test pop!(s2, 20) == 20
        @test !(20 in s2)
        @test_throws KeyError pop!(s2, 100)
        @test pop!(s2, 100, -1) == -1
    end

    @testset "Base-like empty-set edges" begin
        e = AVLSet{Int}()
        @test_throws ArgumentError first(e)
        @test_throws ArgumentError last(e)
        @test_throws ArgumentError pop!(e)
        @test_throws KeyError pop!(e, 1)
        @test pop!(e, 1, 42) == 42
        @test isempty(e)
    end

    @testset "union" begin
        a = rand(1:1000, 800)
        b = rand(1:1000, 800)

        avl_a = AVLSet(a)
        avl_b = AVLSet(b)

        sa = Set(a)
        sb = Set(b)

        @test union(avl_a, avl_b) == union(sa, sb)
        @test union(avl_a, avl_a) == union(sa, sa)
        @test union(avl_a, avl_b, avl_b) == union(sa, sb)
        @test union(avl_a, sb, avl_b, avl_a, sb) == union(sa, sb)
        @test union!(avl_a, avl_b) == union(sa, sb)
        @test union!(avl_b, avl_a) == union(sa, sb)
    end

    @testset "setdiff" begin
        a = rand(1:1000, 800)
        b = rand(1:1000, 800)

        avl_a = AVLSet(a)
        avl_b = AVLSet(b)

        sa = Set(a)
        sb = Set(b)

        @test setdiff(avl_a, avl_b, avl_b) == setdiff(sa, sb)
        @test setdiff(avl_a, avl_a) == setdiff(sa, sa)
        @test setdiff(avl_a, sb) == setdiff(sa, sb)
    end

    @testset "intersect" begin
        a = rand(1:1000, 800)
        b = rand(1:1000, 800)

        avl_a = AVLSet(a)
        avl_b = AVLSet(b)

        sa = Set(a)
        sb = Set(b)

        @test intersect(avl_a, avl_b) == intersect(sa, sb)
        @test intersect(avl_a, avl_a) == intersect(sa, sa)
    end
end
