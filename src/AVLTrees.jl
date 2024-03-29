module AVLTrees

import Base: iterate, haskey, getkey, getindex, setindex!, length, 
            eltype, isempty, insert!, popfirst!, insert!, delete!
            print, show, firstindex, pop!, popfirst!

include("node.jl")
include("tree.jl")
include("set.jl")

export AVLTree, AVLSet, findkey
end # module
