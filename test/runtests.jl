using Test

using POMDPGifs
using POMDPModels
using Cairo # to make Compose work

@testset "Basic call checks" begin
  @test_nowarn makegif(SimpleGridWorld())
  @test_nowarn makegif(SimpleGridWorld(), extra_initial=true, extra_final=true)
end
