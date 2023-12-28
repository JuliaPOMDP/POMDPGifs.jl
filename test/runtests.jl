using Test

using POMDPGifs
using POMDPModels
using Cairo # to make Compose work

@testset "Basic call checks" begin
    mktempdir() do dir
        makegif(SimpleGridWorld(), filename=joinpath(dir, "test1.gif"))
        @test isfile(joinpath(dir, "test1.gif"))
        
        makegif(SimpleGridWorld(); 
            filename=joinpath(dir, "test2.gif"),
            spec=(:s, :a, :r),
            show_progress=true,
            max_steps=15
        )
        @test isfile(joinpath(dir, "test2.gif"))
        
        g = makegif(SimpleGridWorld(), 
            filename=joinpath(dir, "test3.gif"), 
            extra_initial=true, 
            extra_final=true
        )

        io = IOBuffer()
        Base.show(io, MIME("text/html"), g)
        @test String(take!(io)) == "<img src=\"$(joinpath(dir, "test3.gif"))\">\n"
        @test isfile(joinpath(dir, "test3.gif"))
    end
end
