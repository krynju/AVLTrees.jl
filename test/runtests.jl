using AVL
using Test

@testset "AVL.jl" begin
    # Write your own tests here.

    t=AVLTree{Int,Int}(nothing)
    insert!(t,1,2)
    insert!(t,2,2)
    insert!(t,3,2)
    t.root.bf = 2
    t.root.right.bf = 1
    AVL.rotate_left(t, t.root)

    @test t.root.bf == 0
    @test t.root.left.bf == 0
    @test t.root.right.bf == 0


    t=AVLTree{Int,Int}(nothing)
    insert!(t,3,2)
    insert!(t,2,2)
    insert!(t,1,2)
    t.root.bf = -2
    t.root.left.bf = -1
    AVL.rotate_right(t, t.root)

end
