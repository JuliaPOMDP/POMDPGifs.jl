using Test

using POMDPGifs
using POMDPModels
using Cairo # to make Compose work

@testset "Basic call checks" begin
    try
        makegif(SimpleGridWorld(), filename="test.gif")
        rm("test.gif")
        @test true
    catch
        @test false
    end
    try
        makegif(SimpleGridWorld(), filename="test.gif", extra_initial=true, extra_final=true)
        rm("test.gif")
        @test true
    catch
        @test false
    end
end
