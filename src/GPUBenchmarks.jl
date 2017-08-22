module GPUBenchmarks

using GPUArrays, CUDAdrv, FileIO, BenchmarkTools
import CuArrays, ArrayFire, CUDAnative, CUDAdrv, OpenCL

function devices()
    (GPUArrays.supported_backends()..., :cuarrays, :arrayfire_cl, :arrayfire_cu, :julia_base)
end

function normit(x, mini, maxi)
    width = (maxi - mini)
    width == 0 && return x
    (x .- mini) ./ width
end

function meandifference(juliabaseline, gpuarray)
    mini, maxi = extrema(juliabaseline)
    normed1 = normit(juliabaseline, mini, maxi)
    normed2 = normit(Array(gpuarray), mini, maxi)
    mean(abs.(normed1 .- normed2))
end

function init(device)
    if device == :cuarrays
        # cuarrays uses the default device 0
        CUDAdrv.name(CUDAnative.CuDevice(0)), CuArrays.CuArray
    elseif device == :julia_base
        FFTW.set_num_threads(1)
        Sys.cpu_info()[1].model, Array
    elseif device == :arrayfire_cl
        ArrayFire.set_backend(ArrayFire.AF_BACKEND_OPENCL)
        gpu_devices = first(OpenCL.cl.devices(:gpu))
        replace(gpu_devices[:name], r"\s+", " "), ArrayFire.AFArray
    elseif device == :arrayfire_cu
        ArrayFire.set_backend(ArrayFire.AF_BACKEND_CUDA)
        CUDAdrv.name(CUDAnative.CuDevice(ArrayFire.get_device())), ArrayFire.AFArray
    else
        ctx = GPUArrays.init(device)
        hardware = if device == :cudanative
            CUDAdrv.name(ctx.device)
        elseif device == :opencl
            replace(ctx.device[:name], r"\s+", " ")
        elseif device == :julia
            FFTW.set_num_threads(8)
            Sys.cpu_info()[1].model
        end
        hardware, GPUArray
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
    envs = String[]
    julia_args = []
    variables = []
    if isa(args, Expr) && args.head == :tuple
        for elem in args.args
            if isa(elem, String)
                push!(julia_args, elem)
            elseif isa(elem, Expr) && elem.head == :(=)
                key, value = elem.args
                push!(envs, string(key, "=", value))
            elseif isa(elem, Symbol)
                push!(variables, elem)
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
    command_1 = ["julia6", julia_args...]
    variable_expr = map(variables) do var
        quote
            src_str *= sprint() do io
                val = $(esc(var))
                print(io, $(string(var)), " = ")
                show(io, val)
                println(io)
            end
        end
    end
    expr = quote
        src_str = ""
        $(variable_expr...)
        src_str *= $(string(expr))
        command_2 = Cmd([$(command_1)..., "-e", src_str])
        command_3 = Cmd(command_2, env = $(envs))
        run(command_3)
    end
    expr
end

include("database.jl")

export devices, init, is_cudanative, free, synchronize, is_arrayfire, is_gpuarrays
export @run_julia, BenchResult, meandifference


end # module


@which Sys.cpu_summary()
