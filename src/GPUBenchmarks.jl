module GPUBenchmarks

using GPUArrays, CUDAdrv

function devices()
    GPUArrays.supported_backends()
end
function init(device)
    ctx = GPUArrays.init(device)
    ctx, GPUArray
end

is_cudanative(x) = x == :cudanative

function free(x)
    GPUArrays.free(x)
end
synchronize(x) = GPUArrays.synchronize(x)

export devices, init, is_cudanative, free, synchronize


end # module
