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
   1 │ 1000       12.5      6.70253  0.164164
   2 │ 10000      24.8889  12.4      0.18018
   3 │ 100000     45.1429  22.0      0.192385
   4 │ 1000000    65.8     32.2222   0.225677
   5 │ 10000000  104.0     49.4286   0.235944
```

### Plot


![benchmark results](https://github.com/krynju/AVLTrees.jl/blob/master/benchmark/result.svg)

![benchmark results](https://github.com/krynju/AVLTrees.jl/blob/master/benchmark/result_log.svg)
