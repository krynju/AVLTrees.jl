using AVLTrees
using Test
using Random  # For randperm in tree tests

@testset "AVLTrees.jl" begin
    include("node.jl")
    include("tree.jl")
    include("set.jl")
    include("base_dict.jl")
end
