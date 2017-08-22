module Poincare

using GPUBenchmarks, BenchmarkTools, GPUArrays
import CUDAnative

const cu = CUDAnative
description = """
Poincare section of a chaotic neuronal network.
The domination of OpenCL in this benchmark might be due to a better use of vector intrinsics in Transpiler.jl, but needs some
more investigations.
Result of calculation:
![]("https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/poincare_result.png?raw=true")
"""

# Original poincare implementation by https://github.com/RainerEngelken
# GPU version by Simon Danisch

function poincare_inner{N}(rv, result::CUDAnative.CuDeviceArray, c, π, ::Val{N}, n)
    # find next spiking neuron
    ϕ₁, ϕ₂, ϕ₃ = rv[1], rv[2], rv[3]
    πh = π / 2f0
    π2 = π * 2f0
    for unused = 1:N
        if ϕ₁ > ϕ₂
            if ϕ₁ > ϕ₃
                # first neuron is spiking
                dt = πh - ϕ₁
                # evolve phases till next spike time
                ϕ₁ = -πh
                ϕ₂ = cu.atan(cu.tan(ϕ₂ + dt) - c)
                ϕ₃ += dt
                # save state of neuron 2 and 3
                x = Cuint(cu.max(cu.ceil(((ϕ₂ + πh) / π) * (Float32(n) - 1f0)) + 1f0, 1f0))
                y = Cuint(cu.max(cu.ceil(((ϕ₃ + πh) / π) * (Float32(n) - 1f0)) + 1f0, 1f0))
                i1d = GPUArrays.gpu_sub2ind((n, n), (x, y)) # convert to linear index
                accum = result[i1d]
                # this is unsafe, since it could read + write from different threads, but good enough for the stochastic kind of process we're doing
                result[i1d] = accum + 1f0
                continue
            end
        else
            if ϕ₂ > ϕ₃
                # second neuron is spiking
                dt = πh - ϕ₂
                # evolve phases till next spike time
                ϕ₁ += dt
                ϕ₂ = -πh
                ϕ₃ = cu.atan(cu.tan(ϕ₃ + dt) - c)
                continue
            end
        end
        # third neuron is spikinga
        dt = πh - ϕ₃
        # evolve phases till next spike time
        ϕ₁ += dt
        ϕ₂ = cu.atan(cu.tan(ϕ₂ + dt) - c)
        ϕ₃ = -πh
    end
    return
end

function poincare_inner{N}(rv, result, c, π, ::Val{N}, n)
    # find next spiking neuron
    ϕ₁, ϕ₂, ϕ₃ = rv[1], rv[2], rv[3]
    πh = π / 2f0
    π2 = π * 2f0
    for unused = 1:N
        if ϕ₁ > ϕ₂
            if ϕ₁ > ϕ₃
                # first neuron is spiking
                dt = πh - ϕ₁
                # evolve phases till next spike time
                ϕ₁ = -πh
                ϕ₂ = atan(tan(ϕ₂ + dt) - c)
                ϕ₃ += dt
                # save state of neuron 2 and 3
                x = Cuint(max(round(((ϕ₂ + πh) / π) * (Float32(n) - 1f0)) + 1f0, 1f0))
                y = Cuint(max(round(((ϕ₃ + πh) / π) * (Float32(n) - 1f0)) + 1f0, 1f0))
                i1d = GPUArrays.gpu_sub2ind((n, n), (x, y)) # convert to linear index
                accum = result[i1d]
                # this is unsafe, since it could read + write from different threads, but good enough for the stochastic kind of process we're doing
                result[i1d] = accum + 1f0
                continue
            end
        else
            if ϕ₂ > ϕ₃
                # second neuron is spiking
                dt = πh - ϕ₂
                # evolve phases till next spike time
                ϕ₁ += dt
                ϕ₂ = -πh
                ϕ₃ = atan(tan(ϕ₃ + dt) - c)
                continue
            end
        end
        # third neuron is spikinga
        dt = πh - ϕ₃
        # evolve phases till next spike time
        ϕ₁ += dt
        ϕ₂ = atan(tan(ϕ₂ + dt) - c)
        ϕ₃ = -πh
    end
    return
end

function poincare_inner(n, seeds::GPUArray, result, c, π, val::Val{N}) where N
    foreach(poincare_inner, seeds, result, c, Float32(pi), val, n)
end
function poincare_inner(n, seeds::Array, result, c, π, val::Val{N}) where N
    for rv in seeds
        poincare_inner(rv, result[], c, π, val, n)
    end
end


function makeresult(bench, N, device, hardware, mdiff)
    BenchResult(
        "Poincare",
        bench,
        N,
        Float32,
        string(device),
        hardware,
        @__FILE__,
        mdiff
    )
end

function execute(device)
    results = BenchResult[]
    is_gpuarrays(device) || device == :julia_base || return results
    hardware, AT = init(device)
    c = 1f0; divisor = 2^11
    srand(2)
    for i = 3:9
        N = 10^i
        ND = Cuint(1024)
        result = AT(zeros(Float32, ND, ND))
        _n = div(N, divisor)
        seeds = AT([ntuple(i-> rand(Float32), Val{3}) for x in 1:divisor])
        bench = @benchmark begin
            $(poincare_inner)($ND, $seeds, $(Base.RefValue(result)), $c, $(Float32(pi)), $(Val{_n}()))
            synchronize($(result)) # synchronize for the benchmark
        end
        jl_results = zeros(Float32, ND, ND)
        result = AT(jl_results)
        _n = div(N, divisor)
        jl_seeds = [ntuple(i-> rand(Float32), Val{3}) for x in 1:divisor]
        seeds = AT(jl_seeds)
        poincare_inner(ND, seeds, Base.RefValue(result), c, Float32(pi), Val{_n}())
        poincare_inner(ND, jl_seeds, Base.RefValue(jl_results), c, Float32(pi), Val{_n}())
        mdiff = meandifference(jl_results, result)
        @show mdiff
        push!(results, makeresult(bench, N, device, hardware, mdiff))
    end
    results
end

# using FileIO, Interpolations, Colors, GPUBenchmarks, GPUArrays, ColorVectorSpace, FixedPointNumbers
# device = :opencl
# hardware, AT = init(device)
# N = 10^9
# ND = Cuint(512)
# result = AT(zeros(Float32, ND, ND))
# divisor = 2^11
# _n = div(N, divisor)
# seeds = AT([ntuple(i-> rand(Float32), Val{3}) for x in 1:divisor])
# _n = div(N, divisor)
# c = 1f0
# seeds = AT([ntuple(i-> rand(Float32), Val{3}) for x in 1:divisor])
# poincare_inner(ND, seeds, Base.RefValue(result), c, Float32(pi), Val{_n}())
# synchronize(result)
# cn = 100
# cmap = interpolate(colormap("Oranges", cn), BSpline(Linear()), OnCell());
# img_color = map(Array(result)) do val
#     val = val / 2000f0
#     val = clamp(val, 0f0, 1f0);
#     idx = (val * (cn - 1)) + 1.0
#     RGB{N0f8}(cmap[idx])
# end
# #save as an image
# save(GPUBenchmarks.dir("results", "plots", "poincare_result.png"), img_color)


end
