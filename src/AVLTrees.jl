module AVLTrees

import Base:
    copy,
    copy!,
    delete!,
    eltype,
    empty,
    empty!,
    firstindex,
    get,
    get!,
    getindex,
    getkey,
    haskey,
    insert!,
    insert!,
    isequal,
    isempty,
    iterate,
    last,
    length,
    merge,
    mergewith,
    mergewith!,
    pop!,
    popfirst!,
    popfirst!,
    print,
    setindex!,
    show,
    similar,
    sizehint!,
    ==

include("node.jl")
include("tree.jl")
include("tree_interface.jl")
include("set.jl")
include("dict.jl")

export AVLTree, AVLSet, AVLDict

end
