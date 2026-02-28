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

function AVLSet(xs)
    if !Base.isiterable(typeof(xs))
        throw(ArgumentError("AVLSet(xs): xs needs to be iterable"))
    end

    if Base.IteratorEltype(typeof(xs)) isa Base.HasEltype
        K = eltype(xs)
        if K === Union{}
            return AVLSet{Any}()
        end
        s = AVLSet{K}()
        for item in xs
            push!(s, item)
        end
        return s
    end

    first_item = iterate(xs)
    if first_item === nothing
        return AVLSet{Any}()
    end

    item, state = first_item
    s = AVLSet{typeof(item)}()
    push!(s, item)

    while true
        next_item = iterate(xs, state)
        if next_item === nothing
            return s
        end
        item, state = next_item
        push!(s, item)
    end
end

Base.eltype(::Type{AVLSet{K}}) where {K} = K
Base.length(set::AVLSet) = length(set.tree)
function Base.in(x, set::AVLSet{K}) where {K}
    try
        return haskey(set.tree, convert(K, x))
    catch e
        if e isa MethodError || e isa TypeError || e isa InexactError
            return false
        end
        rethrow()
    end
end

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

function Base.push!(set::AVLSet{K}, item) where {K}
    insert!(set.tree, convert(K, item), nothing)
    return set
end

function Base.delete!(set::AVLSet{K}, item) where {K}
    try
        delete!(set.tree, convert(K, item))
    catch e
        if !(e isa MethodError || e isa TypeError || e isa InexactError)
            rethrow()
        end
    end
    return set
end

Base.union(set::AVLSet{K}, sets...) where {K} = union!(deepcopy(set), sets...)

function Base.union!(set::AVLSet{K}, sets...) where {K}
    for s in sets
        for key in s
            push!(set, key)
        end
    end
    return set
end

Base.setdiff(set::AVLSet{K}, sets...) where {K} = setdiff!(deepcopy(set), sets...)

function Base.setdiff!(set::AVLSet{K}, sets...) where {K}
    for s in sets
        for key in s
            delete!(set, key)
        end
    end
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

function Base.filter!(f, set::AVLSet{K}) where {K}
    items = collect(set)
    for item in items
        if !f(item)
            delete!(set, item)
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

function Base.last(s::AVLSet{K}) where {K}
    if isempty(s)
        throw(ArgumentError("set must be non-empty"))
    end

    node = s.tree.root
    while node.right !== nothing
        node = node.right
    end
    return node.key
end

function Base.pop!(set::AVLSet{K}) where {K}
    if isempty(set)
        throw(ArgumentError("set must be non-empty"))
    end
    item = first(set)
    delete!(set, item)
    return item
end

function Base.pop!(set::AVLSet{K}, item) where {K}
    converted_item = try
        convert(K, item)
    catch e
        if e isa MethodError || e isa TypeError || e isa InexactError
            throw(KeyError(item))
        end
        rethrow()
    end

    if in(converted_item, set)
        delete!(set, converted_item)
        return converted_item
    end
    throw(KeyError(item))
end

function Base.pop!(set::AVLSet{K}, item, default) where {K}
    converted_item = try
        convert(K, item)
    catch e
        if e isa MethodError || e isa TypeError || e isa InexactError
            return default
        end
        rethrow()
    end

    if in(converted_item, set)
        delete!(set, converted_item)
        return converted_item
    end
    return default
end

function _set_equal(s1::AVLSet, s2::AVLSet)
    if length(s1) != length(s2)
        return false
    end
    for item in s1
        if !haskey(s2.tree, item)
            return false
        end
    end
    return true
end

Base.:(==)(s1::AVLSet, s2::AVLSet) = _set_equal(s1, s2)
Base.isequal(s1::AVLSet, s2::AVLSet) = _set_equal(s1, s2)
