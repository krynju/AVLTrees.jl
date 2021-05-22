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
        insert!(t, i, i)
    end
end

function batch_find(t::AVLTree{K,D}, v::Vector{K}) where {K,D}
    for i in v
        findkey(t, i)
    end
end

insertion_vec = []
deletion_vec = []
search_vec = []


d = DataFrame((op=[], time=[], n=[]))
x = [1000, 10000, 100000, 1000000]


for attempt in 1:20
for N in x
    global t = AVLTree{Int64,Int64}()
    rng = MersenneTwister(1111)
    global nums = rand(rng, Int64, N)
    global unique_nums = Vector{Int64}(undef, 1000)
    for i in pairs(unique_nums)
        r = rand(rng, Int64)
        while (r in nums)
            r = rand(rng, Int64)
        end
        unique_nums[i[1]] = r
    end
    for i in nums
        insert!(t, i, i)
    end

    search = @benchmark batch_find(t, nums[1:1000]) samples=1 evals=1
    insertion = @benchmark batch_insert!(t, unique_nums) samples=1 evals=1

    t = AVLTree{Int64,Int64}()
    rng = MersenneTwister(1111)
    nums = rand(rng, Int64, N)
    unique_nums = Vector{Int64}(undef, 1000)
    for i in pairs(unique_nums)
        r = rand(rng, Int64)
        while (r in nums)
            r = rand(rng, Int64)
        end
        unique_nums[i[1]] = r
    end
    for i in nums
        insert!(t, i, i)
    end

    deletion = @benchmark batch_delete!(t, nums[1:1000]) samples=1 evals=1

    push!(d, ("insert", minimum(insertion).time, N))
    push!(d, ("delete", minimum(deletion).time,N))
    push!(d, ("search", minimum(search).time,N))
    println("done $N")
end
end



c= combine(groupby(d, [:op,:n]), :time => minimum)

# plot(x, insertion_vec/1000, xscale=:log10, ylabel="us")
# plot(x, deletion_vec/1000, xscale=:log10, ylabel="us")
# plot(x, search_vec/1000, xscale=:log10, ylabel="us")


plot(
    x,
    [c[(c.op.=="insert"),:].time_minimum./1000,c[(c.op.=="delete"),:].time_minimum./1000, c[(c.op.=="search"),:].time_minimum./1000],
    xscale = :log10,
    ylabel = "operation time [us]",
    xlabel = "N",
    markershape =[:diamond :utriangle :dtriangle],
    labels= ["insert" "delete" "lookup"],
    legend=:topleft,
)

#savefig("result.svg")
