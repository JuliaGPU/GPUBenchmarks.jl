module JuliaSet

using GPUBenchmarks, BenchmarkTools
import CUDAnative, ArrayFire
using ArrayFire: @afgc

description = """
julia set benchmark
generated functions allow you to emit specialized code for the argument types.
"""

@generated function juliaset_unrolled{N}(z, maxiter::Val{N})
    unrolled = Expr(:block)
    for i=1:N
        push!(unrolled.args, quote
            abs2(z2) > 4f0 && return UInt8($(i-1))
            z2 = z2 * z2 + c
        end)
    end
    quote
        c = Complex64(-0.5, 0.75)
        z2 = z
        $unrolled
        return UInt8($N)
    end
end
# Somehow CuArrays broadcast doesn't support res .= juliaset_unrolled(q, Val{50}())
juliaset_50(z) = juliaset_unrolled(z, Val{50}())
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
    z = z0
    for n in 1:maxiter
        z = z .* z .+ Complex64(-0.5, 0.75)
        count .= count .+ (abs2(z) <= 4)
    end
    count
end


# using FileIO, Colors
# save(Pkg.dir("GPUArrays", "examples", "juliaset.png"), Gray.(Array(mg) ./ 16.0))

nrange() = map(x-> (2^x) ^ 2, 6:1:12)
types() = (Float32,)
is_device_supported(dev) = true

function execute(N, T, device)
    ctx, array_type = init(device)
    nsqrt = round(Int, sqrt(N))
    w, h = nsqrt, nsqrt

    q = [Complex64(r, i) for i=1:-(2.0/w):-1, r=-1.5:(3.0/h):1.5]


    q_gpu = array_type(q)
    result_gpu = array_type(zeros(UInt8, size(q_gpu)))
    bench = if is_arrayfire(device)
        @benchmark $(juliaset_af)($q_gpu, $result_gpu, 50)
        ArrayFire.afgc()
    else
        @benchmark ($(result_gpu) .= $(juliaset_50).($q_gpu))
    end
    free(q_gpu); free(result_gpu);
    gc()
    return bench
end


end
