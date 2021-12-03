
"""
    Node

struct
"""
mutable struct Node{K,D}
    parent::Union{Node{K,D},Nothing}
    left::Union{Node{K,D},Nothing}
    right::Union{Node{K,D},Nothing}
    key::K
    bf::Int8
    data::D
end # Node

Node{K,D}(key, data, parent) where {K,D} =
    Node{K,D}(parent, nothing, nothing, key, Int8(0), data)
Node{K,D}(key, data) where {K,D} = Node{K,D}(key, data, nothing)

Node(key::K, data::D) where {K,D} = Node{K,D}(key, data)
Node(key::K, data::D, parent::Union{Node{K,D},Nothing}) where {K,D} =
    Node{K,D}(key, data, parent)

Base.setproperty!(x::Node{K,D}, f::Symbol, v) where {K,D} =
    setfield!(x, f, v)    

Base.show(io::IO, ::MIME"text/plain", node::Node{K,D}) where {K,D} =
    print(io, "Node{$(K),$(D)}: $(node.key) -> $(node.data)")
