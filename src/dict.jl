struct AVLDict{K,D} <: AbstractDict{K,D}
    tree::AVLTree{K,D}

    function AVLDict{K,D}() where {K,D}
        return new(AVLTree{K,D}())
    end
    function AVLDict{K,D}(t::AVLTree{K,D}) where {K,D}
        return new(t)
    end
    function AVLDict{K,D}(d::AVLDict{K,D}) where {K,D}
        return new(deepcopy(d.tree))
    end
end

AVLDict() = AVLDict{Any,Any}()

function AVLDict(kv)
    try
        # Infer types from the eltype of the iterable
        if isa(kv, Union{AbstractArray,Tuple}) || Base.IteratorSize(typeof(kv)) isa Base.HasShape
            et = eltype(kv)
            if et <: Pair
                # Extract K, V from Pair{K,V}
                if isdefined(et, :parameters) && length(et.parameters) >= 2
                    K, V = et.parameters[1], et.parameters[2]
                    return AVLDict{K,V}(kv)
                end
            elseif et <: Tuple && isdefined(et, :parameters) && length(et.parameters) == 2
                # Extract K, V from Tuple{K,V}
                K, V = et.parameters[1], et.parameters[2]
                return AVLDict{K,V}(kv)
            end
        end
        # Fallback: collect and infer from actual values
        pairs = collect(kv)
        if isempty(pairs)
            return AVLDict{Any,Any}()
        end
        K, V = _promote_pair_types(pairs)
        return AVLDict{K,V}(pairs)
    catch e
        if !Base.isiterable(typeof(kv)) || !all(x -> isa(x, Union{Tuple,Pair}), kv)
            throw(ArgumentError("AVLDict(kv): kv needs to be an iterator of tuples or pairs"))
        else
            rethrow()
        end
    end
end
function AVLDict{K,V}(kv) where {K,V}
    h = AVLTree{K,V}()
    for (k, v) in kv
        h[k] = v
    end
    return AVLDict{K,V}(h)
end
AVLDict(::Tuple{}) = AVLDict()

# Helper function to promote types with Union support, matching Base Dict behavior
# Works with both Pairs and 2-tuples
function _promote_pair_types(ps)
    types_first = DataType[]
    types_second = DataType[]

    for item in ps
        if item isa Pair
            push!(types_first, typeof(item.first))
            push!(types_second, typeof(item.second))
        elseif item isa Tuple && length(item) == 2
            push!(types_first, typeof(item[1]))
            push!(types_second, typeof(item[2]))
        else
            throw(ArgumentError("_promote_pair_types: expected Pair or 2-tuple elements"))
        end
    end

    function _infer_type(types)
        unique_types = unique(types)
        if length(unique_types) == 1
            return unique_types[1]
        end
        # Use promote_typejoin just like Base Dict does
        return reduce(Base.promote_typejoin, unique_types)
    end

    return _infer_type(types_first), _infer_type(types_second)
end

function AVLDict(ps::Pair...)
    isempty(ps) && return AVLDict()
    K, V = _promote_pair_types(ps)
    return AVLDict{K,V}(ps...)
end

function AVLDict{K,V}(ps::Pair...) where {K,V}
    t = AVLTree{K,V}()
    for p in ps
        k = convert(K, p.first)
        d = convert(V, p.second)
        insert!(t, k, d)
    end
    return AVLDict{K,V}(t)
end

function AVLDict{K,V}(ps::Pair{K,V}...) where {K,V}
    t = AVLTree{K,V}()
    for (k, d) in ps
        insert!(t, k, d)
    end
    return AVLDict{K,V}(t)
end

Base.haskey(dict::AVLDict{K,D}, k) where {K,D} = haskey(dict.tree, k)

Base.get(dict::AVLDict{K,D}, k, default) where {K,D} = get(dict.tree, k, default)
Base.get(f::Function, dict::AVLDict{K,D}, k) where {K,D} = get(f, dict.tree, k)
Base.get!(dict::AVLDict{K,D}, k, default) where {K,D} = get!(dict.tree, k, default)
Base.get!(f::Function, dict::AVLDict{K,D}, k) where {K,D} = get!(f, dict.tree, k)

function Base.delete!(dict::AVLDict{K,D}, k) where {K,D}
    delete!(dict.tree, k)
    return dict
end

Base.getindex(dict::AVLDict{K,D}, k) where {K,D} = getindex(dict.tree, k)

function Base.getkey(dict::AVLDict{K,D}, k) where {K,D}
    typed_key = if k isa K
        k
    else
        try
            convert(K, k)
        catch e
            if e isa MethodError || e isa TypeError || e isa InexactError
                throw(KeyError(k))
            end
            rethrow()
        end
    end
    node = find_node(dict.tree, typed_key)
    node === nothing && throw(KeyError(k))
    return node.key
end

Base.getkey(dict::AVLDict{K,D}, k, default) where {K,D} = getkey(dict.tree, k, default)
Base.isempty(dict::AVLDict) = isempty(dict.tree)
Base.length(dict::AVLDict) = length(dict.tree)

function Base.setindex!(dict::AVLDict{K,D}, d::D, k) where {K,D}
    setindex!(dict.tree, d, k)
    return d
end

function Base.push!(dict::AVLDict{K,D}, p::Pair) where {K,D}
    dict[p.first] = p.second
    return dict
end

function Base.push!(dict::AVLDict{K,D}, p::Pair, q::Pair...) where {K,D}
    push!(dict, p)
    for pair in q
        push!(dict, pair)
    end
    return dict
end

function Base.pop!(dict::AVLDict{K,D}) where {K,D}
    node = dict.tree.root
    node === nothing && throw(ArgumentError("dict must be non-empty"))
    while node.right !== nothing
        node = node.right
    end
    saved_key = node.key
    saved_data = node.data
    delete_node!(dict.tree, node)
    return saved_key => saved_data
end

function Base.pop!(dict::AVLDict{K,D}, k) where {K,D}
    typed_key = if k isa K
        k
    else
        try
            convert(K, k)
        catch e
            if e isa MethodError || e isa TypeError || e isa InexactError
                throw(KeyError(k))
            end
            rethrow()
        end
    end
    node = find_node(dict.tree, typed_key)
    node === nothing && throw(KeyError(k))
    saved_data = node.data
    delete_node!(dict.tree, node)
    return saved_data
end

function Base.pop!(dict::AVLDict{K,D}, k, default) where {K,D}
    typed_key = if k isa K
        k
    else
        try
            convert(K, k)
        catch e
            if e isa MethodError || e isa TypeError || e isa InexactError
                return default
            end
            rethrow()
        end
    end
    node = find_node(dict.tree, typed_key)
    if node === nothing
        return default
    end
    saved_data = node.data
    delete_node!(dict.tree, node)
    return saved_data
end

function Base.iterate(dict::AVLDict)
    ret = iterate(dict.tree)
    if ret === nothing
        return nothing
    else
        return (ret[1][1] => ret[1][2], ret[2])
    end
end

function Base.iterate(dict::AVLDict, state)
    ret = iterate(dict.tree, state)
    if ret === nothing
        return nothing
    else
        return (ret[1][1] => ret[1][2], ret[2])
    end
end

function Base.show(io::IO, ::MIME"text/plain", t::AVLDict)
    return printtree(io, t.tree)
end

function Base.sizehint!(d::AVLDict, sz)
    return d
end

Base.copy(d::AVLDict{K,D}) where {K,D} = AVLDict{K,D}(deepcopy(d.tree))

function Base.copy!(dest::AVLDict{K,D}, src::AVLDict{K,D}) where {K,D}
    empty_tree!(dest.tree)
    for (k, v) in src
        dest[k] = v
    end
    return dest
end

function Base.similar(d::AVLDict{K,D}) where {K,D}
    return AVLDict{K,D}()
end

function Base.similar(d::AVLDict{K,D}, ::Type{K2}, ::Type{D2}) where {K,D,K2,D2}
    return AVLDict{K2,D2}()
end

Base.empty(d::AVLDict{K,D}) where {K,D} = AVLDict{K,D}()
Base.empty(::Type{AVLDict{K,D}}) where {K,D} = AVLDict{K,D}()

function Base.empty!(d::AVLDict{K,D}) where {K,D}
    empty_tree!(d.tree)
    return d
end

function Base.:(==)(d1::AVLDict, d2::AVLDict)
    if length(d1) != length(d2)
        return false
    end
    has_missing = false
    for (k, v) in d1
        if !haskey(d2, k)
            return false
        end
        eq = d2[k] == v
        if eq === false
            return false
        elseif eq === missing
            has_missing = true
        elseif eq !== true
            return false
        end
    end
    return has_missing ? missing : true
end

function Base.isequal(d1::AVLDict, d2::AVLDict)
    if length(d1) != length(d2)
        return false
    end
    for (k, v) in d1
        if !haskey(d2, k) || !isequal(d2[k], v)
            return false
        end
    end
    return true
end

# merge and mergewith implementations
function Base.merge(d::AVLDict{K,D}, others::AbstractDict...) where {K,D}
    result = copy(d)
    for other in others
        for (k, v) in other
            result[k] = v
        end
    end
    return result
end

function Base.merge(combine::Function, d::AVLDict{K,D}, others::AbstractDict...) where {K,D}
    result = copy(d)
    for other in others
        for (k, v) in other
            if haskey(result, k)
                result[k] = combine(result[k], v)
            else
                result[k] = v
            end
        end
    end
    return result
end

function mergewith(combine::Function, d::AVLDict{K,D}, others::AbstractDict...) where {K,D}
    return merge(combine, d, others...)
end

function mergewith!(combine::Function, d::AVLDict{K,D}, others::AbstractDict...) where {K,D}
    for other in others
        for (k, v) in other
            if haskey(d, k)
                d[k] = combine(d[k], v)
            else
                d[k] = v
            end
        end
    end
    return d
end
