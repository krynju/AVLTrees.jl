struct AVLSet{K} <: AbstractSet{K}
    tree::AVLTree{K,Nothing}
end

AVLSet() = AVLSet{Any}(AVLTree{Any,Nothing}())
AVLSet{K}() where {K} = AVLSet{K}(AVLTree{K,Nothing}())

Base.eltype(::Type{AVLSet{K}}) where {K} = K
Base.length(set::AVLSet) = length(set.tree) 


function iterate(set::AVLSet{K}) where {K}
    ret = iterate(set.tree)
    if isnothing(ret) return nothing else return (ret[1][1], ret[2])  end
end

function iterate(set::AVLSet{K}, node::Node{K,Nothing}) where {K}
    ret = iterate(set.tree, node)
    if isnothing(ret) return nothing else return (ret[1][1], ret[2])  end
end

Base.push!(set::AVLSet{K}, item::K) where {K} = insert!(set.tree, item, nothing)

function delete!(set::AVLSet{K}, item) where {K} delete!(set.tree, item) end
