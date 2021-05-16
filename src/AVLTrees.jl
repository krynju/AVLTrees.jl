module AVLTrees

using Base: iterate, haskey, getkey, getindex, setindex!, length, 
            eltype, isempty, insert!, popfirst!, insert!, delete!
            first_index, size

include("node.jl")
include("tree.jl")
include("set.jl")

export AVLTree, AVLSet, findkey
end # module
