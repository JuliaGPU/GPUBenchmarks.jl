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


dir(paths...) = normpath(joinpath(@__DIR__, "..", paths...))

datapath(version, names...) = dir("results", "data", string(version), names...)
function datapath!(version, names...)
    full_path = datapath(version, names...)
    dirpath = dirname(full_path)
    isdir(dirpath) || mkdir(dirpath)
    normpath(full_path)
end
function save_result(result, name, version = current_version())
    save(datapath!(version, name * ".jld"), result)
end


load_result(name, version = current_version()) = load(datapath(version, name * ".jld"))

function load_results(version = current_version())
    files = filter(readdir(datapath(version))) do x
        endswith(x, ".jld")
    end
    Dict(map(files) do file
        result = load(file)
        name, ext = splitext(file)
        name = basename(name)
        name => result
    end)
end
current_version() = v"0.0.1"
"""
Runs a script in a new julia process.
Usage:
```
@run_julia (JULIA_NUM_THREADS = 8, "-O3",  "--math-mode=fast") begin
    println(Threads.nthreads())
end
```
"""
macro run_julia(args, expr)
    envs = []
    julia_args = []
    variables = []
    if isa(args, Expr) && args.head == :tuple
        for elem in args.args
            if isa(elem, String)
                push!(julia_args, elem)
            elseif isa(elem, Expr) && elem.head == :(=)
                key, value = elem.args
                push!(envs, string(key) => value)
            else
                error("Unsupported argument: $elem")
            end
        end
    else
        error("Unsupported expression for args $args")
    end

    new_args = []
    for arg in expr.args
        if isa(arg, Expr) && arg.head == :toplevel
            for toplevel in arg.args
                push!(new_args, toplevel)
            end
        else
            push!(new_args, arg)
        end
    end
    expr.args = new_args
    str = string(expr)
    command = `julia6 $(julia_args...) -e $str`
    quote

        withenv($(esc(envs...))) do
            run($command)
        end
    end
end



export devices, init, is_cudanative, free, synchronize, save_result, load_result, is_arrayfire, current_version, is_gpuarrays
export @run_julia, datapath


end # module
