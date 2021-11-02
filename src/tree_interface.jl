Base.eltype(::Type{AVLTree{K,D}}) where {K,D} = Tuple{K,D}

Base.length(t::AVLTree{K,D}) where {K,D} = size(t)
Base.isempty(t::AVLTree{K,D}) where {K,D} = t.root === nothing
Base.size(t::AVLTree) = __size(t.root)
@inline __size(node::Node) = __size(node.left) + __size(node.right) + 1
@inline __size(node::Nothing) = return 0

@inline function Base.haskey(t::AVLTree{K,D}, k::K) where {K,D}
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
Base.in(k::K, t::AVLTree{K,D}) where {K,D} = haskey(t, k)

Base.setindex!(tr::AVLTree{K,D}, d::D, k::K) where {K,D} = insert!(tr, k, d)
Base.setindex!(tr::AVLTree{K,D}, d::D, k::Any) where {K,D} = insert!(tr, convert(K, k), d)

Base.get(t::AVLTree{K,D}, k::K, default) where {K,D} = getkey(t, k, default)

function Base.get(f::Function, t::AVLTree{K,D}, k::K) where {K,D}
    node = find_node(t, k)
    if node === nothing
        return f()
    else
        return node.data
    end
end

function Base.get!(t::AVLTree{K,D}, k::K, default) where {K,D}
    node = find_node(t, k)
    if node === nothing
        insert!(t, k, default)
        return default
    else
        return node.data
    end
end

function Base.get!(f::Function, t::AVLTree{K,D}, k::K) where {K,D}
    node = find_node(t, k)
    if node === nothing
        d = f()
        insert!(t, k, d)
        return d
    else
        return node.data
    end
end

function Base.getindex(t::AVLTree{K,D}, k::K) where {K,D}
    node = find_node(t, k)
    if node === nothing
        throw(KeyError(k))
    else
        return node.data
    end
end

function Base.getkey(t::AVLTree{K,D}, k::K, default) where {K,D} 
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


function Base.iterate(t::AVLTree, node::Node)
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
    delete!(t, node)
    return node_data
end

function Base.pop!(t::AVLTree{K,D}, k::K) where {K,D}
    if isempty(t)
        throw(ArgumentError("Tree must be non-empty"))
    end
    node = AVLTrees.find_node(t, k)
    if node !== nothing
        node_dat = node.data
        delete!(t, node)
        return node_dat
    else
        throw(ArgumentError("Tree must be non-empty"))
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


function Base.print(io::IO, t::AVLTree{K,D}) where {K,D}
    str_lst = Vector{String}()
    for (k, v) in Base.Iterators.take(t, 10)
        push!(str_lst, "$k => $v")
    end
    print(io, "AVLTree{$K,$D}(")
    print(io, join(str_lst, ", "))
    length(str_lst) == 10 && print(io, ", ⋯ ")
    print(io, ")")
end


function Base.show(io::IO, ::MIME"text/plain", t::AVLTree{K,D}) where {K,D}
    str_lst = Vector{String}()
    indent_str = "  "
    for (k, v) in Base.Iterators.take(t, 10)
        push!(str_lst, indent_str * "$k => $v")
    end
    if length(str_lst) > 0
        print(io, "AVLTree{$K,$D} with $(length(t)) entries:\n")
        print(io, join(str_lst, "\n"))
    else
        print(io, "AVLTree{$K,$D}()")
    end
    length(str_lst) == 10 && print(io, "\n", indent_str * "⋮ => ⋮ \n")
end
