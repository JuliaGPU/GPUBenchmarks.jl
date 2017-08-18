using GPUBenchmarks, BenchmarkTools, FileIO

benchmark_files = [
    "blackscholes",
    "PDE",
    "poincare"
]

for file in benchmark_files
    @run_julia (JULIA_NUM_THREADS = 8, "-O3",  "--math-mode=fast") begin
        using GPUBenchmarks, BenchmarkTools, FileIO
        file = "blackscholes"
        suite = Dict()
        bench_mod = include(GPUBenchmarks.dir("benchmark", file * ".jl"))
        for device in GPUBenchmarks.devices()
            range = Float64[]
            trials = []
            for T in bench_mod.types()
                if bench_mod.is_device_supported(device)
                    for N in bench_mod.nrange()
                        println("Benchmarking $N $T $device")
                        try
                            b = bench_mod.execute(N, T, device)
                            push!(range, N)
                            push!(trials, b)
                        catch e
                            warn(e)
                            Base.show_backtrace(STDERR, backtrace())
                            push!(range, N)
                            push!(trials, e)
                        end
                    end
                    range, trials
                    suite[string(device)] = (range, trials)
                end
            end
        end
        save_result(suite, file)
    end
end
