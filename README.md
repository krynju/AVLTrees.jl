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

| N    | insert [us]    | delete [us] | lookup [us] |
| :------------- | :------------- | :-------| :---- |
| 10<sup>3</sup>     |    86.039  |   67.768 |   67.433    |
|10<sup>4</sup>  | 152.533 | 87.305 |   89.556 |
|   10<sup>5</sup>  |  260.794 | 107.378 |  114.014 |
|  10<sup>6</sup>  | 424.0  | 123.648 |  124.587 |
| 10<sup>7</sup>  | 659.088  |  135.373 | 134.609 |

### Plot


![benchmark results](https://github.com/krynju/AVLTrees.jl/blob/master/benchmark/result.svg)
