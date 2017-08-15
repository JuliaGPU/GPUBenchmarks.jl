module GPUBenchmarks

using GPUArrays

function devices()
    GPUArrays.supported_backends()
end
function init(device)
    ctx = GPUArrays.init(device)
    ctx, GPUArray
end

is_cudanative(x) = x == :cudanative

export devices, init, is_cudanative

end # module
