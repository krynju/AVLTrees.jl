using AVLTrees
using Test

@testset "AVLTrees.jl" begin
    include("node.jl")
    include("tree.jl")
    include("set.jl")
    include("base_dict.jl")
end
