# AVLTrees

[![Build Status](https://travis-ci.com/krynju/AVLTrees.jl.svg?branch=master)](https://travis-ci.com/krynju/AVLTrees.jl)
[![codecov](https://codecov.io/gh/krynju/AVLTrees.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/krynju/AVLTrees.jl)

AVL self-balancing tree written in pure Julia.

Implemented on raw heap assigned storage with minimal overhead coming from
balancing the tree itself. The tree node structure only has an additional Int8
keeping the balance factor. All balancing procedures are dynamically propagated
(no height calculations during balancing).

## Benchmark

An overview of performance is shown below. Times are shown for an average of 1000 operations made at N elements in the structure.

### Table

```julia
 Row │ n         insert[us]   delete[us]    search[us]
     │ Any       Float64?     Float64?      Float64?  
─────┼────────────────────────────────────────────────
   1 │ 1000          152.67        32.02    0.00222892
   2 │ 10000         174.1         63.86    0.00227912
   3 │ 100000        299.6        165.86    0.00235597
   4 │ 1000000       629.11       524.92    0.00304124
   5 │ 10000000      964.76       912.39    0.025
```

### Plot


![benchmark results](https://github.com/krynju/AVLTrees.jl/blob/master/benchmark/result.svg)
