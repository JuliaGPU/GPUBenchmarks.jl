using GPUBenchmarks, BenchmarkTools, FileIO

benchmark_files = [
    "blackscholes",
]
results = Dict()

for file in benchmark_files
    suite = Dict()
    results[file] = suite
    mod = include(GPUBenchmarks.dir("benchmark", file * ".jl"))
    for device in GPUBenchmarks.devices()
        range = Float64[]
        trials = []
        for T in mod.types()
            if mod.is_device_supported(device)
                for N in mod.nrange()
                    println("Benchmarking $N $T $device")
                    try
                        b = mod.execute(N, T, device)
                        push!(range, N)
                        push!(trials, b)
                    catch e
                        warn(e)
                        Base.show_backtrace(STDERR, backtrace())
                        push!(range, N)
                        push!(trials, e)
                    end
                end
            end
        end
        range, trials
        suite[device] = (range, trials)
    end
end
