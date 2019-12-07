
@testset "basic operations" begin
    # root insertion test
    let
        t = AVLTree{Int,Int}(nothing)
        insert!(t, 1, 2)
        @test t.root != nothing
        @test t.root.bf == 0
        @test t.root.right == nothing
        @test t.root.left == nothing
        @test t.root.key == 1
        @test t.root.data == 2
    end


    # left rotation test
    let
        t = AVLTree{Int,Int}(nothing)
        insert!(t, 1, 2)
        insert!(t, 2, 2)
        insert!(t, 3, 2)
        @test t.root.bf == 0
        @test t.root.left.bf == 0
        @test t.root.right.bf == 0
    end

    # left rotation test
    let
        t = AVLTree{Int,Int}(nothing)
        insert!(t, 3, 2)
        insert!(t, 2, 2)
        insert!(t, 1, 2)
        @test t.root.bf == 0
        @test t.root.left.bf == 0
        @test t.root.right.bf == 0
    end

    # fill test
    let
        t = AVLTree{Float64,Int}(nothing)
        for i in randn(100)
            insert!(t, i, 0)
        end
    end
end
