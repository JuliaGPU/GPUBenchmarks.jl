using GPUBenchmarks
using Base.Test
using PkgBenchmark

benchmarkpkg(
    "GPUBenchmarks",
    resultsdir = joinpath(@__DIR__, "..", "results"),
    saveresults = true,
    promptsave = false,
    promptoverwrite = false
)
