Base.eltype(::Type{AVLTree{K,V}}) where {K,V} = Tuple{K,V}

Base.length(t::AVLTree{K,V}) where {K,V} = __size(t.root)
Base.isempty(t::AVLTree{K,V}) where {K,V} = t.root === nothing
@inline __size(node::Node) = __size(node.left) + __size(node.right) + 1
@inline __size(node::Nothing) = return 0

@inline function Base.haskey(t::AVLTree{K,V}, k) where {K,V}
    typed_key = if k isa K
        k
    else
        try
            convert(K, k)
        catch e
            if e isa MethodError || e isa TypeError || e isa InexactError
                return false
            end
            rethrow()
        end
    end
    return find_node(t, typed_key) !== nothing
end
Base.in(k, t::AVLTree{K,V}) where {K,V} = haskey(t, k)

function Base.setindex!(tree::AVLTree{K,V}, v::V, k::K) where {K,V}
    insert!(tree, k, v)
    return v
end
function Base.setindex!(tree::AVLTree{K,V}, v::V, k::Any) where {K,V}
    insert!(tree, convert(K, k), v)
    return v
end

Base.insert!(tree::AVLTree{K,V}, k::K, v::V) where {K,V} = insert_node!(tree, k, v)

function Base.delete!(tree::AVLTree{K,V}, key) where {K,V}
    typed_key = if key isa K
        key
    else
        try
            convert(K, key)
        catch e
            if e isa MethodError || e isa TypeError || e isa InexactError
                return tree
            end
            rethrow()
        end
    end
    node = find_node(tree, typed_key)
    if node !== nothing
        delete_node!(tree, node)
    end
    return tree
end

function Base.get(t::AVLTree{K,V}, k, default) where {K,V}
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
    node = find_node(t, typed_key)
    if node === nothing
        return default
    else
        return node.data
    end
end

function Base.get(f::Function, t::AVLTree{K,V}, k::K) where {K,V}
    node = find_node(t, k)
    if node === nothing
        return f()
    else
        return node.data
    end
end

function Base.get!(t::AVLTree{K,V}, k, default) where {K,V}
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
    node = find_node(t, typed_key)
    if node === nothing
        insert!(t, typed_key, default)
        return default
    else
        return node.data
    end
end

function Base.get!(f::Function, t::AVLTree{K,V}, k) where {K,V}
    typed_key = if k isa K
        k
    else
        try
            convert(K, k)
        catch e
            if e isa MethodError || e isa TypeError || e isa InexactError
                return f()
            end
            rethrow()
        end
    end
    node = find_node(t, typed_key)
    if node === nothing
        d = f()
        insert!(t, typed_key, d)
        return d
    else
        return node.data
    end
end

function Base.getindex(t::AVLTree{K,V}, k) where {K,V}
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
    node = find_node(t, typed_key)
    if node === nothing
        throw(KeyError(k))
    else
        return node.data
    end
end

function Base.getkey(t::AVLTree{K,V}, k, default) where {K,V}
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
    node = find_node(t, typed_key)
    if node === nothing
        return default
    else
        return node.key
    end
end

function Base.iterate(t::AVLTree)
    if isempty(t)
        return nothing
    end
    node = t.root
    while node.left !== nothing
        node = node.left
    end
    return (node.key, node.data), node
end

function Base.iterate(::AVLTree, node::Node)
    if node.right !== nothing
        node = node.right
        while node.left !== nothing
            node = node.left
        end
    else
        prev = node
        while node !== nothing && node.left !== prev
            prev = node
            node = node.parent
        end
    end

    if node === nothing
        return nothing
    end

    return (node.key, node.data), node
end

function Base.popfirst!(t::AVLTree)
    if isempty(t)
        throw(ArgumentError("Tree must be non-empty"))
    end
    node = t.root
    while node.left !== nothing
        node = node.left
    end
    node_data = node.data
    delete_node!(t, node)
    return node_data
end

function Base.pop!(t::AVLTree{K,V}) where {K,V}
    node = t.root
    node === nothing && throw(ArgumentError("Tree must be non-empty"))
    while node.right !== nothing
        node = node.right
    end
    temp = node.data
    delete_node!(t, node)
    return temp
end

function Base.pop!(t::AVLTree{K,V}, k) where {K,V}
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
    node = find_node(t, typed_key)
    if node !== nothing
        saved_data = node.data
        delete_node!(t, node)
        return saved_data
    else
        throw(KeyError(k))
    end
end

function Base.pop!(t::AVLTree{K,V}, k, default) where {K,V}
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
    node = find_node(t, typed_key)
    if node !== nothing
        saved_data = node.data
        delete_node!(t, node)
        return saved_data
    else
        return default
    end
end

function Base.firstindex(t::AVLTree)
    if isempty(t)
        throw(ArgumentError("Tree must be non-empty"))
    end
    node = t.root
    while node.left !== nothing
        node = node.left
    end
    return node.key
end

function Base.print(io::IO, t::AVLTree{K,V}) where {K,V}
    str_lst = Vector{String}()
    for (k, v) in Base.Iterators.take(t, 10)
        push!(str_lst, "$k => $v")
    end
    print(io, "AVLTree{$K,$V}(")
    print(io, join(str_lst, ", "))
    length(str_lst) == 10 && print(io, ", ⋯ ")
    return print(io, ")")
end

function printtree(io::IO, t::AVLTree{K,V}) where {K,V}
    str_lst = Vector{String}()
    indent_str = "  "
    for (k, v) in Base.Iterators.take(t, 10)
        push!(str_lst, indent_str * "$k => $v")
    end
    if length(str_lst) > 0
        print(io, "AVLTree{$K,$V} with $(length(t)) entries:\n")
        print(io, join(str_lst, "\n"))
    else
        print(io, "AVLTree{$K,$V}()")
    end
    return length(str_lst) == 10 && print(io, "\n", indent_str * "⋮ => ⋮ \n")
end

function Base.show(io::IO, ::MIME"text/plain", t::AVLTree{K,V}) where {K,V}
    return printtree(io, t)
end
