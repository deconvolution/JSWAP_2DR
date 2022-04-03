# JSWAP

## Contents
* [Target](#Target)
* [Highlights](#Highlights)
* [Installation](#Installation)
* [Dependencies](#Dependencies)
* [Usage](#Usage)

## Installation
Install Julia on OS first. Then, in an IDE with Julia installed (e.g., [Atom](https://atom.io/)), one can install this package by
```julia
julia> ]
(@v1.6) pkg> add https://github.com/deconvolution/JSWAP
```
You can test whether it works on your system with
```julia
julia> ]
(@v1.6) pkg> test JSWAP
```
and use it with
```julia
julia> using JSWAP
```
## Dependencies
JSWAP dependes on [ParallelStencil.jl](https://github.com/omlins/ParallelStencil.jl), [CUDA](https://github.com/JuliaGPU/CUDA.jl), and [WriteVTK.jl](https://github.com/jipolanco/WriteVTK.jl). They will be installed automatically under JSWAP and there is no need to install them separately.
## Usage
You can find the [manual](https://deconvolution.github.io/JSWAP/dev/) for details, which explains input, output and some utilities.
