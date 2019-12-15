
@testset "basic operations" begin
    # root insertion test
    let
        t = AVLTree{Int64,Int64}()
        insert!(t, 1, 2)
        @test t.root != nothing
        @test t.root.bf == 0
        @test t.root.right == nothing
        @test t.root.left == nothing
        @test t.root.key == 1
        @test t.root.data == 2
        insert!(t, 1, 10)
        @test t.root.data == 10
    end


    # left rotation test
    let
        t = AVLTree{Int64,Int64}()
        insert!(t, 1, 2)
        insert!(t, 2, 2)
        insert!(t, 3, 2)
        @test t.root.bf == 0 && t.root.left.bf == 0 && t.root.right.bf == 0
        @test t.root.key == 2 && t.root.left.key == 1 && t.root.right.key == 3
    end

    # right rotation test
    let
        t = AVLTree{Int64,Int64}()
        insert!(t, 3, 2)
        insert!(t, 2, 2)
        insert!(t, 1, 2)
        @test t.root.bf == 0 && t.root.left.bf == 0 && t.root.right.bf == 0
        @test t.root.key == 2 && t.root.left.key == 1 && t.root.right.key == 3
    end

    # left-right rotation test
    let
        t = AVLTree{Int64,Int64}()
        insert!(t, 3, 2)
        insert!(t, 1, 2)
        insert!(t, 2, 2)
        @test t.root.bf == 0 && t.root.left.bf == 0 && t.root.right.bf == 0
        @test t.root.key == 2 && t.root.left.key == 1 && t.root.right.key == 3
    end

    # right-left rotation test
    let
        t = AVLTree{Int64,Int64}()
        insert!(t, 1, 2)
        insert!(t, 3, 2)
        insert!(t, 2, 2)
        @test t.root.bf == 0 && t.root.left.bf == 0 && t.root.right.bf == 0
        @test t.root.key == 2 && t.root.left.key == 1 && t.root.right.key == 3
    end

    # tree{Any,Any} test - TODO breaks - conversion errors
    # let
    #     t = AVLTree()
    #     insert!(t, "item1", "item1")
    #     @test t.root.key == "item1"
    #     insert!(t, "item2", "item2")
    #     insert!(t, "item3", "item3")
    #     @test t.root.key == "item2"
    # end

    # fill test
    let
        t = AVLTree{Int64,Int64}()
        for i in rand(Int64, 100)
            insert!(t, i, 0)
        end
    end

    # erase basic
    let
        t = AVLTree{Int64,Int64}()
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

    # fill and erase all test
    let
        t = AVLTree{Int64,Int64}()
        for i in rand(Int64, 100)
            insert!(t, i, 0)
        end
        while t.root != nothing
            erase!(t, t.root)
        end
        @test t.root == nothing
    end

    # fill and erase keys test
    let
        t = AVLTree{Int64,Int64}()
        nums = rand(Int64, 100)
        for i in nums
            insert!(t, i, i)
        end
        for i in nums
            erase!(t, i)
        end
        @test t.root == nothing
    end

    # find test
    let
        t = AVLTree{Int64,Int64}()
        for i = 1:1000
            insert!(t, i, i)
        end
        res = find(t, 500)
        @test 500 == res[1] && 500 == res[2]
        @test nothing == find(t, 1001)
    end
end
