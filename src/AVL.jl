module AVL

import AbstractTrees: children, printnode
import Base: insert!, delete!, size

include("node.jl")
include("tree.jl")

export AVLTree, insert!, delete!, findkey, size
end # module
