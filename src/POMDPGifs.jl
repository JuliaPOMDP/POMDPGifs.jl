module POMDPGifs

using Reel
using POMDPs
using POMDPSimulators
using POMDPModelTools
using POMDPPolicies
using ProgressMeter
using Parameters
using Random

export
    GifSimulator,
    makegif

struct SavedGif
    filename::String
end

function Base.show(io::IO, m::MIME"text/html", g::SavedGif)
    println(io, "<img src=\"$(g.filename)\">")
end

"""
    GifSimulator(<keyword arguments>)

Create a simulator for producing a gif output by calling `POMDPModelTools.render` at each step.

# Keyword Arguments
- `filename::String=tempname()*".gif"`
- `fps::Int=2`: frames per second
- `spec::Any`: specification for which elements of a step to render (see `POMDPSimulators.eachstep`)
- `max_steps::Int=nothing`
- `rng::AbstractRNG=GLOBAL_RNG`
- `show_progress::Bool`
- `extra_initial::Bool` if set to true, the simulator adds an extra step at time 0 (before first transition)
- `extra_final::Boll` if set to true, the simulator adds an extra setp at the end (after the last transition)
- `render_kwargs`: keyword args to be fed to `POMDPModelTools.render`
"""
@with_kw mutable struct GifSimulator <: Simulator
    filename::String                = tempname()*".gif"
    fps::Int                        = 2
    spec::Union{Nothing, Any}       = nothing
    max_steps::Union{Nothing, Int}  = nothing
    rng::AbstractRNG                = Random.GLOBAL_RNG
    show_progress::Bool             = max_steps != nothing
    extra_initial::Bool             = false
    extra_final::Bool               = false
    render_kwargs                   = NamedTuple()
end

function POMDPs.simulate(s::GifSimulator, m::Union{MDP, POMDP}, p::Policy=RandomPolicy(m, rng=s.rng), args...)

    # run simulation
    sim = HistoryRecorder(rng = s.rng,
                          max_steps = s.max_steps,
                          show_progress = s.show_progress
                         )
    hist = simulate(sim, m, p, args...)

    makegif(m, hist,
            filename=s.filename,
            spec=s.spec,
            show_progress=s.show_progress,
            extra_initial=s.extra_initial,
            extra_final=s.extra_final,
            render_kwargs=s.render_kwargs,
            fps=s.fps
           )
end

"""
    makegif(m; kwargs...)
    makegif(m, policy; kwargs...)
    makegif(m, policy, args...; kwargs...)

Create a gif of a single simulation of a POMDP or MDP by calling `POMDPModelTools.render` at each step.

# Arguments
- `m::Union{POMDP,MDP}`: the model to be simulated

All other positional arguments, for instance a policy, updater, initial state, etc. will be fed to the `simulate` function. See that documentation for more info.

# Keyword Arguments
All keyword arguments are fed to the `GifSimulator` constructor. See its documentation for more info.
"""
function makegif(args...; kwargs...)
    sim = GifSimulator(;kwargs...)
    return simulate(sim, args...)
end

"""
    makegif(m, history; kwargs...)

Create a gif from a POMDP or MDP and a history by calling `POMDPModelTools.render` at each step.

# Arguments
- `m::Union{POMDP,MDP}`: domain model
- `history::POMDPSimulators.SimHistory`: history of states, actions, etc. for the gif

# Keyword Arguments
- `filename::String=tempname()*".gif"`
- `fps::Int=2`: frames per second
- `spec::Any`: specification for which elements of a step to render (see `POMDPSimulators.eachstep`)
- `show_progress::Bool`
- `extra_initial::Bool` if set to true, the simulator adds an extra step at time 0 (before first transition)
- `extra_final::Bool` if set to true, the simulator adds an extra setp at the end (after the last transition)
- `render_kwargs`: keyword args to be fed to `POMDPModelTools.render`
"""
function makegif(m::Union{POMDP, MDP}, hist::POMDPSimulators.SimHistory;
                 filename=tempname()*".gif",
                 spec=nothing,
                 show_progress::Bool=true,
                 extra_initial::Bool=false,
                 extra_final::Bool=false,
                 render_kwargs=NamedTuple(),
                 fps::Int=2
                )

    # deal with the spec
    if spec == nothing
        steps = eachstep(hist)
    else
        steps = eachstep(hist, spec)
    end

    if extra_initial
        first_step = first(steps)
        extra_init_step = (t=0, sp=get(first_step, :s, missing), bp=get(first_step, :b, missing))
        steps = vcat(extra_init_step, collect(steps))
    end
    if extra_final
        last_step = last(steps)
        extra_final_step = (t=length(steps)+1, s=get(last_step, :sp, missing), b=get(last_step, :bp, missing), done=true)
        steps = vcat(collect(steps), extra_final_step)
    end

    # create gif
    frames = Frames(MIME("image/png"), fps=fps)
    if show_progress
        p = Progress(length(steps), 0.1, "Rendering $(length(steps)) steps...")
    end

    for step in steps
        push!(frames, render(m, step; pairs(render_kwargs)...))
        if show_progress
            next!(p)
        end
    end
    if show_progress
        @info "Creating Gif..."
    end
    write(filename, frames)
    if show_progress
        @info "Done Creating Gif."
    end
    return SavedGif(filename)
end

end # module
