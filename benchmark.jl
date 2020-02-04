using AVL, BenchmarkTools
using Random
using Plots



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

x = [1000, 10000, 100000]

for N in x

    global t = AVLTree{Int64,Int64}()
    rng = MersenneTwister(1111)
    global nums = rand(rng,Int64, N)
    global unique_nums = Vector{Int64}(undef,1000)
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

    search = @benchmark batch_find(t, nums[1:1000])
    insertion = @benchmark batch_insert!(t, unique_nums)

    t = AVLTree{Int64,Int64}()
    rng = MersenneTwister(1111)
    nums = rand(rng,Int64, N)
    unique_nums = Vector{Int64}(undef,1000)
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

    deletion = @benchmark batch_delete!(t, nums[1:1000])

    push!(insertion_vec, minimum(insertion).time)
    push!(deletion_vec, minimum(deletion).time)
    push!(search_vec, minimum(search).time)
    println("done $N")
end

println("insert_times : $insertion_vec")
println("deletion_times : $deletion_vec")
println("search_times : $search_vec")


# plot(x, insertion_vec/1000, xscale=:log10, ylabel="us")
# plot(x, deletion_vec/1000, xscale=:log10, ylabel="us")
# plot(x, search_vec/1000, xscale=:log10, ylabel="us")
