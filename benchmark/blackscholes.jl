module Blackscholes

using GPUBenchmarks

using CUDAnative
const cu = CUDAnative

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



is_device_supported(dev) = dev != :cudanative# should work for all!

nrange() = map(x-> 10^x, 1:7)
types() = (Float32,)

function setup(N, T, device)
    arrays = (
        T[42.0 for i = 1:N],
        T[40.0 + (i / N) for i = 1:N],
        T[0.5 for i = 1:N],
        T[0.2 for i = 1:N],
        T[0.5 for i = 1:N],
        zeros(T, N)
    )
    ctx, array_type = init(device)
    func = is_cudanative(device) ? cu_blackscholes : blackscholes
    return func, array_type.(arrays)
end

function execute(f, setup)
    res, a, b, c, d, e = setup
    res .= f.(a, b, c, d, e)
    synchronize(res)
    return res
end

function teardown(setup)
    for elem in setup
        free(elem)
    end
    gc()
    return
end

end
