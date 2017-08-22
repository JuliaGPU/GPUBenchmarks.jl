module JuliaSetUnrolled

using GPUBenchmarks, BenchmarkTools
import CUDAnative, ArrayFire
using ArrayFire: @afgc

description = """
The Julia Set benchmark.
The unrolled benchmark uses generated functions to emit an unrolled version of the inner loop.
This currently doesn't yield a speed up, but was quite a bit faster in the initial tests.
Needs some further research of why this slowed down - Potentially an N == 16 for the inner iteration is too big.
Image of the benchmarked juliaset:
![]("https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/juliaset_result.png?raw=true")
"""


function juliaset(z0, maxiter)
    c = Complex64(-0.5, 0.75)
    z = z0
    for i=1:maxiter
        abs2(z) > 4f0 && return UInt8(i - 1)
        z = z * z + c
    end
    return UInt8(maxiter)
end

@afgc function juliaset_af(z0, count, maxiter)
    fill!(count, 0)
    z = z0
    c = Complex64(-0.5, 0.75)
    for n in 1:maxiter
        z = z .* z .+ c
        count .= count .+ (abs2.(z) .<= 4)
    end
    count
end

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
juliaset_16(z) = juliaset_unrolled(z, Val{16}())

# using FileIO, Colors
# save(Pkg.dir("GPUArrays", "examples", "juliaset.png"), Gray.(Array(mg) ./ 16.0))

# the benchmark file will get included when the benchmark is run,
# so this should be a good time stamp for the suite

function makeresult(name, bench, N, device, hardware, mdiff)
    BenchResult(
        name,
        bench,
        N,
        Complex64,
        string(device),
        hardware,
        @__FILE__,
        mdiff
    )
end


function execute(device)
    hardware, array_type = init(device)
    results = BenchResult[]
    # arrayfire makes to many problems right now
    is_arrayfire(device) && return results
    for N in 6:12
        w, h = 2^N, 2^N
        println("    N: ", w * h)
        q = [Complex64(r, i) for i=1:-(2.0/w):-1, r=-1.5:(3.0/h):1.5]

        q_gpu = array_type(q)
        result_gpu = array_type(zeros(UInt8, size(q_gpu)))

        jl_result = zeros(UInt8, size(q_gpu))
        jl_result .= juliaset.(q, 16)
        bench = if is_arrayfire(device)
            @benchmark begin
                $(juliaset_af)($q_gpu, $result_gpu, 16)
                synchronize($result_gpu)
                ArrayFire.afgc()
            end
        else
            @benchmark begin
                $(result_gpu) .= $(juliaset).($q_gpu, 16)
                synchronize($result_gpu)
            end
        end

        meandiff = meandifference(jl_result, result_gpu)
        println("    juliaset: ", meandiff)
        push!(results, makeresult("Juliaset", bench, w * h, device, hardware, meandiff))

        bench = @benchmark begin
            ($(result_gpu) .= $(juliaset_16).($q_gpu))
            synchronize($result_gpu)
        end
        meandiff = meandifference(jl_result, result_gpu)
        println("    juliaset unrolled: ", meandiff)
        push!(results, makeresult("Juliaset Unrolled", bench, w * h, device, hardware, meandiff))

        free(q_gpu); free(result_gpu);
        gc()
    end
    return results
end


# using FileIO, Interpolations, Colors, GPUBenchmarks, GPUArrays, ColorVectorSpace, FixedPointNumbers
# device = :opencl
# hardware, array_type = init(device)
# w, h = 512, 512
# q = [Complex64(r, i) for i=1:-(2.0/w):-1, r=-1.5:(3.0/h):1.5]
# q_gpu = array_type(q)
# result_gpu = array_type(zeros(UInt8, size(q_gpu)))
# result_gpu .= juliaset.(q_gpu, 50)
# cn = 100
# cmap = interpolate(colormap("Oranges", cn), BSpline(Linear()), OnCell());
# img_color = map(Array(result_gpu)) do val
#     val = val / 50.0
#     val = 1 - clamp(val, 0f0, 1f0);
#     idx = (val * (cn - 1)) + 1.0
#     RGB{N0f8}(cmap[idx])
# end
# #save as an image
# save(GPUBenchmarks.dir("results", "plots", "juliaset_result.png"), img_color)

end
