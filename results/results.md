### Juliaset
julia set benchmark
generated functions allow you to emit specialized code for the argument types.

[![Juliaset](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/GPUBenchmarks/results/plots/Juliaset.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

___

### Juliaset Unrolled
julia set benchmark
generated functions allow you to emit specialized code for the argument types.

[![Juliaset Unrolled](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/GPUBenchmarks/results/plots/Juliaset Unrolled.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

___

### Blackscholes
Blackschole is a nice benchmark for broadcasting performance.
It's a medium heavy calculation per array element, where the calculation is completely
independant from each other.

[![Blackscholes](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/GPUBenchmarks/results/plots/Blackscholes.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/blackscholes.jl/)

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/blackscholes.jl/)

___

### Poincare
Poincare section of a chaotic neuronal network

[![Poincare](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/GPUBenchmarks/results/plots/Poincare.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/poincare.jl/)

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/poincare.jl/)

___

### PDE
This benchmark is dominated by the cost of the FFT, leading to worse results for OpenCL with
CLFFT compared to the faster CUFFT.
Similarly the multithreaded backend doesn't improve much over base with the same FFT implementation.

[![PDE](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/GPUBenchmarks/results/plots/PDE.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/PDE.jl/)

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/PDE.jl/)

___

### Sum
Mapreduce, e.g. sum!

[![sum](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/GPUBenchmarks/results/plots/sum.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/mapreduce.jl/)

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/mapreduce.jl/)

___

