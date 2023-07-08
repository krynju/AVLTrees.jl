
@testset "tree.jl" begin

    @testset "root insertion test" begin
        t = AVLTree{Int64,Int64}()
        insert!(t, 1, 2)
        @test !isnothing(t.root)
        @test t.root.bf == 0
        @test isnothing(t.root.right) && isnothing(t.root.left)
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
        @test isnothing(t.root.left)
        @test t.root.bf == 1
        @test size(t) == 2
        AVLTrees.delete_node!(t, t.root.right)
        @test isnothing(t.root.right)
        @test t.root.bf == 0
        @test size(t) == 1
        AVLTrees.delete_node!(t, t.root)
        @test size(t) == 0
        @test isnothing(t.root)
    end

    @testset "fill and delete all test" begin
        t = AVLTree{Int64,Int64}()
        for i in rand(Int64, 100)
            insert!(t, i, 0)
        end
        @test size(t) <= 100
        while !isnothing(t.root)
            AVLTrees.delete_node!(t, t.root)
        end
        @test isnothing(t.root)
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
        @test isnothing(t.root)
    end

    @testset "getkey test" begin
        t = AVLTree{Int64,Int64}()
        for i = 1:1000
            insert!(t, i, i)
        end
        @test size(t) == 1000
        @test 500 == getkey(t, 500, nothing)
        @test nothing === getkey(t, 1001, nothing)
        @test size(t) == 1000
    end

    @testset "iteration test" begin
        t = AVLTree{Int64,Int64}()
        for i = 1:1000
            insert!(t, i, i)
        end
        s1 = Set{Tuple{Int64,Int64}}([(_x,_x) for _x in 1:1000])
        s2 = Set{Tuple{Int64,Int64}}()
        for i in t
            push!(s2,i)
        end
        @test s1 == s2
    end

    @testset "Base.*" begin
        t = AVLTree{Int64, Int64}()

        for i in 1:100
            insert!(t, i, i)
        end

        @test eltype(t) == Tuple{Int64, Int64}
        @test getindex.(Ref(t), 1:100) == 1:100
        try
            getindex(t, -100)
        catch x
            @test x == KeyError(-100)
        end
        setindex!(t, -10, 10)
        @test t[10] == -10
        @test haskey(t,10)
        @test !haskey(t,-10)
        @test length(t) == 100
        t[-10] = -10
        @test length(t) == 101
        @test !isempty(t)

        @test popfirst!(t) == -10
        @test firstindex(t) == 1
        t[10] = 10
        @test getproperty.(pop!.(Ref(t), 1:100), :data) == 1:100

    end
end
