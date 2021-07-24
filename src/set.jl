import Base: union, union!, setdiff, setdiff!, intersect!, intersect

struct AVLSet{K} <: AbstractSet{K}
    tree::AVLTree{K,Nothing}
end

AVLSet() = AVLSet{Any}(AVLTree{Any,Nothing}())
AVLSet{K}() where {K} = AVLSet{K}(AVLTree{K,Nothing}())

function AVLSet(x::K) where {K <: AbstractVector}
    t = AVLTree{eltype(x),Nothing}()
    for i in x
        insert!(t, i, nothing)
    end
    return AVLSet{eltype(x)}(t)
end

Base.eltype(::Type{AVLSet{K}}) where {K} = K
Base.length(set::AVLSet) = length(set.tree) 
Base.in(x::K, set::AVLSet{K}) where {K} = !isnothing(find_node(set.tree, x)) 

function iterate(set::AVLSet{K}) where {K}
    ret = iterate(set.tree)
    if isnothing(ret) return nothing else return (ret[1][1], ret[2])  end
end

function iterate(set::AVLSet{K}, node::Node{K,Nothing}) where {K}
    ret = iterate(set.tree, node)
    if isnothing(ret) return nothing else return (ret[1][1], ret[2])  end
end

Base.push!(set::AVLSet{K}, item::K) where {K} = insert!(set.tree, item, nothing)

Base.delete!(set::AVLSet{K}, item) where {K} = delete!(set.tree, item)

Base.union(set::AVLSet{K}, sets...) where {K} = union!(deepcopy(set), sets...)

function Base.union!(set::AVLSet{K}, sets...) where {K} 
    (key -> push!.(Ref(set), key)).(sets)
    return set
end


Base.setdiff(set::AVLSet{K}, sets...) where {K} = setdiff!(deepcopy(set), sets...)

function Base.setdiff!(set::AVLSet{K}, sets...) where {K} 
    (key -> delete!.(Ref(set), key)).(sets)
    return set
end

Base.intersect(set::AVLSet{K}, s::AbstractSet) where {K} = intersect!(deepcopy(set), s)

function Base.intersect!(set::AVLSet{K}, s::AbstractSet) where {K}
    _set = collect(set)
    for key in _set
        if key ∉ s
            delete!(set, key)
        end
    end
    return set
end
