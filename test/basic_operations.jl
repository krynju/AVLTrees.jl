
@testset "basic operations" begin
    # root insertion test
    let
        t = AVLTree{Int64,Int64}()
        insert!(t, 1, 2)
        @test t.root != nothing
        @test t.root.bf == 0
        @test t.root.right == nothing && t.root.left == nothing
        @test t.root.key == 1 && t.root.data == 2
        @test size(t) == 1
        insert!(t, 1, 10)
        delete!(t, 999)
        @test t.root.data == 10
        @test size(t) == 1
    end


    # left rotation test
    let
        t = AVLTree{Int64,Int64}()
        insert!(t, 1, 2)
        insert!(t, 2, 2)
        insert!(t, 3, 2)
        @test t.root.bf == 0 && t.root.left.bf == 0 && t.root.right.bf == 0
        @test t.root.key == 2 && t.root.left.key == 1 && t.root.right.key == 3
        @test size(t) == 3
    end

    # right rotation test
    let
        t = AVLTree{Int64,Int64}()
        insert!(t, 3, 2)
        insert!(t, 2, 2)
        insert!(t, 1, 2)
        @test t.root.bf == 0 && t.root.left.bf == 0 && t.root.right.bf == 0
        @test t.root.key == 2 && t.root.left.key == 1 && t.root.right.key == 3
        @test size(t) == 3
    end

    # left-right rotation test
    let
        t = AVLTree{Int64,Int64}()
        insert!(t, 3, 2)
        insert!(t, 1, 2)
        insert!(t, 2, 2)
        @test t.root.bf == 0 && t.root.left.bf == 0 && t.root.right.bf == 0
        @test t.root.key == 2 && t.root.left.key == 1 && t.root.right.key == 3
        @test size(t) == 3
    end

    # right-left rotation test
    let
        t = AVLTree{Int64,Int64}()
        insert!(t, 1, 2)
        insert!(t, 3, 2)
        insert!(t, 2, 2)
        @test t.root.bf == 0 && t.root.left.bf == 0 && t.root.right.bf == 0
        @test t.root.key == 2 && t.root.left.key == 1 && t.root.right.key == 3
        @test size(t) == 3
    end

    # tree{Any,Any} test
    let
        t = AVLTree()
        insert!(t, "item1", "item1")
        @test t.root.key == "item1"
        insert!(t, "item2", "item2")
        insert!(t, "item3", "item3")
        @test t.root.key == "item2"
        @test size(t) == 3
    end

    # fill test
    let
        t = AVLTree{Int64,Int64}()
        for i in rand(Int64, 100)
            insert!(t, i, 0)
        end
        @test size(t) <= 100
    end

    # delete basic
    let
        t = AVLTree{Int64,Int64}()
        insert!(t, 1, 2)
        insert!(t, 2, 2)
        insert!(t, 3, 2)
        @test size(t) == 3
        delete!(t, t.root.left)
        @test t.root.left == nothing
        @test t.root.bf == 1
        @test size(t) == 2
        delete!(t, t.root.right)
        @test t.root.right == nothing
        @test t.root.bf == 0
        @test size(t) == 1
        delete!(t, t.root)
        @test size(t) == 0
        @test t.root == nothing
    end

    # fill and delete all test
    let
        t = AVLTree{Int64,Int64}()
        for i in rand(Int64, 100)
            insert!(t, i, 0)
        end
        @test size(t) <= 100
        while t.root != nothing
            delete!(t, t.root)
        end
        @test t.root == nothing
        @test size(t) == 0
    end

    # fill and delete keys test
    let
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
        @test t.root == nothing
    end

    # findkey test
    let
        t = AVLTree{Int64,Int64}()
        for i = 1:1000
            insert!(t, i, i)
        end
        @test size(t) == 1000
        @test 500 == findkey(t, 500)
        @test nothing == findkey(t, 1001)
        @test size(t) == 1000
    end

    #iteration test
    let
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
end
