using GPUBenchmarks, Plots, Colors, BenchmarkTools

#########################
# Parameters

# lol we can't just use 0.0, because Plots.jl errors then
missing_val = 0.0 + eps(Float64)
text2pix = 1.0
ywidth = 2.5
window_size = (800, 500)


nice_colors = map([
    (0, 116, 217), # Blue
    (127, 219, 255), # Aqua
    (133,  20,  75), # Maroon
    (240,  18, 190), # Fuchsia
    (46, 204,  64), # Green
    (177,  13, 201), # Purple
    (57, 204, 204), # Teal
    (61, 153, 112), # Olive
    (255, 220,   0), # Yellow
    (255,  65,  54), # Red
    (1, 255, 112), # Lime
    (255, 133,  27), # Orange
    (0,  31,  63), # Navy
    (221, 221, 221), # Silver
    (17,  17,  17), # Black
    (170, 170, 170), # Gray
]) do x
    RGB(map(v-> v / 255, x)...)
end
nice_colors = parse.(Colorant, ["#a6cee3","#b2df8a","#33a02c","#fb9a99","#e31a1c","#fdbf6f","#ff7f00","#cab2d6","#6a3d9a","#1f78b4"])
#######################
# helpers

function get_time(x::BenchmarkTools.Trial)
    time = minimum(x).time
    isinf(time) ? missing_val : time / 10^9
end

function judged_push!(benchset, benchmark, name)
    get_time(benchmark) == missing_val && return
    for benches in benchset
        judgment = judge(minimum(first(benches)[2]), minimum(benchmark))
        if judgment.time == :invariant
            push!(benches, (name, benchmark))
            return
        end
    end
    # we have a new unique benchresult and can open a new group
    push!(benchset, [(name, benchmark)])
    return
end

get_trial(x::BenchmarkTools.Trial) = x
function get_trial(x)
    BenchmarkTools.Trial(
        BenchmarkTools.Parameters(),
        fill(Inf, 1000),
        fill(Inf, 1000),
        typemax(Int),
        typemax(Int)
    )
end

grouptime(x) = minimum(last(first(x))).time
function speedup!(benchset)
    sort!(benchset, by = grouptime)
    slowest = grouptime(benchset[end])
    map(x-> slowest / grouptime(x), benchset)
end

rect(w, h, x, y) = Shape(x + [0,w,w,0], y + [0,0,h,h])
function plot_speedup!(p, position, label, color)
    annotation = text(label, 9, RGB(0.2, 0.2, 0.2), :right, "helvetica")
    ps = annotation.font.pointsize
    w = (10 * ps) / text2pix
    shape = rect(-w, ps * ywidth, (position)...)
    plot!(p, shape, linewidth = 0, linecolor = RGBA(0,0,0,0), color = color, m = (color, stroke(0)))
    annotate!(p, [((position .+ (-4, 10text2pix))..., annotation)])
    position .- (w + (5 * text2pix), 0)
end

function plot_label!(p, position, label, color)
    shape = rect(10, 9 * ywidth, (position .- (12, 0))...)
    plot!(p, shape, linewidth = 0, color = color, linecolor = RGBA(1,1,1,0.2))
    position .- ((15text2pix), 0)
end

function plot_benchset(p, position, wstart, benchset, label_colors, speed_cmap)
    speedups = speedup!(benchset)
    abs_times = map(x-> minimum(x[1][2]).time, benchset)
    iterator = zip(reverse(speedups), speed_cmap, reverse(benchset), reverse(abs_times))
    for (speedup, scolor, benches, abs_time) in iterator
        position = plot_speedup!(p, position, prettytime(abs_time), scolor)
        position = plot_speedup!(p, position, @sprintf("%8.1fx", speedup), scolor)
        for (name, bench) in benches
            position = plot_label!(p, position, name, label_colors[name])
        end
        position = (wstart, position[2] + 11 * ywidth + 5)
    end
    position
end

function plot_legend(name, benchsetsn, benchsets, label_colors, size)
    pad = 5
    width, height = size .* (0.3, 0.5)
    wstart = width - pad
    position = (wstart, 0)
    str = IOBuffer()
    print(str, "|")
    for n in benchsetsn
        print(str, " ", get_log_n(n), " |")
    end
    print(str, "\n|")
    for n in benchsetsn
        print(str, " --- |")
    end
    print(str, "\n|")
    for (i, (n, benchset)) in enumerate(zip(benchsetsn, benchsets))
        p = plot(
            xlims = (0, width), ylims = (0, height),
            legend = false,
            grid = false,
            axis = false,
            margin = 0,
            bottom_margin = 0,
            aspect_ratio = 1,
            markerstrokewidth = 0,
            size = (width, height)
        )
        speed_cmap = linspace(RGBA(colorant"#E53A15", 0.6), RGBA(colorant"#AAE500", 0.3), length(benchset))
        plot_benchset(p, position, wstart, benchset, label_colors, speed_cmap)
        path = ("results", "plots", "speedups",  string(name, i, ".png"))
        savefig(GPUBenchmarks.dir(path...))
        print(str, " ![](", github_url(true, path...), ") |")
    end
    String(take!(str))
end
function github_url(isimage, name...)
    str = joinpath(
        "https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/",
        name...,
        isimage ? "?raw=true" : ""
    )
    # there is a better way to do this in HTTParser or so... keep forgetting where and how
    replace(str, " ", "%20")
end

##########################################
# plotting code

gr(size = window_size)


md_io = open(GPUBenchmarks.dir("results", string("results.md")), "w")

println(md_io, """
# GPU Benchmarks

This is the first iteration of Julia's GPU benchmark suite.
Please treat all numbers with care and open issues if numbers seem off.
If you have suggestions or improvements, please go ahead and open a PR with this repository.

Packages benchmarked:

[CuArrays](https://github.com/FluxML/CuArrays.jl) appears as: **cuarrays**

[ArrayFire](https://github.com/gaika/ArrayFire.jl) appears as: **arrayfire cl**, **arrayfire cu**

[GPUArrays](https://github.com/JuliaGPU/GPUArrays.jl) appears as: **opencl**, **cudanative** and **julia** for a multi threaded backend

Julia Base Arrays appear as: **julia base**

Hardware used for GPU: **GTX 950**

Hardware used for Julia single and multithreaded backends: **Intel® Core™ i7-6700 CPU @ 3.40GHz × 4**

Julia's Array implementation is used as a baseline for performance and precision.
So the baseline is in most cases the maximum single threaded performance with SIMD acceleration.
The mean difference in the precision compared to the Julia baseline is plotted as points, with the size of difference corelating with point size.

---

""")

function get_log_n(N)
    # we should only use log10  or log2 for now!
    isinteger(log10(N)) && return string("10^", Int(log10(N)))
    ispow2(N) && return string("2^", Int(log2(N)))
    string(N)
end

function prettytime(t)
    if t < 1e3
        value, units = t, "ns"
    elseif t < 1e6
        value, units = t / 1e3, "\\mus"
    elseif t < 1e9
        value, units = t / 1e6, "ms"
    else
        value, units = t / 1e9, "s"
    end
    return string(@sprintf("%8.1f", round(value, 1)), units)
end
function device_label(device)
    # TODO rename devices in GPUArrays and GPUBenchmarks
    str = replace(string(device), "_", " ")
    if device == "opencl"
        "gpuarrays cl"
    elseif device == "cudanative"
        "gpuarrays cudanative"
    elseif device == "julia"
        "gpuarrays threaded"
    else
        str
    end
end


# most_current = filter(x-> x.timestamp == GPUBenchmarks.last_time_stamp(), GPUBenchmarks.get_database())
most_current = GPUBenchmarks.get_database()
using GPUBenchmarks: codepath, name
codepaths = unique(codepath.(most_current))
for code_path in codepaths
    suites = unique(name.(filter(x-> codepath(x) == code_path, most_current)))
    mod = include(code_path)
    jl_name = basename(code_path)
    file_name, ext = splitext(jl_name)
    println(md_io, "### ", titlecase(file_name))
    println(md_io, mod.description)
    for suitename in suites
        suite = filter(x-> name(x) == suitename, most_current)
        println(md_io, "#### ", titlecase(suitename))
        i = 1
        legend_colors = Dict()
        main_plot = plot(
            xaxis = ("Problem size N", :log10), yaxis = "Speedup",
            legend = :topleft,
            background_color_legend = RGBA(1, 1, 1, 0.6),
            top_margin = 0,
            foreground_color_grid = RGB(0.6, 0.6, 0.6),
            axiscolor = RGB(0.2, 0.2, 0.2),
            markerstrokewidth = 0,
        );
        devices = unique(map(x-> x.device, suite))
        benchset_firstn = []
        benchset_middle = []
        benchset_lastn = []
        baseline = sort(filter(x-> x.device == "julia_base", suite), by = (x)-> x.N)
        base_times, Ns = map(x-> x.benchmark, baseline), map(x-> x.N, baseline)
        benchset_ns = [Ns[1], Ns[length(Ns) ÷ 2], Ns[end]]
        base_times = get_time.(base_times)
        for device in devices
            device_benches = sort(filter(x-> x.device == device, suite), by = (x)-> x.N)
            times, Ns = map(x-> x.benchmark, device_benches), map(x-> x.N, device_benches)
            meandiff = map(x-> x.meandiffrence, device_benches) .* 3000.0
            judged_push!(benchset_firstn, first(times), device)
            judged_push!(benchset_middle, times[length(times) ÷ 2], device)
            judged_push!(benchset_lastn, last(times), device)
            times = base_times ./ get_time.(times)
            color = nice_colors[i]
            legend_colors[device] = color
            error_cmap = linspace(colorant"#E53A15", colorant"#AAE500", length(Ns))
            plot!(main_plot, Ns, times, line = (1, 0.4, color), m = (color, 5, stroke(0)), label = device_label(device))
            i += 1
        end
        benchsets = [benchset_firstn, benchset_middle, benchset_lastn]
        legend_str = plot_legend(suitename, benchset_ns, benchsets, legend_colors, window_size)

        layout = @layout [
            a{0.5h}
            a{0.5w} a{0.5w}
        ]
        plot(main_plot)
        plotbase = GPUBenchmarks.dir("results", "plots")
        isdir(plotbase) || mkdir(plotbase)
        pngpath = joinpath(plotbase, suitename * ".png")
        println(pngpath)
        savefig(pngpath)
        println(pngpath)
        img_url = github_url(true, split(pngpath, Base.Filesystem.path_separator)[end-2:end]...)

        code_url = github_url(false, "benchmark", jl_name)
        println(md_io, "[![$suitename]($img_url)]($code_url)")
        println(md_io)
        println(md_io, legend_str)
        println(md_io)
        println(md_io, "[code]($code_url)")
        println(md_io)
        println(md_io, "___")
        println(md_io)
    end
end
close(md_io)
