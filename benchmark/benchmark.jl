using AVLTrees, BenchmarkTools
using Random
using Plots
using DataFrames


function batch_insert!(t::AVLTree{K,D}, v::Vector{K}) where {K,D}
    for i in v
        insert!(t, i, i)
    end
end

function batch_delete!(t::AVLTree{K,D}, v::Vector{K}) where {K,D}
    for i in v
        delete!(t, i)
    end
end

function batch_find(t::AVLTree{K,D}, v::Vector{K}) where {K,D}
    for i in v
        i in t
    end
end

d = DataFrame((op=[], time=[], n=[]))
x = [1_000, 10_000, 100_000, 1_000_000, 10_000_000]

function prepare_t_insert(t)
    batch_delete!(t, nums_test)
    t
end

function prepare_t_delete(t)
    batch_insert!(t, nums_test)
    t
end

for attempt in 1:5
    for N in x
        global t = AVLTree{Int64,Int64}()
        rng = MersenneTwister(1111)
        global nums_fill = rand(rng, Int64, N)
        nn = 100
        global nums_test = rand(rng, Int64, nn)

        for i in nums_fill
            insert!(t, i, i)
        end

        insertion = @benchmark batch_insert!(_t, nums_test) setup=(_t=prepare_t_insert(t))
        deletion = @benchmark batch_delete!(_t, nums_test) setup=(_t=prepare_t_delete(t))

        batch_insert!(t, nums_test)
        search = @benchmark batch_find(t, nums_test)

        push!(d, ("insert", minimum(insertion).time/nn, N))
        push!(d, ("delete", minimum(deletion).time/nn,N))
        push!(d, ("search", minimum(search).time/nn,N))
        println("done $N")
    end
end

c = combine(groupby(d, [:op,:n]), :time => minimum)


plot(
    x,
    [c[(c.op.=="insert"),:].time_minimum,c[(c.op.=="delete"),:].time_minimum, c[(c.op.=="search"),:].time_minimum],
    xscale = :log10,
    # yscale = :log10,
    ylabel = "operation time [ns]",
    xlabel = "N",
    xticks = [1e3, 1e4, 1e5, 1e6, 1e7],
    markershape =[:diamond :utriangle :dtriangle],
    labels= ["insert" "delete" "lookup"],
    legend=:topleft,
)

