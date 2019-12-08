mutable struct Node{K,D}
    key::K
    data::D
    parent::Union{Node{K,D},Nothing}
    left::Union{Node{K,D},Nothing}
    right::Union{Node{K,D},Nothing}
    bf::Int8
end # Node

Node(key::K, data::D) where {K,D} =
    Node{K,D}(key, data, nothing, nothing, nothing, Int8(0))
Node(key::K, data::D, parent::Union{Node{K,D},Nothing}) where {K,D} =
    Node{K,D}(key, data, parent, nothing, nothing, Int8(0))

mutable struct AVLTree{K,D}
    root::Union{Node{K,D},Nothing}
end

AVLTree() = AVLTree{Any,Any}(nothing)
AVLTree{K,D}() where {K,D} = AVLTree{K,D}(nothing)

"""
    insert!(args)

documentation
"""
function insert!(tree::AVLTree{K,D}, key::K, data::D) where {K,D}
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
        tree.root = Node(key, data)
    elseif key < parent.key
        parent.left = Node(key, data, parent)
        balance(tree, parent, true)
    elseif key > parent.key
        parent.right = Node(key, data, parent)
        balance(tree, parent, false)
    end

    return
end # function



"""
    balance(args)

documentation
"""
function balance(
    tree::AVLTree{K,D},
    node::Node{K,D},
    left_insertion::Bool,
) where {K,D}
    while node != nothing
        if left_insertion
            node.bf -= 1
        else
            node.bf += 1
        end

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
        y.parent = nothing
    elseif x.parent.left == x
        x.parent.left = y
    else
        x.parent.right = y
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
        y.parent = nothing
    elseif x.parent.left == x
        x.parent.left = y
    else
        x.parent.right = y
    end

    y.parent = x.parent
    x.parent = y

    x.bf -= y.bf * (y.bf < 0) - 1
    y.bf += x.bf * (x.bf >= 0) + 1

    return y
end

"""
    erase!(tree::AVLTree{K,D}, node::Node{K,D}) where {K,D}

documentation

add balancing
"""
function erase!(tree::AVLTree{K,D}, node::Node{K,D}) where {K,D}
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
            erase!(tree, temp)
        else
            # left != nothing && right == nothing
            dir = parent_replace(tree, node, node.left)
            node.left.parent = node.parent
            balance_erase(tree, node.parent, dir)
        end
    else
        if node.right != nothing
            # left == nothing && right != nothing
            dir = parent_replace(tree, node, node.right)
            node.right.parent = node.parent
            balance_erase(tree, node.parent, dir)
        else
            # left == nothing && right == nothing
            dir = parent_replace(tree, node, nothing)
            balance_erase(tree, node.parent, dir)
        end
    end
end # function


"""
    balance_erase(args)

documentation
"""
function balance_erase(
    tree::AVLTree{K,D},
    node::Union{Node{K,D}, Nothing},
    left_erase::Union{Nothing,Bool},
) where {K,D}
    while node != nothing
        if left_erase
            node.bf += 1
        else
            node.bf -= 1
        end

        node, height_changed = rebalance(tree, node)

        if !height_changed
            break
        end

        left_erase = node.parent != nothing && node.parent.left == node
        node = node.parent
    end
end # function

"""
    parent_replace(args)

documentation
"""
function parent_replace(
    tree::AVLTree{K,D},
    node::Node{K,D},
    replacement::Union{Nothing,Node{K,D}},
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
        if replacement != nothing
            replacement.parent = nothing
        end
        tree.root = replacement
        return nothing
    end
end # function
