# Compare benchmarks
using GPUBenchmarks, BenchmarkTools
db = GPUBenchmarks.get_database()
using GPUBenchmarks: name, timestamp

timestamp = last(sort(unique(timestamp.(db))))

newbenchs = filter(x-> x.timestamp == timestamp, db)
oldbenchs = filter(x-> x.device == "opencl", db)
old_newest_ts = last(sort(unique(GPUBenchmarks.timestamp.(oldbenchs))))
oldbenchs = filter(x-> x.timestamp == old_newest_ts, oldbenchs)

sort(unique(GPUArrays.name.(db)))

for elem in unique(GPUBenchmarks.name.(newbenchs))
    A = filter(x-> x.name == elem, oldbenchs)
    B = filter(x-> x.name == elem, oldbenchs)
    for (a, b) in zip(A, B)
        x = judge(minimum(a.benchmark), minimum(b.benchmark))
        if x.time != :invariant
            println(name)
            @show x
        end
    end
end
