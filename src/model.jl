

mutable struct Node{K,D}
    key::K
    data::D
    parent::Union{Node{K,D},Nothing}
    left::Union{Node{K,D},Nothing}
    right::Union{Node{K,D},Nothing}
    bf::Int
end # Node

Node(key, data) = Node(key, data, nothing, nothing, nothing, 0)
Node(key, data, parent) = Node(key, data, parent, nothing, nothing, 0)

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
