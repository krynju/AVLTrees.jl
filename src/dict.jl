struct AVLDict{K,D} <: AbstractDict{K,D}
    tree::AVLTree{K,D}

    function AVLDict{K,D}() where {K,D}
        return new(AVLTree{K,D}())
    end
    function AVLDict{K,D}(t::AVLTree{K,D}) where {K,D}
        return new(t)
    end
    function AVLDict{K,D}(d::AVLDict{K,D}) where {K,D}
        # copy here
        return d
    end
end

AVLDict() = AVLDict{Any,Any}()
# AVLDict{K,D}(d::AVLDict{K,D})  where {K,D} = d
# AVLDict{K,D}() where {K,D} = AVLDict{K,D}(AVLTree{K,D}())
function AVLDict(kv)
    try
        Base.dict_with_eltype((K, V) -> AVLDict{K,V}, kv, eltype(kv))
    catch
        if !Base.isiterable(typeof(kv)) || !all(x -> isa(x, Union{Tuple,Pair}), kv)
            throw(ArgumentError("AVLDict(kv): kv needs to be an iterator of tuples or pairs"))
        else
            rethrow()
        end
    end
end
function AVLDict{K,V}(kv) where {K,V}
    h = AVLTree{K,V}()
    for (k, v) in kv
        h[k] = v
    end
    return AVLDict{K,V}(h)
end
AVLDict(::Tuple{}) = AVLDict()

function AVLDict(ps::Pair...)
    return AVLDict(ps)
end

function AVLDict{K,V}(ps::Pair...) where {K,V}
    t = AVLTree{K,V}()
    for (k, d) in ps
        insert!(t, k, d)
    end
    return AVLDict{K,V}(t)
end

function AVLDict{K,V}(ps::Pair{K,V}...) where {K,V}
    t = AVLTree{K,V}()
    for (k, d) in ps
        insert!(t, k, d)
    end
    return AVLDict{K,V}(t)
end

Base.haskey(dict::AVLDict{K,D}, k::K) where {K,D} = haskey(dict.tree, k)

Base.get(dict::AVLDict{K,D}, k, default) where {K,D} = get(dict.tree, k, default)
Base.get(f::Function, dict::AVLDict{K,D}, k) where {K,D} = get(f, dict.tree, k)
Base.get!(dict::AVLDict{K,D}, k::K, default) where {K,D} = get!(dict.tree, k, default)
Base.get!(f::Function, dict::AVLDict{K,D}, k::K) where {K,D} = get!(f, dict.tree, k)

Base.delete!(dict::AVLDict{K,D}, k::K) where {K,D} = delete!(dict.tree, k)

Base.getindex(dict::AVLDict{K,D}, k::K) where {K,D} = getindex(dict.tree, k)

Base.getkey(dict::AVLDict{K,D}, k) where {K,D} = getkey(dict.tree, k)
Base.getkey(dict::AVLDict{K,D}, k, default) where {K,D} = getkey(dict.tree, k, default)
Base.isempty(dict::AVLDict) = isempty(dict.tree)
Base.length(dict::AVLDict) = length(dict.tree)

Base.setindex!(dict::AVLDict{K,D}, d::D, k::K) where {K,D} = setindex!(dict.tree, d, k)
Base.empty!(dict::AVLDict) = empty_tree!(dict.tree)

function Base.pop!(dict::AVLDict{K,D}) where {K,D}
    node = pop!(dict.tree)
    return node.key => node.data
end

function Base.pop!(dict::AVLDict{K,D}, k::K) where {K,D}
    node = pop!(dict.tree, k)
    return k => node.data
end

function Base.pop!(dict::AVLDict{K,D}, k::K, default) where {K,D}
    node = pop!(dict.tree, k, default)
    if node isa Node
        k => node.data
    else
        default
    end
end

function iterate(dict::AVLDict)
    ret = iterate(dict.tree)
    if ret === nothing
        return nothing
    else
        return (ret[1][1] => ret[1][2], ret[2])
    end
end

function iterate(dict::AVLDict, state)
    ret = iterate(dict.tree, state)
    if ret === nothing
        return nothing
    else
        return (ret[1][1] => ret[1][2], ret[2])
    end
end

function Base.show(io::IO, ::MIME"text/plain", t::AVLDict)
    return printtree(io, t.tree)
end

# [10] copy(d::Dict) in Base at dict.jl:120
# [13] filter!(pred, h::Dict{K, V}) where {K, V} in Base at dict.jl:703
# [25] mergewith!(combine, d1::Dict{K, V}, d2::AbstractDict) where {K, V} in Base at dict.jl:731
