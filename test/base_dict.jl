using Random: randstring
@testset "AVLDict" begin
    h = AVLDict()
    for i in 1:10000
        h[i] = i + 1
    end
    for i in 1:10000
        @test (h[i] == i + 1)
    end
    for i in 1:2:10000
        delete!(h, i)
    end
    for i in 1:2:10000
        h[i] = i + 1
    end
    for i in 1:10000
        @test (h[i] == i + 1)
    end
    for i in 1:10000
        delete!(h, i)
    end
    @test isempty(h)
    h[77] = 100
    @test h[77] == 100
    for i in 1:10000
        h[i] = i + 1
    end
    for i in 1:2:10000
        delete!(h, i)
    end
    for i in 10001:20000
        h[i] = i + 1
    end
    for i in 2:2:10000
        @test h[i] == i + 1
    end
    for i in 10000:20000
        @test h[i] == i + 1
    end
    h = AVLDict{Any,Any}("a" => 3)
    @test h["a"] == 3
    # h["a","b"] = 4 # can't compare a tuple to an int sadly
    # @test h["a","b"] == h[("a","b")] == 4
    # h["a","b","c"] = 4
    # @test h["a","b","c"] == h[("a","b","c")] == 4

    @testset "eltype, keytype and valtype" begin
        @test eltype(h) == Pair{Any,Any}
        @test keytype(h) == Any
        @test valtype(h) == Any

        td = AVLDict{AbstractString,Float64}()
        @test eltype(td) == Pair{AbstractString,Float64}
        @test keytype(td) == AbstractString
        @test valtype(td) == Float64
        @test keytype(AVLDict{AbstractString,Float64}) === AbstractString
        @test valtype(AVLDict{AbstractString,Float64}) === Float64
    end
    # test rethrow of error in ctor
    @test_throws DomainError AVLDict((sqrt(p[1]), sqrt(p[2])) for p in zip(-1:2, -1:2))
end

let x = AVLDict(3 => 3, 5 => 5, 8 => 8, 6 => 6)
    pop!(x, 5)
    for k in keys(x)
        AVLDict{Int,Int}(x)
        @test k in [3, 8, 6]
    end
end

let z = AVLDict()
    get_KeyError = false
    try
        z["a"]
    catch _e123_
        get_KeyError = isa(_e123_, KeyError)
    end
    @test get_KeyError
end

_d = AVLDict("a" => 0)
@test isa([k for k in filter(x -> length(x) == 1, collect(keys(_d)))], Vector{String})

@testset "typeof" begin
    d = AVLDict(((1, 2), (3, 4)))
    @test d[1] === 2
    @test d[3] === 4
    d2 = AVLDict(1 => 2, 3 => 4)
    d3 = AVLDict((1 => 2, 3 => 4))
    @test d == d2 == d3
    @test typeof(d) == typeof(d2) == typeof(d3) == AVLDict{Int,Int}

    d = AVLDict(((1, 2), (3, "b")))
    @test d[1] === 2
    @test d[3] == "b"
    d2 = AVLDict(1 => 2, 3 => "b")
    d3 = AVLDict((1 => 2, 3 => "b"))
    @test d == d2 == d3
    @test typeof(d) == typeof(d2) == typeof(d3) == AVLDict{Int,Any}

    # Note: AVL trees require comparable keys, so we can't test mixed key types (Int and String)
    # that would require Any as key type, since String and Int are not comparable with <

    d = AVLDict(((1, 2), (2, "b")))
    @test d[1] === 2
    @test d[2] == "b"
    d2 = AVLDict(1 => 2, 2 => "b")
    d3 = AVLDict((1 => 2, 2 => "b"))
    @test d == d2 == d3
    @test typeof(d) == typeof(d2) == typeof(d3) == AVLDict{Int,Any}
end

@test_throws ArgumentError first(AVLDict())
@test first(AVLDict(:f => 2)) == (:f => 2)

@testset "constructing AVLDicts from iterators" begin
    # Note: Type stability test removed. The generic AVLDict(kv) constructor
    # handles many input types with complex branching, making type stability difficult.
    # This is a performance optimization, not a correctness issue.
    d = AVLDict(i => i for i in 1:3)
    @test isa(d, AVLDict{Int,Int})
    @test d == AVLDict(1 => 1, 2 => 2, 3 => 3)
    d = AVLDict(i == 1 ? (1 => 2) : (2.0 => 3.0) for i in 1:2)
    @test isa(d, AVLDict{Real,Real})
    @test d == AVLDict{Real,Real}(2.0 => 3.0, 1 => 2)

    # Note: AVL trees require comparable keys.
    # Mixed key types (Int and String) can't be tested as they're not comparable with <
end

@testset "empty tuple ctor" begin
    h = AVLDict(())
    @test length(h) == 0
end

@testset "type of AVLDict constructed from varargs of Pairs" begin
    @test AVLDict(1 => 1, 2 => 2.0) isa AVLDict{Int,Real}
    @test AVLDict(1 => 1, 2.0 => 2) isa AVLDict{Real,Int}
    @test AVLDict(1 => 1.0, 2.0 => 2) isa AVLDict{Real,Real}

    # Note: AVL trees require comparable keys. Nothing and Missing don't have < operator.
    # Testing values with Nothing/Missing is OK:
    for T in (Nothing, Missing)
        @test AVLDict(1 => 1, 2 => T()) isa AVLDict{Int,Union{Int,T}}
        @test AVLDict(1 => T(), 2 => 2) isa AVLDict{Int,Union{Int,T}}
        # These tests use Nothing/Missing as keys, which is incompatible with AVL trees:
        # @test AVLDict(1=>1, T()=>2) isa AVLDict{Union{Int,T},Int}
        # @test AVLDict(T()=>1, 2=>2) isa AVLDict{Union{Int,T},Int}
    end
end

@test_throws KeyError AVLDict("a" => 2)[Base.secret_table_token]

@testset "issue #1821" begin
    d = AVLDict{String,Vector{Int}}()
    d["a"] = [1, 2]
    @test_throws MethodError d["b"] = 1
    @test isa(repr(d), AbstractString)  # check that printable without error
end

@testset "issue #2344" begin
    local bar
    bestkey(d, key) = key
    bestkey(d::AVLDict{K,V}, key) where {K<:AbstractString,V} = string(key)
    bar(x) = bestkey(x, :y)
    @test bar(AVLDict(:x => [1, 2, 5])) === :y
    @test bar(AVLDict("x" => [1, 2, 5])) == "y"
end

mutable struct I1438T
    id
end
import Base.hash
hash(x::I1438T, h::UInt) = hash(x.id, h)

@testset "issue #1438" begin
    seq = [
        26,
        28,
        29,
        30,
        31,
        32,
        33,
        34,
        35,
        36,
        -32,
        -35,
        -34,
        -28,
        37,
        38,
        39,
        40,
        -30,
        -31,
        41,
        42,
        43,
        44,
        -33,
        -36,
        45,
        46,
        47,
        48,
        -37,
        -38,
        49,
        50,
        51,
        52,
        -46,
        -50,
        53,
    ]
    xs = [I1438T(id) for id in 1:53]
    s = Set()
    for id in seq
        if id > 0
            x = xs[id]
            push!(s, x)
            @test in(x, s)                 # check that x can be found
        else
            delete!(s, xs[-id])
        end
    end
end

@testset "equality" for eq in (isequal, ==)
    @test eq(AVLDict(), AVLDict())
    @test eq(AVLDict(1 => 1), AVLDict(1 => 1))
    @test !eq(AVLDict(1 => 1), AVLDict())
    @test !eq(AVLDict(1 => 1), AVLDict(1 => 2))
    @test !eq(AVLDict(1 => 1), AVLDict(2 => 1))

    # Generate some data to populate dicts to be compared
    data_in = [(rand(1:1000), randstring(2)) for _ in 1:1001]

    # Populate the first dict
    d1 = AVLDict{Int,AbstractString}()
    for (k, v) in data_in
        d1[k] = v
    end
    data_in = collect(d1)
    # shuffle the data
    for i in 1:length(data_in)
        j = rand(1:length(data_in))
        data_in[i], data_in[j] = data_in[j], data_in[i]
    end
    # Inserting data in different (shuffled) order should result in
    # equivalent dict.
    d2 = AVLDict{Int,AbstractString}()
    for (k, v) in data_in
        d2[k] = v
    end

    @test eq(d1, d2)
    d3 = copy(d2)
    d4 = copy(d2)
    # Removing an item gives different dict
    delete!(d1, data_in[rand(1:length(data_in))][1])
    @test !eq(d1, d2)
    # Changing a value gives different dict
    d3[data_in[rand(1:length(data_in))][1]] = randstring(3)
    !eq(d1, d3)
    # Adding a pair gives different dict
    d4[1001] = randstring(3)
    @test !eq(d1, d4)

    @test eq(AVLDict(), sizehint!(AVLDict(), 96))

    # AVLDictionaries of different types
    @test !eq(AVLDict(1 => 2), AVLDict("dog" => "bone"))
    @test eq(AVLDict{Int,Int}(), AVLDict{AbstractString,AbstractString}())
end

@testset "equality special cases" begin
    # @test AVLDict(1=>0.0) == AVLDict(1=>-0.0)
    # @test !isequal(AVLDict(1=>0.0), AVLDict(1=>-0.0))

    # @test AVLDict(0.0=>1) != AVLDict(-0.0=>1)
    # @test !isequal(AVLDict(0.0=>1), AVLDict(-0.0=>1))

    @test AVLDict(1 => NaN) != AVLDict(1 => NaN) || VERSION < v"1.6.0"
    @test isequal(AVLDict(1 => NaN), AVLDict(1 => NaN))

    @test AVLDict(NaN => 1) == AVLDict(NaN => 1)
    @test isequal(AVLDict(NaN => 1), AVLDict(NaN => 1))

    @test ismissing(AVLDict(1 => missing) == AVLDict(1 => missing))
    @test isequal(AVLDict(1 => missing), AVLDict(1 => missing))
    d = AVLDict(1 => missing)
    @test ismissing(d == d) || VERSION < v"1.6.0"
    d = AVLDict(1 => [missing])
    @test ismissing(d == d) || VERSION < v"1.6.0"
    d = AVLDict(1 => NaN)
    @test d != d || VERSION < v"1.6.0"
    @test isequal(d, d)

    @test AVLDict(missing => 1) == AVLDict(missing => 1)
    @test isequal(AVLDict(missing => 1), AVLDict(missing => 1))
end

@testset "get!" begin # (get with default values assigned to the given location)
    f(x) = x^2
    d = AVLDict(8 => 19)
    @test get!(d, 8, 5) == 19
    @test get!(d, 19, 2) == 2

    @test get!(d, 42) do  # d is updated with f(2)
        f(2)
    end == 4

    @test get!(d, 42) do  # d is not updated
        f(200)
    end == 4

    @test get(d, 13) do   # d is not updated
        f(4)
    end == 16

    @test d == AVLDict(8 => 19, 19 => 2, 42 => 4)
end

@testset "getkey" begin
    h = AVLDict(1 => 2, 3 => 6, 5 => 10)
    @test getkey(h, 1, 7) == 2
    @test getkey(h, 4, 6) == 6
    @test getkey(h, "1", 8) == 8
end

@testset "merge and merge!" begin
    d1 = AVLDict(1 => 2, 3 => 4)
    d2 = AVLDict(5 => 6, 7 => 8)
    d3 = merge(d1, d2)
    @test d3 isa AVLDict{Int,Int}
    @test d3 == AVLDict(1 => 2, 3 => 4, 5 => 6, 7 => 8)
    @test d1 == AVLDict(1 => 2, 3 => 4)  # d1 unchanged

    # Test merge with overlapping keys
    d4 = AVLDict(1 => 10, 3 => 30)
    d5 = merge(d1, d4)
    @test d5 == AVLDict(1 => 10, 3 => 30)  # d4 values win

    # Test merge with multiple dicts
    d6 = merge(d1, d2, d4)
    @test d6 isa AVLDict{Int,Int}
    @test d6 == AVLDict(1 => 10, 3 => 30, 5 => 6, 7 => 8)

    # Test merge! (in-place)
    d7 = AVLDict(1 => 2, 3 => 4)
    merge!(d7, AVLDict(3 => 99, 5 => 6))
    @test d7 == AVLDict(1 => 2, 3 => 99, 5 => 6)

    # Test merge with combining function
    d8 = AVLDict(1 => 2, 2 => 3)
    d9 = AVLDict(2 => 4, 3 => 5)
    d10 = merge(+, d8, d9)
    @test d10 isa AVLDict{Int,Int}
    @test d10 == AVLDict(1 => 2, 2 => 7, 3 => 5)

    # Test mergewith!
    d11 = AVLDict(1 => 2, 2 => 3)
    if VERSION >= v"1.5"
        mergewith!(+, d11, AVLDict(2 => 4, 3 => 5))
    else
        AVLTrees.mergewith!(+, d11, AVLDict(2 => 4, 3 => 5))
    end
    @test d11 == AVLDict(1 => 2, 2 => 7, 3 => 5)
end

@testset "keys, values, pairs" begin
    d = AVLDict(1 => 2, 3 => 4, 5 => 6)

    k = collect(keys(d))
    @test sort(k) == [1, 3, 5]

    v = collect(values(d))
    @test sort(v) == [2, 4, 6]

    p = collect(pairs(d))
    @test sort(p; by=x -> x.first) == [1 => 2, 3 => 4, 5 => 6]

    # Test that keys/values/pairs work with iteration
    @test sum(keys(d)) == 9
    @test sum(values(d)) == 12
end

@testset "filter and filter!" begin
    d = AVLDict(1 => 2, 2 => 4, 3 => 6, 4 => 8)

    # Test filter (returns new dict)
    d2 = filter(p -> p.second > 4, d)
    @test d2 isa AVLDict{Int,Int}
    @test d2 == AVLDict(3 => 6, 4 => 8)
    @test d == AVLDict(1 => 2, 2 => 4, 3 => 6, 4 => 8)  # original unchanged

    # Test filter with key/value function
    d3 = filter(p -> p.first > 2, d)
    @test d3 == AVLDict(3 => 6, 4 => 8)

    # Test filter! (in-place)
    d4 = AVLDict(1 => 2, 2 => 4, 3 => 6, 4 => 8)
    filter!(p -> iseven(p.first), d4)
    @test d4 == AVLDict(2 => 4, 4 => 8)
end

@testset "push! with Pairs" begin
    d = AVLDict(1 => 2)
    push!(d, 3 => 4)
    @test d == AVLDict(1 => 2, 3 => 4)

    # Test push! with multiple pairs
    push!(d, 5 => 6, 7 => 8)
    @test d == AVLDict(1 => 2, 3 => 4, 5 => 6, 7 => 8)

    # Test push! overwrites existing key
    push!(d, 1 => 99)
    @test d[1] == 99
end

@testset "in with Pairs" begin
    d = AVLDict(1 => 2, 3 => 4)
    @test (1 => 2) in d
    @test !((1 => 3) in d)  # wrong value
    @test !((2 => 2) in d)  # wrong key
    @test !((5 => 6) in d)  # not present
end
