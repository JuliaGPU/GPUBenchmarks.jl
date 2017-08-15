using GPUBenchmarks
using Base.Test
using PkgBenchmark

x = benchmarkpkg(
    "GPUBenchmarks",
    resultsdir = joinpath(@__DIR__, "..", "results"),
    saveresults = true,
    promptsave = false,
    promptoverwrite = false
)

for (suitname, benchsuite) in x
    for (name, bench) in benchsuite
        println(name)
    end
end
