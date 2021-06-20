# POMDPGifs.jl

[![Build status](https://github.com/JuliaPOMDP/POMDPGifs.jl/workflows/CI/badge.svg)](https://github.com/JuliaPOMDP/POMDPGifs.jl/actions)

Utilities for generating gifs of [POMDPs.jl](https://github.com/JuliaPOMDP/POMDPs.jl) models.

## Installation 

In the julia REPL:
```julia
import Pkg; Pkg.add("POMDPGifs")
```

## Documentation

Currently, there are two utilities:
- A `GifSimulator` to be used with the `simulate` function.
- A `makegif` convenience function to (1) run a simulation and create a gif, or (2) create a gif from a model.

### GifSimulator
`GifSimulator(kwargs...)`. Create a simulator for producing a gif output by calling `POMDPModelTools.render` at each step.

**Keyword Arguments**
- `filename::String=tempname()*".gif"`
- `fps::Int=2`: frames per second
- `spec::Any`: specification for which elements of a step to render (see `POMDPSimulators.eachstep`)
- `max_steps::Int=nothing`
- `rng::AbstractRNG=GLOBAL_RNG`
- `show_progress::Bool`
- `extra_initial::Bool` if set to true, the simulator adds an extra step at time 0 (before first transition)
- `extra_final::Boll` if set to true, the simulator adds an extra setp at the end (after the last transition)
- `render_kwargs`: keyword args to be fed to `POMDPModelTools.render`

### makegif

```julia
makegif(m; kwargs...)
makegif(m, policy; kwargs...)
makegif(m, policy, args...; kwargs...)
```
Create a gif of a single simulation of a POMDP or MDP by calling `POMDPModelTools.render` at each step.

**Arguments:**
- `m::Union{POMDP,MDP}`: the model to be simulated

All other positional arguments, for instance a policy, updater, initial state, etc. will be fed to the `simulate` function. See [POMDPSimulators documentation](https://juliapomdp.github.io/POMDPSimulators.jl/latest/) for more info.

**Keyword Arguments**
All keyword arguments are fed to the `GifSimulator` constructor. See its documentation for more info.
