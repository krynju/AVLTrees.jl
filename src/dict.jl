struct AVLDict{K,D} <: AbstractDict{K,D}
    tree::AVLTree{K,D}
end

AVLDict() = AVLDict{Any,Any}(AVLTree{Any,Any}())
AVLDict{K,D}() where {K,D} = AVLDict{K,D}(AVLTree{K,D}())

function AVLDict(x::V) where {V <: AbstractVector}
    @assert eltype(x) <: Pair
    keytype = eltype(x).types[1]
    datatype = eltype(x).types[2]

    t = AVLTree{keytype,datatype}()
    for (k,d) in x
        insert!(t, k, d)
    end
    return AVLDict{keytype,datatype}(t)
end

Base.haskey(dict::AVLDict{K,D}, key::K) where {K,D} = find_node(dict.tree, key) !== nothing

# TODO: probably move the logic to tree?
function Base.get(dict::AVLDict{K,D}, key::K, default) where {K,D} 
    node = find_node(dict.tree, key)
    node === nothing ? default : node.data
end

function Base.get!(dict::AVLDict{K,D}, key::K, default) where {K,D} 
    node = find_node(dict.tree, key)
    node === nothing && insert!(dict.tree, key, default)
    return default
end