
@testset "tree.jl" begin
    @testset "root insertion test" begin
        t = AVLTree{Int64,Int64}()
        insert!(t, 1, 2)
        @test t.root !== nothing
        @test t.root.bf == 0
        @test t.root.right === nothing && t.root.left === nothing
        @test t.root.key == 1 && t.root.data == 2
        @test size(t) == 1
        insert!(t, 1, 10)
        delete!(t, 999)
        @test t.root.data == 10
        @test size(t) == 1
    end

    @testset "left rotation test" begin
        t = AVLTree{Int64,Int64}()
        insert!(t, 1, 2)
        insert!(t, 2, 2)
        insert!(t, 3, 2)
        @test t.root.bf == 0 && t.root.left.bf == 0 && t.root.right.bf == 0
        @test t.root.key == 2 && t.root.left.key == 1 && t.root.right.key == 3
        @test size(t) == 3
    end

    @testset "right rotation test" begin
        t = AVLTree{Int64,Int64}()
        insert!(t, 3, 2)
        insert!(t, 2, 2)
        insert!(t, 1, 2)
        @test t.root.bf == 0 && t.root.left.bf == 0 && t.root.right.bf == 0
        @test t.root.key == 2 && t.root.left.key == 1 && t.root.right.key == 3
        @test size(t) == 3
    end

    @testset "left-right rotation test" begin
        t = AVLTree{Int64,Int64}()
        insert!(t, 3, 2)
        insert!(t, 1, 2)
        insert!(t, 2, 2)
        @test t.root.bf == 0 && t.root.left.bf == 0 && t.root.right.bf == 0
        @test t.root.key == 2 && t.root.left.key == 1 && t.root.right.key == 3
        @test size(t) == 3
    end

    @testset "right-left rotation test" begin
        t = AVLTree{Int64,Int64}()
        insert!(t, 1, 2)
        insert!(t, 3, 2)
        insert!(t, 2, 2)
        @test t.root.bf == 0 && t.root.left.bf == 0 && t.root.right.bf == 0
        @test t.root.key == 2 && t.root.left.key == 1 && t.root.right.key == 3
        @test size(t) == 3
    end

    @testset "tree{Any,Any} test" begin
        t = AVLTree()
        insert!(t, "item1", "item1")
        @test t.root.key == "item1"
        insert!(t, "item2", "item2")
        insert!(t, "item3", "item3")
        @test t.root.key == "item2"
        @test size(t) == 3
    end

    @testset "fill test" begin
        t = AVLTree{Int64,Int64}()
        for i in rand(Int64, 100)
            insert!(t, i, 0)
        end
        @test size(t) <= 100
    end

    @testset "delete basic" begin
        t = AVLTree{Int64,Int64}()
        insert!(t, 1, 2)
        insert!(t, 2, 2)
        insert!(t, 3, 2)
        @test size(t) == 3
        AVLTrees.delete_node!(t, t.root.left)
        @test t.root.left === nothing
        @test t.root.bf == 1
        @test size(t) == 2
        AVLTrees.delete_node!(t, t.root.right)
        @test t.root.right === nothing
        @test t.root.bf == 0
        @test size(t) == 1
        AVLTrees.delete_node!(t, t.root)
        @test size(t) == 0
        @test t.root === nothing
    end

    @testset "fill and delete all test" begin
        t = AVLTree{Int64,Int64}()
        for i in rand(Int64, 100)
            insert!(t, i, 0)
        end
        @test size(t) <= 100
        while t.root !== nothing
            AVLTrees.delete_node!(t, t.root)
        end
        @test t.root === nothing
        @test size(t) == 0
    end

    @testset "fill and delete keys test" begin
        t = AVLTree{Int64,Int64}()
        nums = rand(Int64, 100)
        for i in nums
            insert!(t, i, i)
        end
        @test size(t) <= 100
        for i in nums
            delete!(t, i)
        end
        @test size(t) == 0
        @test t.root === nothing
    end

    @testset "getkey test" begin
        t = AVLTree{Int64,Int64}()
        for i in 1:1000
            insert!(t, i, i)
        end
        @test size(t) == 1000
        @test 500 == getkey(t, 500, nothing)
        @test nothing === getkey(t, 1001, nothing)
        @test size(t) == 1000
    end

    @testset "iteration test" begin
        t = AVLTree{Int64,Int64}()
        for i in 1:1000
            insert!(t, i, i)
        end
        s1 = Set{Tuple{Int64,Int64}}([(_x, _x) for _x in 1:1000])
        s2 = Set{Tuple{Int64,Int64}}()
        for i in t
            push!(s2, i)
        end
        @test s1 == s2
    end

    @testset "Base.*" begin
        t = AVLTree{Int64,Int64}()

        for i in 1:100
            insert!(t, i, i)
        end

        @test eltype(t) == Tuple{Int64,Int64}
        @test getindex.(Ref(t), 1:100) == 1:100
        try
            getindex(t, -100)
        catch x
            @test x == KeyError(-100)
        end
        setindex!(t, -10, 10)
        @test t[10] == -10
        @test haskey(t, 10)
        @test !haskey(t, -10)
        @test length(t) == 100
        t[-10] = -10
        @test length(t) == 101
        @test !isempty(t)

        @test popfirst!(t) == -10
        @test firstindex(t) == 1
        t[10] = 10
        @test getproperty.(pop!.(Ref(t), 1:100), :data) == 1:100
    end

    @testset "get with default and function" begin
        t = AVLTree{Int,String}()
        for i in 1:10
            insert!(t, i, "val$i")
        end

        # get with default
        @test get(t, 5, "default") == "val5"
        @test get(t, 99, "default") == "default"

        # get with function
        @test get(t, 5, "default") == "val5"
        @test get(() -> "computed", t, 5) == "val5"
        @test get(() -> "computed", t, 99) == "computed"

        call_count = 0
        get(t, 5) do
            call_count += 1
            "not_called"
        end
        @test call_count == 0  # function not called when key exists

        get(t, 99) do
            call_count += 1
            "called"
        end
        @test call_count == 1  # function called when key missing
    end

    @testset "get! inserts on missing" begin
        t = AVLTree{Int,String}()
        insert!(t, 1, "one")
        insert!(t, 2, "two")

        # get! with default value
        @test get!(t, 1, "default") == "one"
        @test length(t) == 2
        @test get!(t, 3, "three") == "three"
        @test length(t) == 3
        @test t[3] == "three"

        # get! with function
        @test get!(() -> "four", t, 4) == "four"
        @test length(t) == 4
        @test t[4] == "four"
        @test get!(() -> "not_used", t, 1) == "one"
        @test length(t) == 4
    end

    @testset "pop! variations" begin
        # pop!() - remove maximum
        t = AVLTree{Int,Int}()
        foreach(i -> insert!(t, i, i * 10), [5, 3, 8, 1, 4, 7, 9])

        @test pop!(t) == 90
        @test !haskey(t, 9)
        @test length(t) == 6

        @test pop!(t) == 80
        @test !haskey(t, 8)
        @test length(t) == 5

        # pop!(key) - remove specific key
        node = pop!(t, 3)
        @test node.data == 30
        @test !haskey(t, 3)
        @test length(t) == 4

        @test_throws KeyError pop!(t, 99)

        # pop!(key, default) - with default
        node2 = pop!(t, 5, nothing)
        @test node2.data == 50
        @test !haskey(t, 5)
        @test pop!(t, 99, nothing) === nothing
        @test length(t) == 3

        # pop! on empty tree
        empty_tree = AVLTree{Int,Int}()
        @test_throws ArgumentError pop!(empty_tree)
    end

    @testset "popfirst! edge cases" begin
        t = AVLTree{Int,String}()
        @test_throws ArgumentError popfirst!(t)

        insert!(t, 5, "five")
        @test popfirst!(t) == "five"
        @test isempty(t)
    end

    @testset "firstindex edge cases" begin
        t = AVLTree{Int,Int}()
        @test_throws ArgumentError firstindex(t)

        insert!(t, 10, 1)
        @test firstindex(t) == 10
        insert!(t, 5, 1)
        @test firstindex(t) == 5
    end

    @testset "in function" begin
        t = AVLTree{Int,Int}()
        for i in [3, 1, 4, 1, 5, 9, 2, 6]
            insert!(t, i, i)
        end

        @test 3 in t
        @test 5 in t
        @test !(10 in t)
        @test !(0 in t)
    end

    @testset "special key types" begin
        # Nothing as key
        t_nothing = AVLTree{Nothing,String}()
        insert!(t_nothing, nothing, "value")
        @test haskey(t_nothing, nothing)
        @test t_nothing[nothing] == "value"
        @test length(t_nothing) == 1

        # Missing as key
        t_missing = AVLTree{Missing,String}()
        insert!(t_missing, missing, "value")
        @test haskey(t_missing, missing)
        @test t_missing[missing] == "value"
        @test length(t_missing) == 1
    end

    @testset "height calculation" begin
        t = AVLTree{Int,Int}()
        @test AVLTrees.height(t) == 0

        insert!(t, 5, 5)
        @test AVLTrees.height(t) == 1

        insert!(t, 3, 3)
        insert!(t, 7, 7)
        @test AVLTrees.height(t) == 2

        # Build taller tree
        for i in 1:15
            insert!(t, i, i)
        end
        h = AVLTrees.height(t)
        @test h >= 4 && h <= 6  # AVL tree height should be O(log n)
    end

    @testset "complex deletion with rebalancing" begin
        t = AVLTree{Int,Int}()
        # Insert to create specific tree structure
        for i in [50, 25, 75, 10, 35, 60, 80, 5, 15, 30, 40]
            insert!(t, i, i)
        end

        initial_size = length(t)
        @test initial_size == 11

        # Delete nodes that will trigger rebalancing
        delete!(t, 5)
        @test length(t) == 10
        @test !haskey(t, 5)

        delete!(t, 10)
        @test length(t) == 9
        @test !haskey(t, 10)

        delete!(t, 15)
        @test length(t) == 8

        # Verify all remaining keys are still accessible
        for k in [25, 30, 35, 40, 50, 60, 75, 80]
            @test haskey(t, k)
            @test t[k] == k
        end
    end

    @testset "iteration on empty and single element" begin
        t = AVLTree{Int,Int}()
        @test collect(t) == []

        insert!(t, 42, 100)
        @test collect(t) == [(42, 100)]
    end

    @testset "deletion of non-existent keys" begin
        t = AVLTree{Int,Int}()
        for i in 1:5
            insert!(t, i, i * 10)
        end

        # Delete non-existent key should not change tree
        delete!(t, 999)
        @test length(t) == 5
        delete!(t, -1)
        @test length(t) == 5

        # All original keys still present
        for i in 1:5
            @test haskey(t, i)
        end
    end

    @testset "update existing keys" begin
        t = AVLTree{String,Int}()
        insert!(t, "a", 1)
        insert!(t, "b", 2)
        insert!(t, "c", 3)

        @test length(t) == 3

        # Update existing keys
        insert!(t, "a", 10)
        @test t["a"] == 10
        @test length(t) == 3  # Size unchanged

        insert!(t, "b", 20)
        insert!(t, "c", 30)
        @test t["b"] == 20
        @test t["c"] == 30
        @test length(t) == 3
    end

    @testset "large tree operations" begin
        t = AVLTree{Int,Int}()
        n = 1000

        # Insert in random order (using randperm from Random stdlib)
        keys = randperm(n)
        for k in keys
            insert!(t, k, k * 2)
        end
        @test length(t) == n

        # Verify all keys present
        for k in 1:n
            @test haskey(t, k)
            @test t[k] == k * 2
        end

        # Delete half the keys
        for k in 1:2:n
            delete!(t, k)
        end
        @test length(t) == n ÷ 2

        # Verify remaining keys
        for k in 2:2:n
            @test haskey(t, k)
        end
        for k in 1:2:n
            @test !haskey(t, k)
        end
    end
end
