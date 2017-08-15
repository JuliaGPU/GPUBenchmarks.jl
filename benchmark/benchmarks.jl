ENV["TRACE"] = 1
using PkgBenchmark, GPUBenchmarks, BenchmarkTools

benchmark_files = [
    "blackscholes",
]

for file in benchmark_files
    mod = include(file * ".jl")
    @benchgroup file begin
        for T in mod.types()
            for device in GPUBenchmarks.devices()
                if mod.is_device_supported(device)
                    for N in mod.nrange()
                        println("Benchmarking $N, $T $device")
                        # result = mod.execute(f, args)
                        dev_quote = QuoteNode(device)
                        b = @benchmarkable $(mod.execute)(f, args) setup = ((f, args) = $(mod.setup)($N, $T, $dev_quote)) teardown = $(mod.teardown)(args)
                        PkgBenchmark._top_group()["$device for $T & $N"] = b
                    end
                end
            end
        end
    end
end
