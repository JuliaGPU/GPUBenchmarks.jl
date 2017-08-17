using GPUBenchmarks
using Base.Test
using PkgBenchmark

result = benchmarkpkg(
    "GPUBenchmarks",
    resultsdir = joinpath(@__DIR__, "..", "results"),
    saveresults = false,
    promptsave = false,
    promptoverwrite = false
)


using Plots, FileIO, BenchmarkTools, PkgBenchmark; gr()

results = result
benchsuits = results
p = plot()
nfirst = Dict(); nlast = Dict()
for (suitname, suite) in benchsuits
    for (T, tbench) in suite
        for (dev, dbench) in tbench
            times = Float64[]; widths = Float64[]; xaxis = Float64[]
            bench_array = collect(dbench)
            sort!(bench_array, by = first)
            _n, trial_first = first(bench_array)
            nfirst[dev] = trial_first
            _n, trial_last = last(bench_array)
            nlast[dev] = trial_last
            for (N, trial) in bench_array
                push!(times, minimum(trial).time / 10^9)
                push!(widths, mean(trial).time / 10^9)
                push!(xaxis, N)
            end
            println(widths)
            plot!(p, xaxis, times, label = dev)
        end
    end
end
display(p)

@show first(benchsuits)[2][string(Float32)]["opencl"][100]
