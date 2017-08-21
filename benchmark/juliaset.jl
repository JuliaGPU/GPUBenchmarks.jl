module JuliaSet

using GPUBenchmarks, BenchmarkTools
import CUDAnative, ArrayFire
using ArrayFire: @afgc

description = """
julia set benchmark
"""


function juliaset(z0, maxiter)
    c = Complex64(-0.5, 0.75)
    z = z0
    for i=1:maxiter
        abs2(z) > 4f0 && return UInt8(i)
        z = z * z + c
    end
    return UInt8(maxiter)
end

@afgc function juliaset_af(z0, count, maxiter)
    fill!(count, 1)
    z = z0
    c = Complex64(-0.5, 0.75)
    for n in 1:maxiter
        z = z .* z .+ c
        count .= count .+ (abs2.(z) .<= 4)
    end
    count
end


# using FileIO, Colors
# save(Pkg.dir("GPUArrays", "examples", "juliaset.png"), Gray.(Array(mg) ./ 16.0))

nrange() = map(x-> (2^x) ^ 2, 6:1:12)
types() = (Float32,)
is_device_supported(dev) = !is_arrayfire(dev)

function execute(N, T, device)
    ctx, array_type = init(device)
    nsqrt = round(Int, sqrt(N))
    w, h = nsqrt, nsqrt

    q = [Complex64(r, i) for i=1:-(2.0/w):-1, r=-1.5:(3.0/h):1.5]


    q_gpu = array_type(q)
    result_gpu = array_type(zeros(UInt8, size(q_gpu)))
    jl_result = zeros(UInt8, size(q_gpu))
    jl_result .= juliaset.(q, 50)

    bench = if is_arrayfire(device)
        @benchmark begin
            $(juliaset_af)($q_gpu, $result_gpu, 50)
            synchronize($result_gpu)
            ArrayFire.afgc()
        end
    else
        @benchmark begin
            $(result_gpu) .= $(juliaset).($q_gpu, 50)
            synchronize($result_gpu)
        end
    end
    @assert(count(x-> !x, jl_result .≈ Array(result_gpu)) < N / 40, "backend $device yielded different result")

    free(q_gpu); free(result_gpu);
    gc()
    return bench
end
execute(4096, Float32, :opencl)

end
