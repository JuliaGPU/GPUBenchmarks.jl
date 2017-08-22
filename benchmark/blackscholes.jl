module Blackscholes

using GPUBenchmarks, ArrayFire, BenchmarkTools
import CUDAdrv

using CUDAnative
const cu = CUDAnative

const description = """
Blackschole is a nice benchmark for broadcasting performance.
It's a medium heavy calculation per array element, where the calculation is completely
independant from each other.
"""

function blackscholes(
        sptprice,
        strike,
        rate,
        volatility,
        time
    )
    logterm = log( sptprice / strike)
    powterm = .5f0 * volatility * volatility
    den = volatility * sqrt(time)
    d1 = (((rate + powterm) * time) + logterm) / den
    d2 = d1 - den
    NofXd1 = cndf2(d1)
    NofXd2 = cndf2(d2)
    futureValue = strike * exp(-rate * time)
    c1 = futureValue * NofXd2
    call_ = sptprice * NofXd1 - c1
    put  = call_ - futureValue + sptprice
    return put
end
@afgc function blackscholes_af(
        sptprice,
        strike,
        rate,
        volatility,
        time
    )
    logterm = log( sptprice / strike)
    powterm = .5f0 * volatility * volatility
    den = volatility * sqrt(time)
    d1 = (((rate + powterm) * time) + logterm) / den
    d2 = d1 - den
    NofXd1 = cndf2(d1)
    NofXd2 = cndf2(d2)
    futureValue = strike * exp(-rate * time)
    c1 = futureValue * NofXd2
    call_ = sptprice * NofXd1 - c1
    put  = call_ - futureValue + sptprice
    return put
end

@inline function cndf2(x)
    0.5f0 + 0.5f0 * erfc(0.707106781f0 * x)
end

function cu_blackscholes(sptprice, strike, rate, volatility, time)
    logterm = cu.log( sptprice / strike)
    powterm = .5f0 * volatility * volatility
    den = volatility * cu.sqrt(time)
    d1 = (((rate + powterm) * time) + logterm) / den
    d2 = d1 - den
    NofXd1 = cu_cndf2(d1)
    NofXd2 = cu_cndf2(d2)
    futureValue = strike * cu.exp(- rate * time)
    c1 = futureValue * NofXd2
    call_ = sptprice * NofXd1 - c1
    put  = call_ - futureValue + sptprice
    return put
end

function cu_cndf2(x)
    0.5f0 + 0.5f0 * cu.erfc(0.707106781f0 * x)
end

function execute_broadcast(f, res, a, b, c, d, e)
    res .= f.(a, b, c, d, e)
    synchronize(res)
end

@afgc function execute_broadcast_af(f, res, a, b, c, d, e)
    res .= f.(a, b, c, d, e)
    synchronize(res)
end


function makeresult(bench, N, device, hardware, mdiff)
    BenchResult(
        "Blackscholes",
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
    T = Float32
    results = BenchResult[]
    func = is_cudanative(device) ? cu_blackscholes : blackscholes
    func = is_arrayfire(device) ? blackscholes_af : func
    for x in 1:7
        N = 10^x
        jl_arrays = (
            zeros(T, N),
            T[42.0 for i = 1:N],
            T[40.0 + (i / N) for i = 1:N],
            T[0.5 for i = 1:N],
            T[0.2 for i = 1:N],
            T[0.5 for i = 1:N]
        )
        gpu_arrays = array_type.(jl_arrays)
        res, a, b, c, d, e = gpu_arrays
        br_func = is_arrayfire(device) ? execute_broadcast_af : execute_broadcast
        bench = @benchmark $(br_func)($func, $res, $a, $b, $c, $d, $e)
        jl_arrays[1] .= blackscholes.(jl_arrays[2:end]...)
        mdiff = meandifference(jl_arrays[1], res)
        push!(results, makeresult(bench, N, device, hardware, mdiff))
        for elem in gpu_arrays
            free(elem)
            println("freeing element: ", CUDAdrv.Mem.used() / 10^7)
        end
        afgc();gc()
    end
    return results
end


end
