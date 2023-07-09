module AVLTrees

import Base:
    delete!,
    eltype,
    firstindex,
    get,
    get!,
    getindex,
    getkey,
    haskey,
    insert!,
    insert!,
    isempty,
    iterate,
    length,
    pop!,
    popfirst!,
    popfirst!,
    print,
    setindex!,
    show,
    sizehint!

include("node.jl")
include("tree.jl")
include("tree_interface.jl")
include("set.jl")
include("dict.jl")

export AVLTree, AVLSet, AVLDict

end
