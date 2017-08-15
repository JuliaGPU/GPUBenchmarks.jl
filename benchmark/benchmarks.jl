using PkgBenchmark, GPUBenchmarks

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
                        args = mod.setup(N, T, device)
                        @bench "$device for $T & $N" (result = mod.execute(args...))
                    end
                end
            end
        end
    end
end
