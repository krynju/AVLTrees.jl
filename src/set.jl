import Base: union, union!, setdiff, setdiff!, intersect!, intersect

struct AVLSet{K} <: AbstractSet{K}
    tree::AVLTree{K,Nothing}
end

AVLSet() = AVLSet{Any}(AVLTree{Any,Nothing}())
AVLSet{K}() where {K} = AVLSet{K}(AVLTree{K,Nothing}())

function AVLSet(x::K) where {K<:AbstractVector}
    t = AVLTree{eltype(x),Nothing}()
    for i in x
        insert!(t, i, nothing)
    end
    return AVLSet{eltype(x)}(t)
end

Base.eltype(::Type{AVLSet{K}}) where {K} = K
Base.length(set::AVLSet) = length(set.tree)
Base.in(x::K, set::AVLSet{K}) where {K} = x in set.tree

function iterate(set::AVLSet{K}) where {K}
    ret = iterate(set.tree)
    if ret === nothing
        return nothing
    else
        return (ret[1][1], ret[2])
    end
end

function iterate(set::AVLSet{K}, node::Node{K,Nothing}) where {K}
    ret = iterate(set.tree, node)
    if ret === nothing
        return nothing
    else
        return (ret[1][1], ret[2])
    end
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
Base.copy(s::AVLSet{K}) where {K} = AVLSet{K}(deepcopy(s.tree))

function Base.copy!(dest::AVLSet{K}, src::AVLSet{K}) where {K}
    empty!(dest)
    for item in src
        push!(dest, item)
    end
    return dest
end

function Base.similar(s::AVLSet{K}) where {K}
    return AVLSet{K}()
end

function Base.similar(s::AVLSet{K}, ::Type{K2}) where {K,K2}
    return AVLSet{K2}()
end

Base.empty(s::AVLSet{K}) where {K} = AVLSet{K}()
Base.empty(::Type{AVLSet{K}}) where {K} = AVLSet{K}()

function Base.empty!(s::AVLSet{K}) where {K}
    empty_tree!(s.tree)
    return s
end

Base.last(s::AVLSet{K}) where {K} = popfirst!(deepcopy(s.tree))

function Base.:(==)(s1::AVLSet{K}, s2::AVLSet{K}) where {K}
    if length(s1) != length(s2)
        return false
    end
    for item in s1
        if !in(item, s2)
            return false
        end
    end
    return true
end

function Base.:(==)(s1::AVLSet, s2::AVLSet)
    if length(s1) != length(s2)
        return false
    end
    for item in s1
        if !in(item, s2)
            return false
        end
    end
    return true
end

function Base.isequal(s1::AVLSet{K}, s2::AVLSet{K}) where {K}
    if length(s1) != length(s2)
        return false
    end
    for item in s1
        if !in(item, s2)
            return false
        end
    end
    return true
end

function Base.isequal(s1::AVLSet, s2::AVLSet)
    if length(s1) != length(s2)
        return false
    end
    for item in s1
        if !in(item, s2)
            return false
        end
    end
    return true
end
