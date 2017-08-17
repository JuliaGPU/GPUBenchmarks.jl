module GPUBenchmarks

using GPUArrays, CUDAdrv, FileIO
import CuArrays, ArrayFire

function devices()
    (GPUArrays.supported_backends()..., :cuarrays, :arrayfire_cl, :arrayfire_cu, :julia_base)
end

function init(device)
    if device == :cuarrays
        nothing, CuArrays.CuArray
    elseif device == :julia_base
        FFTW.set_num_threads(1)
        nothing, Array
    elseif device == :arrayfire_cl
        ArrayFire.set_backend(ArrayFire.AF_BACKEND_OPENCL)
        nothing, ArrayFire.AFArray
    elseif device == :arrayfire_cu
        ArrayFire.set_backend(ArrayFire.AF_BACKEND_CUDA)
        nothing, ArrayFire.AFArray
    else
        if device == :julia
            FFTW.set_num_threads(8)
        end
        ctx = GPUArrays.init(device)
        ctx, GPUArray
    end
end

is_cudanative(x) = x in (:cudanative, :cuarrays)
is_arrayfire(x) = x in (:arrayfire_cl, :arrayfire_cu)
is_gpuarrays(x) = x in (:opencl, :cudanative, :julia)

synchronize(x) = GPUArrays.synchronize(x)

function synchronize(x::CuArrays.CuArray)
    ctx = CUDAdrv.CuContext(CUDAdrv.CuPrimaryContext(CUDAdrv.CuDevice(0)))
    CUDAdrv.synchronize(ctx)
    x
end

function synchronize(x::ArrayFire.AFArray)
    ArrayFire.afgc()
    ArrayFire.sync(x)
    return x
end

free(x) = finalize(x)
# Maybe GPUArrays should stop using free and use finalize instead ........
free(x::GPUArray) = GPUArrays.free(x)


dir(paths...) = joinpath(@__DIR__, "..", paths...)

function save_result(result, version = current_version())
    save(dir("results", "data", string(version, ".jld")), result)
end

load_result(version = current_version()) = load(dir("results", "data", string(version, ".jld")))

current_version() = v"0.0.1"

export devices, init, is_cudanative, free, synchronize, save_result, load_result, is_arrayfire, current_version, is_gpuarrays


end # module
