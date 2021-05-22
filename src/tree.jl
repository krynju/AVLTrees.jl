
"""
    AVLTree

struct
"""
mutable struct AVLTree{K,D}
    root::Union{Node{K,D},Nothing}
end

AVLTree() = AVLTree{Any,Any}(nothing)
AVLTree{K,D}() where {K,D} = AVLTree{K,D}(nothing)

Base.eltype(::Type{AVLTree{K,D}}) where {K,D} = Tuple{K,D}
Base.getindex(tr::AVLTree{K,D},k::K) where {K,D} = Base.getkey(tr, k) 
Base.setindex!(tr::AVLTree{K,D},k::K,d::D) where {K,D} = AVLTrees.insert!(tr, k, d)
Base.haskey(tr::AVLTree{K,D},k::K) where {K,D} = !(find_node(tr, k) === nothing)
Base.length(tr::AVLTree{K,D}) where {K,D} = AVLTrees.size(tr)
Base.isempty(tr::AVLTree{K,D}) where {K,D} = isnothing(tr.root)

function Base.getkey(tr::AVLTree{K,D}, k::K) where {K,D} 
    d = findkey(tr, k)
    if isnothing(d) throw(KeyError(k)) else d end
end


function Base.size(tree::AVLTree)
    return __size(tree.root)
end # function

@inline function __size(node::Union{Nothing,Node})
    if isnothing(node)
        return 0
    end
    return __size(node.left) + __size(node.right) + 1
end


"""
    insert!(args)

documentation
"""
function Base.insert!(tree::AVLTree{K,D}, key, data) where {K,D}
    parent = nothing
    node = tree.root

    while !isnothing(node)
        parent = node
        if key < node.key
            node = node.left
        elseif key > node.key
            node = node.right
        else
            node.data = data
            return
        end
    end

    if isnothing(parent)
        tree.root = Node{K,D}(key, data)
    elseif key < parent.key
        parent.left = Node{K,D}(key, data, parent)
        balance_insertion(tree, parent, true)
    elseif key > parent.key
        parent.right = Node{K,D}(key, data, parent)
        balance_insertion(tree, parent, false)
    end

    return
end # function

"""
macro rebalance(tree, node)

documentation
"""
macro rebalance(tree, node, height_changed)
    return :(
    if $(esc(node)).bf == 2
        $(esc(height_changed)) = $(esc(node)).right.bf != 0
        if $(esc(node)).right.bf == -1
            rotate_right($(esc(tree)), $(esc(node)).right)
        end
        $(esc(node)) = rotate_left($(esc(tree)), $(esc(node)))
    elseif $(esc(node)).bf == -2
        $(esc(height_changed)) = $(esc(node)).left.bf != 0
        if $(esc(node)).left.bf == 1
            rotate_left($(esc(tree)), $(esc(node)).left)
        end
        $(esc(node)) = rotate_right($(esc(tree)), $(esc(node)))
    else
        $(esc(height_changed)) = $(esc(node)).bf == 0
    end)
end 

"""
    balance_insertion(tree::AVLTree{K,D},node::Node{K,D},left_insertion::Bool) where {K,D}

documentation
"""
function balance_insertion(
    tree::AVLTree{K,D},
    node::Node{K,D},
    left_insertion::Bool,
) where {K,D}
    while !isnothing(node)
        node.bf += ifelse(left_insertion, -1, 1)
        height_changed = false
        @rebalance(tree, node, height_changed)
        if height_changed
            break
        end
        left_insertion = !isnothing(node.parent) && node.parent.left == node
        node = node.parent
    end
end # function


@inline function rotate_left(t::AVLTree{K,D}, x::Node{K,D}) where {K,D}
    y = x.right

    x.right = y.left
    if !isnothing(y.left)
        y.left.parent = x
    end
    y.left = x

    if isnothing(x.parent)
        t.root = y
    else
        if x.parent.left == x
            x.parent.left = y
        else
            x.parent.right = y
        end
    end

    y.parent = x.parent
    x.parent = y

    x.bf -= y.bf * (y.bf >= 0) + 1
    y.bf += x.bf * (x.bf < 0) - 1

    return y
end

@inline function rotate_right(t::AVLTree{K,D}, x::Node{K,D}) where {K,D}
    y = x.left

    x.left = y.right
    if !isnothing(y.right)
        y.right.parent = x
    end
    y.right = x

    if isnothing(x.parent)
        t.root = y
    else
        if x.parent.left == x
            x.parent.left = y
        else
            x.parent.right = y
        end
    end

    y.parent = x.parent
    x.parent = y

    x.bf -= y.bf * (y.bf < 0) - 1
    y.bf += x.bf * (x.bf >= 0) + 1

    return y
end


"""
    delete!(tree::AVLTree{K,D}, node::Node{K,D}) where {K,D}

documentation
"""
function Base.delete!(tree::AVLTree{K,D}, node::Node{K,D}) where {K,D}
    if !isnothing(node.left)
        if !isnothing(node.right)
            # left != nothing && right != nothing
            temp = node.right
            while !isnothing(temp.left)
                temp = temp.left
            end
            # switch spots completely
            node.key = temp.key
            node.data = temp.data
            delete!(tree, temp)
        else
            # left != nothing && right == nothing
            dir = __parent_replace(tree, node, node.left)
            balance_deletion(tree, node.parent, dir)
        end
    else
        if !isnothing(node.right)
            # left == nothing && right != nothing
            dir = __parent_replace(tree, node, node.right)
            balance_deletion(tree, node.parent, dir)
        else
            # left == nothing && right == nothing
            dir = __parent_replace(tree, node, nothing)
            balance_deletion(tree, node.parent, dir)
        end
    end
    return
end # function


"""
    delete!(tree::AVLTree{K,D}, key::K) where {K,D}
"""
function Base.delete!(tree::AVLTree{K,D}, key::K) where {K,D}
    node = find_node(tree, key)
    if !isnothing(node)
        delete!(tree, node)
    end
end # function


"""
    balance_deletion(args)
"""
function balance_deletion(
    tree::AVLTree{K,D},
    node::Union{Node{K,D},Nothing},
    left_delete::Union{Nothing,Bool},
) where {K,D}
    while !isnothing(node)
        node.bf += ifelse(left_delete, 1, -1)
        height_changed = false
        @rebalance(tree, node, height_changed)
        if !height_changed
            break
        end
        left_delete = !isnothing(node.parent) && node.parent.left == node
        node = node.parent
    end
end # function


#    __parent_replace(tree::AVLTree{K,D}, node::Node{K,D}, replacement::Node{K,D})
# 
# Replaces node with its only child. Used on nodes with a single child when erasing a node.
@inline function __parent_replace(
    tree::AVLTree{K,D},
    node::Node{K,D},
    replacement::Node{K,D},
) where {K,D}
    if !isnothing(node.parent)
        replacement.parent = node.parent
        if node.parent.right == node
            node.parent.right = replacement
            return false
        else
            node.parent.left = replacement
            return true
        end
    else
        replacement.parent = nothing
        tree.root = replacement
        return nothing
    end
end # function


#    __parent_replace(tree::AVLTree{K,D}, node::Node{K,D}, replacement::Nothing)
# Replaces node with nothing. Used on leaf nodes when erasing a node.
@inline function __parent_replace(
    tree::AVLTree{K,D},
    node::Node{K,D},
    replacement::Nothing,
) where {K,D}
    if !isnothing(node.parent)
        if node.parent.right == node
            node.parent.right = replacement
            return false
        else
            node.parent.left = replacement
            return true
        end
    else
        tree.root = replacement
        return nothing
    end
end # function


"""
    find(tree::AVLTree{K,D}, key::K) where {K,D}

    Warning: do not use it to check whether `key` is in the `tree`.
    It returns the node.data if found which can be `nothing`.
"""
function findkey(tree::AVLTree{K,D}, key::K) where {K,D}
    node = tree.root
    while !isnothing(node)
        if key < node.key
            node = node.left
        elseif key > node.key
            node = node.right
        else
            return node.data
        end
    end
    return nothing
end # function


"""
    find_node(args)
"""
function find_node(tree::AVLTree{K,D}, key::K) where {K,D}
    node = tree.root
    while !isnothing(node)
        if key < node.key
            node = node.left
        elseif key > node.key
            node = node.right
        else
            return node
        end
    end
    return nothing
end # function


# Iteration interface

function Base.iterate(tree::AVLTree)
    if isnothing(tree.root)
        return nothing
    end
    node = tree.root
    while !isnothing(node.left)
        node = node.left
    end
    return (node.key, node.data), node
end

function Base.iterate(tree::AVLTree, node::Node)
    if !isnothing(node.right)
        node = node.right
        while !isnothing(node.left)
            node = node.left
        end
    else
        prev = node
        while !isnothing(node) && node.left != prev
            prev = node
            node = node.parent
        end
    end

    if isnothing(node)
        return nothing
    end

    return (node.key, node.data), node
end

# Pop and get methods

function Base.popfirst!(tree::AVLTree)
    # traverse to left-most node
    if isnothing(tree.root)
        return
    end
    node = tree.root
    while !isnothing(node.left)
        node = node.left
    end
    # delete node and return data
    node_data = node.data
    delete!(tree, node)
    return node_data
end

function Base.pop!(tree::AVLTree{K,D}, key::K) where {K,D}
    node = AVLTrees.find_node(tree, key)
    if !isnothing(node)
        node_dat = node.data
        delete!(tree, node)
        return node_dat
    else
        return
    end
end

function Base.firstindex(tree::AVLTree)
    # traverse to left-most node
    if isnothing(tree.root)
        return
    end
    node = tree.root
    while !isnothing(node.left)
        node = node.left
    end
    # return node key
    return node.key
end



## Print and Show methods

function Base.print(io::IO, tree::AVLTree{K,D}) where {K,D}
    str_lst = Vector{String}()
    for (k, v) in Base.Iterators.take(tree, 10)
        push!(str_lst, "$k => $v")
    end
    print(io, "AVLTree{$K,$D}(")
    print(io, join(str_lst, ", "))
    length(str_lst) == 10 && print(io, ", ⋯ ")
    print(io, ")")
end

function Base.show(io::IO, ::MIME"text/plain", tree::AVLTree{K,D}) where {K,D}
    str_lst = Vector{String}()
    indent_str = "  "
    for (k, v) in Base.Iterators.take(tree, 10)
        push!(str_lst, indent_str * "$k => $v")
    end
    if length(str_lst) > 0
        print(io, "AVLTree{$K,$D} with $(length(tree)) entries:\n")
        print(io, join(str_lst, "\n"))
    else
        print(io, "AVLTree{$K,$D}()")
    end
    length(str_lst) == 10 && print(io, "\n", indent_str * "⋮ => ⋮ \n")
end

