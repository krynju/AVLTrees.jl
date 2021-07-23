@testset "node" begin
    @testset "constructors" begin
        n = AVLTrees.Node(10, 10)
        @test n.key == 10
        @test n.data == 10
        @test isnothing(n.parent)

        n1 = AVLTrees.Node(12, 12, n)
        @test n1.parent == n
        @test isnothing(n1.parent.parent)
    end
end