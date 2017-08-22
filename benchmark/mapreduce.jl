module Poincare

using GPUBenchmarks, BenchmarkTools

description = """
Mapreduce, e.g. sum!
"""

function makeresult(name, bench, N, device, hardware, mdiff)
    BenchResult(
        name,
        bench,
        N,
        Float32,
        string(device),
        hardware,
        @__FILE__,
        mdiff
    )
end
relerr(x,y) = abs(x - y) * 2 / (abs(x) + abs(y))
function execute(device)
    results = BenchResult[]
    srand(2)
    for i = 1:7
        N = 10^i
        hardware, array_type = init(device)
        A = rand(Float32, N)
        Agpu = array_type(A)
        bench = @benchmark begin
            sum($Agpu)
            synchronize($(Agpu)) # synchronize for the benchmark
        end
        jl_results = sum(A)
        result = sum(Agpu)
        mdiff = relerr(jl_results, result)
        @show mdiff
        push!(results, makeresult("sum", bench, N, device, hardware, mdiff))
        free(Agpu)
    end
    results
end

end
