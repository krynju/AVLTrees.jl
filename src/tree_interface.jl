Base.eltype(::Type{AVLTree{K, V}}) where {K, V} = Tuple{K, V}

Base.length(t::AVLTree{K, V}) where {K, V} = size(t)
Base.isempty(t::AVLTree{K, V}) where {K, V} = t.root === nothing
Base.size(t::AVLTree) = __size(t.root)
@inline __size(node::Node) = __size(node.left) + __size(node.right) + 1
@inline __size(node::Nothing) = return 0

@inline function Base.haskey(t::AVLTree{K, V}, k::K) where {K, V}
    node = t.root
    while node !== nothing
        if k < node.key
            node = node.left
        elseif k > node.key
            node = node.right
        else
            return true
        end
    end
    return false
end
Base.in(k::K, t::AVLTree{K, V}) where {K, V} = haskey(t, k)

Base.setindex!(tree::AVLTree{K, V}, v::V, k::K) where {K, V} = insert!(tree, k, v)
Base.setindex!(tree::AVLTree{K, V}, v::V, k::Any) where {K, V} = insert!(tree, convert(K, k), v)

Base.insert!(tree::AVLTree{K, V}, k::K, v::V) where {K, V} = insert_node!(tree, k, v)

function Base.delete!(tree::AVLTree{K, V}, key::K) where {K, V}
    node = find_node(tree, key)
    if node !== nothing
        delete_node!(tree, node)
    end
    return tree
end

Base.get(t::AVLTree{K, V}, k, default) where {K, V} = getkey(t, k, default)

function Base.get(f::Function, t::AVLTree{K, V}, k::K) where {K, V}
    node = find_node(t, k)
    if node === nothing
        return f()
    else
        return node.data
    end
end

function Base.get!(t::AVLTree{K, V}, k::K, default) where {K, V}
    node = find_node(t, k)
    if node === nothing
        insert!(t, k, default)
        return default
    else
        return node.data
    end
end

function Base.get!(f::Function, t::AVLTree{K, V}, k::K) where {K, V}
    node = find_node(t, k)
    if node === nothing
        d = f()
        insert!(t, k, d)
        return d
    else
        return node.data
    end
end

function Base.getindex(t::AVLTree{K, V}, k::K) where {K, V}
    node = find_node(t, k)
    if node === nothing
        throw(KeyError(k))
    else
        return node.data
    end
end

function Base.getkey(t::AVLTree{K, V}, k::T, default) where {K, V, T}
    T !== K && return default
    node = find_node(t, k)
    if node === nothing
        return default
    else
        return node.data
    end
end

function Base.getkey(t::AVLTree{K, V}, k::K, default) where {K, V}
    node = find_node(t, k)
    if node === nothing
        return default
    else
        return node.data
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
        while node !== nothing && node.left != prev
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

function Base.pop!(t::AVLTree{K, V}) where {K, V}
    node = t.root
    node === nothing && ArgumentError("Tree must be non-empty")
    while node !== nothing
        node = node.right
    end
    temp = node
    delete_node!(t, node)
    return temp
end

function Base.pop!(t::AVLTree{K, V}, k::K) where {K, V}
    if isempty(t)
        throw(ArgumentError("Tree must be non-empty"))
    end
    node = find_node(t, k)

    if node !== nothing
        temp = node
        delete_node!(t, node)
        return temp
    else
        throw(KeyError("Key doesn't exist"))
    end
end

function Base.pop!(t::AVLTree{K, V}, k::K, default) where {K, V}
    node = find_node(t, k)
    if node !== nothing
        temp = node
        delete_node!(t, node)
        return temp
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


function Base.print(io::IO, t::AVLTree{K, V}) where {K, V}
    str_lst = Vector{String}()
    for (k, v) in Base.Iterators.take(t, 10)
        push!(str_lst, "$k => $v")
    end
    print(io, "AVLTree{$K,$D}(")
    print(io, join(str_lst, ", "))
    length(str_lst) == 10 && print(io, ", ⋯ ")
    print(io, ")")
end

function printtree(io::IO, t::AVLTree{K, V}) where {K, V}
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
    length(str_lst) == 10 && print(io, "\n", indent_str * "⋮ => ⋮ \n")
end

function Base.show(io::IO, ::MIME"text/plain", t::AVLTree{K, V}) where {K, V}
    printtree(io ,t )
end
