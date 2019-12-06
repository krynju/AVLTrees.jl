

mutable struct Node{K,D}
    key::K
    data::D
    parent::Union{Node{K,D},Nothing}
    left::Union{Node{K,D},Nothing}
    right::Union{Node{K,D},Nothing}
    bf::Int8
end # Node

Node(key, data) = Node(key, data, nothing, nothing, nothing,Int8(0))
Node(key, data, parent) = Node(key, data, parent, nothing, nothing, Int8(0))

mutable struct AVLTree{K,D}
    root::Union{Node{K,D},Nothing}
end

AVLTree() = AVLTree(nothing)


"""
    insert!(args)

documentation
"""
function insert!(tree::AVLTree, key, data)
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
    elseif key > parent.key
        parent.right = Node(key, data, parent)
    end

    return
end # function



"""
    balance(args)

documentation
"""
function balance(node::Node)

end # function

function rotate_left(t::AVLTree, x::Node)
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

function rotate_right(t::AVLTree, x::Node)
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
