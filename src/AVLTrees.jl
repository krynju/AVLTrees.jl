module AVLTrees

import Base: iterate, haskey, getkey, getindex, setindex!, length,
            eltype, isempty, insert!, popfirst!, insert!, delete!
            print, show, firstindex, pop!, popfirst!, get, get!

include("node.jl")
include("tree.jl")
include("tree_interface.jl")
include("set.jl")
include("dict.jl")

export AVLTree, AVLSet, AVLDict

end
