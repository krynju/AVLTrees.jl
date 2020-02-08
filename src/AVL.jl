module AVLTree

import Base: insert!, delete!, size, iterate, eltype, length

include("node.jl")
include("tree.jl")

export AVLTree, insert!, delete!, findkey, size
end # module
