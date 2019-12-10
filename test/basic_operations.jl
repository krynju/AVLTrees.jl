
@testset "basic operations" begin
    # root insertion test
    let
        t = AVLTree{Int,Int}()
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
        t = AVLTree{Int,Int}()
        insert!(t, 1, 2)
        insert!(t, 2, 2)
        insert!(t, 3, 2)
        @test t.root.bf == 0
        @test t.root.left.bf == 0
        @test t.root.right.bf == 0
    end

    # left rotation test
    let
        t = AVLTree{Int,Int}()
        insert!(t, 3, 2)
        insert!(t, 2, 2)
        insert!(t, 1, 2)
        @test t.root.bf == 0
        @test t.root.left.bf == 0
        @test t.root.right.bf == 0
    end

    # fill test
    let
        t = AVLTree{Float64,Int}()
        for i in randn(100)
            insert!(t, i, 0)
        end
    end

    # erase basic
    let
        t = AVLTree{Int,Int}()
        insert!(t, 1, 2)
        insert!(t, 2, 2)
        insert!(t, 3, 2)
        erase!(t, t.root.left)
        @test t.root.left == nothing
        @test t.root.bf == 1
        erase!(t, t.root.right)
        @test t.root.right == nothing
        @test t.root.bf == 0
        erase!(t, t.root)
        @test t.root == nothing
    end

    # fill and erase test
    let
        t = AVLTree{Float64,Int}()
        for i in randn(1000)
            insert!(t, i, 0)
        end
        while t.root != nothing
            erase!(t, t.root)
        end
        @test t.root == nothing
    end

    # find test

    let
        t = AVLTree{Int,Int}()
        for i = 1:1000
            insert!(t,i,i)
        end
        res = find(t, 500)
        @test 500 == res[1] && 500 == res[2]
        @test nothing == find(t,1001)
    end
end
