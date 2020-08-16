module AVLTrees

import Base: insert!, delete!, size, iterate, eltype, length

include("node.jl")
include("tree.jl")
include("set.jl")

export AVLTree, AVLSet, insert!, delete!, findkey, size
end # module
