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

Base.haskey(dict::AVLDict{K,D}, k::K) where {K,D} = haskey(dict.tree, k)

Base.get(dict::AVLDict{K,D}, k::K, default) where {K,D} = get(dict.tree, k, default)
Base.get(f::Function, dict::AVLDict{K,D}, k::K) where {K,D} = get(f, dict.tree, k)
Base.get!(dict::AVLDict{K,D}, k::K, default) where {K,D} = get!(dict.tree, k, default)
Base.get!(f::Function, dict::AVLDict{K,D}, k::K) where {K,D} = get!(f, dict.tree, k)

Base.delete!(dict::AVLDict{K,D}, k::K) where {K,D} = delete(dict.tree, k)

Base.getindex(dict::AVLDict{K,D}, k::K) where {K,D} = getindex(dict.tree, k)

Base.getkey(dict::AVLDict{K,D}, k::K) where {K,D} = getkey(dict.tree, k)
Base.isempty(dict::AVLDict) = isempty(dict.tree)
Base.length(dict::AVLDict) = length(dict.tree)

Base.setindex!(dict::AVLDict{K,D}, d::D, k::K) where {K,D} = setindex!(dict.tree, d, k)
Base.empty!(dict::AVLDict) = empty_tree!(dict.tree)

function Base.pop!(dict::AVLDict{K, D}) where {K, D}
    node = pop!(dict.tree)
    node.key => node.data
end

function Base.pop!(dict::AVLDict{K, D}, k::K) where {K, D}
    node = pop!(dict.tree, k)
    k => node.data
end

function Base.pop!(dict::AVLDict{K, D}, k::K, default) where {K, D}
    node = pop!(dict.tree, k, default)
    if node isa Node
        k => node.data
    else
        default
    end
end

Base.iterate(dict::AVLDict) = iterate(dict.tree)
Base.iterate(dict::AVLDict, state) = iterate(dict.tree, state)

# [10] copy(d::Dict) in Base at dict.jl:120
# [13] filter!(pred, h::Dict{K, V}) where {K, V} in Base at dict.jl:703
# [25] mergewith!(combine, d1::Dict{K, V}, d2::AbstractDict) where {K, V} in Base at dict.jl:731