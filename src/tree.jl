mutable struct AVLTree{K, V}
    root::Union{Node{K, V},Nothing}

    function AVLTree{K,V}() where {K,V}
        new(nothing)
    end
end

AVLTree() = AVLTree{Any,Any}()

##############################################################
# Core
##############################################################

# TODO: Verify whether the macro is still necessary
macro rebalance!(_tree, _node, _height_changed)
    tree = esc(_tree)
    node = esc(_node)
    height_changed = esc(_height_changed)

    return :(
        if $(node).bf == 2
            $(node), $(height_changed) = _rebalance_barrier_p2($(tree), $(node), $(node).right)
        elseif $(node).bf == -2
            $(node), $(height_changed) = _rebalance_barrier_n2($(tree), $(node), $(node).left)
        else
            $(height_changed) = $(node).bf == zero(Int8)
        end
    )
end


@inline function _rebalance_barrier_p2(tree::AVLTree{K, V}, node::Node{K, V}, node_right::Node{K, V}) where {K, V}
    height_changed = node_right.bf != zero(Int8)
    if node_right.bf == -one(Int8)
        rotate_right(tree, node_right, node_right.left)
    end
    rotate_left(tree, node, node.right), height_changed
end


@inline function _rebalance_barrier_n2(tree::AVLTree{K, V}, node::Node{K, V}, node_left::Node{K, V}) where {K, V}
    height_changed = node_left.bf != zero(Int8)
    if node_left.bf == one(Int8)
        rotate_left(tree, node_left, node_left.right)
    end
    rotate_right(tree, node, node.left), height_changed
end


@inline function insert_node!(tree::AVLTree{K, V}, key::K, data::V) where {K, V}
    parent = nothing
    node = tree.root

    while node !== nothing
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

    if parent === nothing
        tree.root = Node{K, V}(key, data)
    elseif key < parent.key
        parent.left = Node{K, V}(key, data, parent)
        balance_insertion(tree, parent, true)
    elseif key > parent.key
        parent.right = Node{K, V}(key, data, parent)
        balance_insertion(tree, parent, false)
    end

    return tree
end


@inline function balance_insertion(
    tree::AVLTree{K, V},
    node::Node{K, V},
    left_insertion::Bool,
) where {K, V}
    while true
        node.bf += ifelse(left_insertion, -one(Int8), one(Int8))
        height_changed = false
        @rebalance!(tree, node, height_changed)

        height_changed && break
        node_parent = node.parent
        if node_parent !== nothing
            left_insertion = node_parent.left == node
            node = node_parent
        else
            break
        end
    end
end


@inline function delete_node!(tree::AVLTree{K, V}, node::Node{K, V}) where {K, V}
    if node.left !== nothing
        node_right = node.right
        if node_right !== nothing
            # left != nothing && right != nothing
            temp = node_right
            temp_left = temp.left
            while temp_left !== nothing
                temp = temp_left
                temp_left = temp.left
            end
            # switch spots completely
            node.key = temp.key
            node.data = temp.data
            delete_node!(tree, temp)
        else
            # left != nothing && right == nothing
            dir = __parent_replace(tree, node, node.left)
            balance_deletion(tree, node.parent, dir)
            node.parent = nothing
            node.left = nothing
        end
    else
        node_right = node.right
        if node_right !== nothing
            # left == nothing && right != nothing
            dir = __parent_replace(tree, node, node_right)
            balance_deletion(tree, node.parent, dir)
            node.parent = nothing
            node.right = nothing
        else
            # left == nothing && right == nothing
            dir = __parent_replace(tree, node, nothing)
            balance_deletion(tree, node.parent, dir)
            node.parent = nothing
        end
    end
    return tree
end


@inline balance_deletion(tree::AVLTree, node::Nothing, left_delete::Bool) = return nothing


@inline function balance_deletion(
    tree::AVLTree{K, V},
    node::Node{K, V},
    left_delete::Bool,
) where {K, V}
    while node !== nothing
        node.bf += ifelse(left_delete, one(Int8), -one(Int8))
        height_changed = false
        @rebalance!(tree, node, height_changed)

        !height_changed && break
        node_parent = node.parent
        if node_parent !== nothing
            left_delete = node_parent.left == node
            node = node_parent
        else
            break
        end
    end
end


@inline function rotate_left(t::AVLTree{K, V}, x::Node{K, V}, x_right::Node{K, V}) where {K, V}
    y = x_right

    if y.left !== nothing
        x.right = y.left
        y.left.parent = x
    else
        x.right = nothing
    end
    y.left = x

    xp = x.parent
    if xp === nothing
        t.root = y
    else
        if xp.left == x
            xp.left = y
        else
            xp.right = y
        end
    end

    y.parent = xp
    x.parent = y

    x.bf -= y.bf * (y.bf >= zero(Int8)) + one(Int8)
    y.bf += x.bf * (x.bf < zero(Int8)) - one(Int8)

    return y
end


@inline function rotate_right(t::AVLTree{K, V}, x::Node{K, V}, x_left::Node{K, V}) where {K, V}
    y = x_left

    if y.right !== nothing
        x.left = y.right
        y.right.parent = x
    else
        x.left = nothing
    end
    y.right = x

    xp = x.parent
    if xp === nothing
        t.root = y
    else
        if xp.left == x
            xp.left = y
        else
            xp.right = y
        end
    end

    y.parent = xp
    x.parent = y

    x.bf -= y.bf * (y.bf < zero(Int8)) - one(Int8)
    y.bf += x.bf * (x.bf >= zero(Int8)) + one(Int8)

    return y
end


#    __parent_replace(tree::AVLTree{K, V}, node::Node{K, V}, replacement::Node{K, V})
#
# Replaces node with its only child. Used on nodes with a single child when erasing a node.
@inline function __parent_replace(
    tree::AVLTree{K, V},
    node::Node{K, V},
    replacement::Node{K, V},
) where {K, V}
    node_parent = node.parent
    if node_parent !== nothing
        replacement.parent = node_parent
        if node_parent.right == node
            node_parent.right = replacement
            return false
        else
            node_parent.left = replacement
            return true
        end
    else
        replacement.parent = nothing
        tree.root = replacement
        return false
    end
end


#    __parent_replace(tree::AVLTree{K, V}, node::Node{K, V}, replacement::Nothing)
#
# Replaces node with nothing. Used on leaf nodes when erasing a node.
@inline function __parent_replace(
    tree::AVLTree{K, V},
    node::Node{K, V},
    replacement::Nothing,
) where {K, V}
    node_parent = node.parent
    if node_parent !== nothing
        if node_parent.right == node
            node_parent.right = replacement
            return false
        else
            node_parent.left = replacement
            return true
        end
    else
        tree.root = replacement
        return false
    end
end




##############################################################
# Utilities
##############################################################
@inline function find_node(tree::AVLTree{Nothing, V}, ::Nothing) where { V}
    return tree.root
end

@inline function find_node(tree::AVLTree{Missing, V}, ::Missing) where { V}
    return tree.root
end

@inline function find_node(tree::AVLTree{K, V}, key::K) where {K, V}
    node = tree.root
    while node !== nothing
        if key < node.key
            node = node.left
        elseif key > node.key
            node = node.right
        else
            return node
        end
    end
    return nothing
end

@inline function empty_tree!(tree::AVLTree{K, V}) where {K, V}
    empty_node!(tree.root)
    tree.root = nothing
end

function empty_node!(node::Node{K, V}) where {K, V}
    empty_node!(node.left)
    empty_node!(node.right)
    node.left = nothing
    node.right = nothing
    node.parent = nothing
end

empty_node!(node::Nothing) = return nothing

function printtree(tree::AVLTree)
    fifo = Vector{Union{Nothing, Node}}()
    push!(fifo, tree.root)

    maxlen = 2^(height(tree)) - 1

    i = 1
    while !isempty(fifo) && i <= maxlen
        i & (i - 1) == 0 && print("\n")
        n = popfirst!(fifo)
        if n isa Node
            print("$(n.key), ")
            push!(fifo,n.left)
            push!(fifo,n.right)
        else
            print("n, ")
        end
        i += 1
    end
end

function height(tree::AVLTree)
    isempty(tree) && return 0
    height(tree.root, 0)
end

function height(node::Node, level)
    l = height(node.left, level)
    r = height(node.right, level)
    maximum([l, r]) + 1
end

function height(node::Nothing, level)
    return level
end
