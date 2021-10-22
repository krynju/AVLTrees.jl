# AVLTrees

[![Build Status](https://travis-ci.com/krynju/AVLTrees.jl.svg?branch=master)](https://travis-ci.com/krynju/AVLTrees.jl)
[![codecov](https://codecov.io/gh/krynju/AVLTrees.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/krynju/AVLTrees.jl)

AVL self-balancing tree written in pure Julia.

Implemented on raw heap assigned storage with minimal overhead coming from
balancing the tree itself. The tree node structure only has an additional Int8
keeping the balance factor. All balancing procedures are dynamically propagated
(no height calculations during balancing).

## Benchmark

An overview of performance is shown below (Julia 1.6.3). Times in nanoseconds. Average of 100 operations performed at tree size `n` using `Int64` keys and data.

### Table

```julia
 Row │ n         insert    delete    search   
     │ Any       Float64?  Float64?  Float64? 
─────┼────────────────────────────────────────
   1 │ 1000          18.0      19.0  0.182365
   2 │ 10000         31.0      29.0  0.204204
   3 │ 100000        52.0      46.0  0.222668
   4 │ 1000000       74.0      68.0  0.247743
   5 │ 10000000     111.0      99.0  0.25502
```

### Plot


![benchmark results](https://github.com/krynju/AVLTrees.jl/blob/master/benchmark/result.svg)

![benchmark results](https://github.com/krynju/AVLTrees.jl/blob/master/benchmark/result_log.svg)
