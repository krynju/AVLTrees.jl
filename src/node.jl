
"""
    Node

struct
"""
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

Node{K,D}(key, data, parent) where {K,D} =
    Node{K,D}(key, data, parent, nothing, nothing, Int8(0))
Node{K,D}(key, data) where {K,D} = Node{K,D}(key, data, nothing)


function children(node::Node{K,D}) where {K,D}
    if node.left != nothing
        if node.right != nothing
            return (node.left, node.right)
        else
            return (node.left,)
        end
    else
        if node.right != nothing
            return (node.right,)
        else
            return ()
        end
    end
end


Base.show(io::IO, ::MIME"text/plain", node::Node{K,D}) where {K,D} = print(
    io,
    "Node{$(K),$(D)}: $(node.key) -> $(node.data)",
)

printnode(io::IO, node::Node{K,D}) where{K,D} = print(io, "Node{$(K),$(D)}: $(node.key) -> $(node.data)")
