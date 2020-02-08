# AVLTree

[![Build Status](https://travis-ci.com/krynju/AVLTree.jl.svg?branch=master)](https://travis-ci.com/krynju/AVLTree.jl)
[![codecov](https://codecov.io/gh/krynju/AVLTree.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/krynju/AVLTree.jl)

AVL self-balancing tree written in pure Julia.

Implemented on raw heap assigned storage with minimal overhead coming from
balancing the tree itself. The tree node structure only has an additional Int8
keeping the balance factor. All balancing procedures are dynamically propagated
(no height calculations during balancing).

## Benchmark

An overview of performance is shown below. Times are shown for an average of 1000 operations made at N elements in the structure.

### Table

| N    | insert [us]    | delete [us] | lookup [us] |
| :------------- | :------------- | :-------| :---- |
| 1000      |    86.039  |   67.768 |   67.433    |
|10000 | 152.533 | 87.305 |   89.556 |
|   100000 |  260.794 | 107.378 |  114.014 |
|  1000000 | 424.0  | 123.648 |  124.587 |
| 10000000 | 659.088  |  135.373 | 134.609 |

### Plot


![benchmark results](https://github.com/krynju/AVL.jl/blob/master/benchmark/result.svg)
