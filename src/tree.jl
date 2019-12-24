
"""
    AVLTree

struct
"""
mutable struct AVLTree{K,D}
    root::Union{Node{K,D},Nothing}
end

AVLTree() = AVLTree{Any,Any}(nothing)
AVLTree{K,D}() where {K,D} = AVLTree{K,D}(nothing)

function children(tree::AVLTree{K,D}) where {K,D}
    return ifelse(tree.root == nothing, (), (tree.root,))
end

Base.show(io::IO, ::MIME"text/plain", tree::AVLTree{K,D}) where {K,D} =
    print(io, "AVLTree{$(K),$(D)} with $(size(tree)) entries")

printnode(io::IO, tree::AVLTree{K,D}) where {K,D} =
    print(io, "AVLTree{$(K),$(D)} root")


"""
    insert!(args)

documentation
"""
function insert!(tree::AVLTree{K,D}, key, data) where {K,D}
    parent = nothing
    node = tree.root

    while node != nothing
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

    if parent == nothing
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
    balance_insertion(tree::AVLTree{K,D},node::Node{K,D},left_insertion::Bool) where {K,D}

documentation
"""
function balance_insertion(
    tree::AVLTree{K,D},
    node::Node{K,D},
    left_insertion::Bool,
) where {K,D}
    while node != nothing
        node.bf += ifelse(left_insertion, -1, 1)
        node, height_changed = rebalance(tree, node)
        if height_changed
            break
        end
        left_insertion = node.parent != nothing && node.parent.left == node
        node = node.parent
    end
end # function

"""
    rebalance(node::Node)

documentation
"""
function rebalance(tree::AVLTree{K,D}, node::Node{K,D})::Tuple{
    Node{K,D},
    Bool,
} where {K,D}
    if node.bf == 2
        height_changed = node.right.bf != 0
        if node.right.bf == -1
            rotate_right(tree, node.right)
        end
        node = rotate_left(tree, node)
        return node, height_changed
    elseif node.bf == -2
        height_changed = node.left.bf != 0
        if node.left.bf == 1
            rotate_left(tree, node.left)
        end
        node = rotate_right(tree, node)
        return node, height_changed
    else
        return node, node.bf == 0
    end
end # function

function rotate_left(t::AVLTree{K,D}, x::Node{K,D}) where {K,D}
    y = x.right

    x.right = y.left
    if y.left != nothing
        y.left.parent = x
    end
    y.left = x

    if x.parent == nothing
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

function rotate_right(t::AVLTree{K,D}, x::Node{K,D}) where {K,D}
    y = x.left

    x.left = y.right
    if y.right != nothing
        y.right.parent = x
    end
    y.right = x

    if x.parent == nothing
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
function delete!(tree::AVLTree{K,D}, node::Node{K,D}) where {K,D}
    if node.left != nothing
        if node.right != nothing
            # left != nothing && right != nothing
            temp = node.right
            while temp.left != nothing
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
        if node.right != nothing
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

documentation
"""
function delete!(tree::AVLTree{K,D}, key::K) where {K,D}
    node = find_node(tree, key)
    if node != nothing
        delete!(tree, node)
    end
end # function

"""
    balance_deletion(args)

documentation
"""
function balance_deletion(
    tree::AVLTree{K,D},
    node::Union{Node{K,D},Nothing},
    left_delete::Union{Nothing,Bool},
) where {K,D}
    while node != nothing
        node.bf += ifelse(left_delete, 1, -1)
        node, height_changed = rebalance(tree, node)
        if !height_changed
            break
        end
        left_delete = node.parent != nothing && node.parent.left == node
        node = node.parent
    end
end # function


#    __parent_replace(tree::AVLTree{K,D}, node::Node{K,D}, replacement::Node{K,D})
#
#Replaces node with its only child. Used on nodes with a single child when erasing a node.
@inbounds function __parent_replace(
    tree::AVLTree{K,D},
    node::Node{K,D},
    replacement::Node{K,D},
) where {K,D}
    if node.parent != nothing
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
#Replaces node with nothing. Used on leaf nodes when erasing a node.
@inbounds function __parent_replace(
    tree::AVLTree{K,D},
    node::Node{K,D},
    replacement::Nothing,
) where {K,D}
    if node.parent != nothing
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

documentation
"""
function findkey(tree::AVLTree{K,D}, key::K) where {K,D}
    node = tree.root
    while node != nothing
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

documentation
"""
function find_node(tree::AVLTree{K,D}, key::K) where {K,D}
    node = tree.root
    while node != nothing
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

"""
    size(tree::AVLTree{K,D}) where {K,D}

documentation
"""
function size(tree::AVLTree)
    return __size(tree.root)
end # function

@inline function __size(node::Union{Nothing,Node})
    if node == nothing
        return 0
    end
    return __size(node.left) + __size(node.right) + 1
end


function iterate(tree::AVLTree)
    if tree.root == nothing
        return nothing
    end
    node = tree.root
    while node.left != nothing
        node = node.left
    end
    return (node.key, node.data), node
end

function iterate(tree::AVLTree, node::Node)
    if node.right != nothing
        node = node.right
        while node.left != nothing
            node = node.left
        end
    else
        prev = node
        while node != nothing && node.left != prev
            prev = node
            node = node.parent
        end
    end

    if node == nothing
        return nothing
    end

    return (node.key, node.data), node
end # function

Base.eltype(::Type{AVLTree{K,D}}) where {K,D} = Tuple{K,D}
Base.length(tree::AVLTree) = size(tree)
