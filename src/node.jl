
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

_getproperty(x::Nothing, f) = @assert false
_getproperty(x::Node{K,D}, f) where {K,D} = getfield(x, f)
Base.getproperty(x::Union{Nothing, Node{K,D}}, f::Symbol) where {K,D} =
    _getproperty(x, f)

_setproperty!(x::Nothing, f, v) = @assert false
_setproperty!(x::Node{K,D}, f, v) where {K,D} =
    # setfield!(x, f, convert(fieldtype(typeof(x), f), v))
    setfield!(x, f, v)
_setproperty!(x::Node{K,D}, f, ::Nothing) where {K,D} =
    setfield!(x, f, nothing)
_setproperty!(x::Node{K,D}, f, v::Node{K,D}) where {K,D} =
    setfield!(x, f, v)
Base.setproperty!(x::Union{Nothing, Node{K,D}}, f::Symbol, v) where {K,D} =
    _setproperty!(x, f, v)
Base.setproperty!(x::Union{Nothing, Node{K,D}}, f::Symbol, v::Union{Nothing, Node{K,D}}) where {K,D} =
    _setproperty!(x, f, v)

Base.show(io::IO, ::MIME"text/plain", node::Node{K,D}) where {K,D} =
    print(io, "Node{$(K),$(D)}: $(node.key) -> $(node.data)")
