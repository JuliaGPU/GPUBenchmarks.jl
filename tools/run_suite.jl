using GPUBenchmarks, BenchmarkTools, FileIO

benchmark_files = [
   # "blackscholes",
    #"PDE",
    "poincare",
    "juliaset",
    "mapreduce"
]

GPUBenchmarks.new_run()


for device in GPUBenchmarks.devices()
    name, typ = GPUBenchmarks.init(device)
    @show name typ
end

device = first(GPUBenchmarks.devices())
nothing
file = "juliaset"
device = :cuarrays


for file in benchmark_files
    # for device in GPUBenchmarks.devices()
        @run_julia (JULIA_NUM_THREADS = 8, "-O3", file, device) begin
            using GPUBenchmarks, BenchmarkTools, FileIO
            bench_mod = include(GPUBenchmarks.dir("benchmark", file * ".jl"))
            println("Benchmarking $file $device")
            result = bench_mod.execute(device)
            println("Benchmarking done for $device")
            GPUBenchmarks.append_data!(result)
        end
    # end
end

GPUBenchmarks.last_time_stamp()