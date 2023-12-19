using Test

using POMDPGifs
using POMDPModels
using Cairo # to make Compose work

@testset "Basic call checks" begin
    try
        makegif(SimpleGridWorld(), filename="test1.gif")
        rm("test1.gif")
        @test true
    catch
        @test false
    end
    
    try
        makegif(SimpleGridWorld(); 
            filename="test2.gif",
            spec=(:s, :a, :r),
            show_progress=true,
            max_steps=15
        )
        rm("test2.gif")
        @test true
    catch
        @test false
    end
    
    try
        g = makegif(SimpleGridWorld(), filename="test3.gif", extra_initial=true, extra_final=true)

        io = IOBuffer()
        Base.show(io, MIME("text/html"), g)
        @test String(take!(io)) == "<img src=\"test3.gif\">\n"
        
        rm("test3.gif")
        @test true
    catch
        @test false
    end
end
