

mutable struct Node{keyType,dataType}
    key::keyType
    data::dataType
    parent::Union{Node,Nothing}
    left::Union{Node,Nothing}
    right::Union{Node,Nothing}
end # Node

Node(key, data) = Node(key, data, nothing, nothing, nothing)
