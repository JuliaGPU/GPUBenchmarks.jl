using GPUBenchmarks, BenchmarkTools, FileIO

benchmark_files = [
    "blackscholes",
    "PDE",
    "poincare",
    "juliaset",
    "julia_unrolled"
]

# for file in benchmark_files
    @run_julia (JULIA_NUM_THREADS = 8, "-O3",  "--math-mode=fast") begin
        using GPUBenchmarks, BenchmarkTools, FileIO
        file = "juliaset_unrolled"
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
        # JLD is a bit brittle, so lets just in case save it with serializer
        open(GPUBenchmarks.datapath!(current_version(), file * ".jls"), "w") do io
            serialize(io, suite)
        end
        save_result(suite, file)
    end
# end

using  GPUArrays, BenchmarkTools
N = 2048
w, h = N, N

q = [Complex64(r, i) for i=1:-(2.0/w):-1, r=-1.5:(3.0/h):1.5]

function juliaset(z0, maxiter)
    c = Complex64(-0.5, 0.75)
    z = z0
    for i=1:maxiter
        abs(z) > 2f0 && return UInt8(i)
        z = z * z + c
    end
    return UInt8(maxiter)
end
using CuArrays
CLBackend.init()
array_type = CuArray
q_gpu = array_type(q)
result_gpu = array_type(zeros(UInt8, size(q_gpu)))
result_gpu .= juliaset.(q_gpu, 50);

jl_results = zeros(UInt8, size(q_gpu))
jl_results .= juliaset.(q, 50);
N / 40
find(x-> !x, jl_results .≈ Array(result_gpu))
b1 = @benchmark begin
    $result_gpu .= juliaset.($q_gpu, 50)
    Array($result_gpu)
end


array_type = GPUArray
CUBackend.init()
q_gpu = array_type(q)
result_gpu = array_type(zeros(UInt8, size(q_gpu)))
result_gpu .= juliaset.(q_gpu, 50)
b2 = @benchmark begin
    $result_gpu .= juliaset.($q_gpu, 50)
    Array($result_gpu)
end
using FileIO, Colors
save(joinpath(homedir(), "juliaset.png"), Gray.(Array(result_gpu) ./ 16.0))
judge(minimum(b1), minimum(b2))

 minimum(b1)

using GPUArrays
using Transpiler.cli: get_group_id, get_global_size, get_local_id, get_local_size, get_global_id
CLBackend.init()
A = GPUArray(zeros(Cuint, 1024))
gpu_call(A, (A,)) do state, a
    x = get_local_size(0)*get_group_id(0) + get_local_id(0) + Cuint(1)
    a[x] = x
    return
end
println(Int.(Array(A)))
256 * 256
