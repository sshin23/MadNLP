![Logo](logo-full.svg)
---

[![build](https://github.com/sshin23/MadNLP.jl/workflows/build/badge.svg?branch=dev%2Fgithub_actions)](https://github.com/sshin23/MadNLP.jl/actions?query=workflow%3Abuild) [![codecov](https://codecov.io/gh/sshin23/MadNLP.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/sshin23/MadNLP.jl)

MadNLP is a [nonlinear programming](https://en.wikipedia.org/wiki/Nonlinear_programming) (NLP) solver, purely implemented in [Julia](https://julialang.org/). MadNLP implements a filter line-search algorithm, as that used in [Ipopt](https://github.com/coin-or/Ipopt). MadNLP seeks to streamline the development of modeling and algorithmic paradigms in order to exploit structures and to make efficient use of high-performance computers. 

## Installation
```julia
pkg> add MadNLP
```

## Build
The build process requires C and Fortran compilers. If they are not installed, do
```julia
shell> sudo apt install gcc gfortran # Linux
shell> brew cask install gcc gfortran # MacOS
```

MadNLP is interfaced with non-Julia sparse/dense linear solvers:
- [Umfpack](https://people.engr.tamu.edu/davis/suitesparse.html)
- [Mumps](http://mumps.enseeiht.fr/) 
- [MKL-Pardiso](https://software.intel.com/content/www/us/en/develop/documentation/mkl-developer-reference-fortran/top/sparse-solver-routines/intel-mkl-pardiso-parallel-direct-sparse-solver-interface.html) 
- [HSL solvers](http://www.hsl.rl.ac.uk/ipopt/) (optional) 
- [Pardiso](https://www.pardiso-project.org/) (optional) 
- [MKL-Lapack](https://software.intel.com/content/www/us/en/develop/documentation/mkl-developer-reference-fortran/top/lapack-routines.html)
- [cuSOLVER](https://docs.nvidia.com/cuda/cusolver/index.html) (optional)

All the dependencies except for HSL solvers, Pardiso, and CUDA are automatically installed. To build MadNLP with HSL linear solvers (Ma27, Ma57, Ma77, Ma86, Ma97), the source codes need to be obtained by the user from <http://www.hsl.rl.ac.uk/ipopt/> under Coin-HSL Full (Stable). Then, the tarball `coinhsl-2015.06.23.tar.gz` should be placed at `deps/download`. To use Pardiso, the user needs to obtain the Paridso shared libraries from <https://www.pardiso-project.org/>, place the shared library file (e.g., `libpardiso600-GNU720-X86-64.so`) at `deps/download`, and place the license file in the home directory. The absolute path for `deps/download` can be obtained by:
```julia
julia> import MadNLP; joinpath(dirname(pathof(MadNLP)),"..","deps","download")
```
To use cuSOLVER, functional NVIDIA driver and corresponding CUDA toolkit need to be installed by the user. After obtaining the files, run
```julia
pkg> build MadNLP
```
Build can be customized by setting the following environment variables.
```julia
julia> ENV["MADNLP_CC"] = "/usr/local/bin/gcc-9"    # default is "gcc"
julia> ENV["MADNLP_FC"] = "/usr/local/bin/gfortran" # default is "gfortran"
julia> ENV["MADNLP_BLAS"] = "openblas"              # default is "mkl" if available "openblas" otherwise
julia> ENV["MADNLP_ENALBE_OPENMP"] = false          # default is "true"
julia> ENV["MADNLP_OPTIMIZATION_FLAG"] = "-O2"      # default is "-O3"
```

Alternatively, if the user has already installed HSL/pardiso library, one can simply specify the library path as follows:
```julia
julia> ENV["MADNLP_HSL_LIBRARY_PATH"] = "/opt/lib/libcoinhsl.so"
julia> ENV["MADNLP_PARDISO_LIBRARY_PATH"] = "/opt/lib/libpardiso.so" 
```
In this case, the source code is not compiled and the provided shared library is directly used.

## Usage
MadNLP is interfaced with modeling packages: 
- [JuMP](https://github.com/jump-dev/JuMP.jl)
- [Plasmo](https://github.com/zavalab/Plasmo.jl)
- [NLPModels](https://github.com/JuliaSmoothOptimizers/NLPModels.jl).

### JuMP interface
```julia
using MadNLP, JuMP

model = Model(()->MadNLP.Optimizer(linear_solver=MadNLP.Ma57,print_level=MadNLP.INFO,max_iter=100))
@variable(model, x, start = 0.0)
@variable(model, y, start = 0.0)
@NLobjective(model, Min, (1 - x)^2 + 100 * (y - x^2)^2)

optimize!(model)

```

### Plasmo interface
```julia
using MadNLP, Plasmo

graph = OptiGraph()
@optinode(graph,n1)
@optinode(graph,n2)
@variable(n1,0 <= x <= 2)
@variable(n1,0 <= y <= 3)
@constraint(n1,x+y <= 4)
@objective(n1,Min,x)
@variable(n2,x)
@NLnodeconstraint(n2,exp(x) >= 2)
@linkconstraint(graph,n1[:x] == n2[:x])

MadNLP.optimize!(graph;linear_solver=MadNLP.Ma97,print_level=MadNLP.DEBUG,max_iter=100)

```

### NLPModels interface
```julia
using MadNLP, CUTEst
model = CUTEstModel("PRIMALC1")
madnlp(model,linear_solver=MadNLP.PardisoMKL,print_level=MadNLP.WARN,max_wall_time=3600)
```

### Using special linear solvers
In order to use GPU solvers, `CUDA` should be imported to the `Main` module.
```julia
using MadNLP, CUDA
model = Model(()->MadNLP.Optimizer(linear_solver=MadNLP.LapackGPU))
# ...
```

In order to use multi-threaded solvers (`Schur` and `Schwawrz`), julia session should be started with `-t` flag.
```sh
julia -t 16 # to use 16 threads
```

## Solver options
To see the list of MadNLP solver options, check the [OPTIONS.md](https://github.com/sshin23/MadNLP/blob/master/OPTIONS.md) file.
## Bug reports and support
Please report issues and feature requests via the [Github issue tracker](https://github.com/sshin23/MadNLP/issues).
