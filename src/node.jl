mutable struct Node{K, V}
    parent::Union{Node{K, V},Nothing}
    left::Union{Node{K, V},Nothing}
    right::Union{Node{K, V},Nothing}
    key::K
    bf::Int8
    data::V
end

Node{K, V}(key, data, parent) where {K, V} =
    Node{K, V}(parent, nothing, nothing, key, Int8(0), data)
Node{K, V}(key, data) where {K, V} = Node{K, V}(key, data, nothing)


Node(key::K, data::V) where {K, V} = Node{K, V}(key, data)
Node(key::K, data::V, parent::Union{Node{K, V},Nothing}) where {K, V} =
    Node{K, V}(key, data, parent)

Base.show(io::IO, ::MIME"text/plain", node::Node{K, V}) where {K, V} =
    print(io, "Node{$(K),$(D)}: $(node.key) -> $(node.data)")
