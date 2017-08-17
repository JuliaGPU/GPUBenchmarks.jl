module Poincare

using GPUBenchmarks, BenchmarkTools, GPUArrays
import CUDAnative

const cu = CUDAnative
description = """
Poincare section of a chaotic neuronal network

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

nrange() = map(x-> 10 ^ x, 3:1:9)
is_device_supported(dev) = is_gpuarrays(dev) || dev == :julia_base
types() = (Float32,)

function poincare_inner(n, seeds::GPUArray, result, c, π, val::Val{N}) where N
    foreach(poincare_inner, seeds, result, c, Float32(pi), val, n)
end
function poincare_inner(n, seeds::Array, result, c, π, val::Val{N}) where N
    for rv in seeds
        poincare_inner(rv, result[], c, π, val, n)
    end
end

function execute(N, T, device)
    ctx, AT = init(device)
    c = 1f0; divisor = 2^11
    srand(2)
    ND = Cuint(1024)
    result = AT(zeros(Float32, ND, ND))
    _n = div(N, divisor)
    seeds = AT([ntuple(i-> rand(Float32), Val{3}) for x in 1:divisor])
    b = @benchmark begin
        $(poincare_inner)($ND, $seeds, $(Base.RefValue(result)), $c, $(Float32(pi)), $(Val{_n}()))
        synchronize($(result)) # synchronize for the benchmark
    end
    b
end

end
