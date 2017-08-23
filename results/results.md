# GPU Benchmarks

This is the first iteration of Julia's GPU benchmark suite.
Please treat all numbers with care and open issues if numbers seem off.
If you have suggestions or improvements, please go ahead and open a PR with this repository.

Packages benchmarked:

[CuArrays](https://github.com/FluxML/CuArrays.jl) appears as: **cuarrays**

[ArrayFire](https://github.com/gaika/ArrayFire.jl) appears as: **arrayfire cl**, **arrayfire cu**

[GPUArrays](https://github.com/JuliaGPU/GPUArrays.jl) appears as: **gpuarrays cl**, **gpuarrays cudanative** and **gpuarrays threaded**

Julia Base Arrays appear as: **julia base**

Hardware used for GPU: **GTX 950**

Hardware used for Julia single and multithreaded backends: **Intel® Core™ i7-6700 CPU @ 3.40GHz × 4**

Julia's Array implementation is used as a baseline for performance and precision.
So the baseline is in most cases the maximum single threaded performance with SIMD acceleration.
The mean difference in the precision compared to the Julia baseline is plotted as points, with the size of difference corelating with point size.

---


### Juliaset
The Julia Set benchmark.
The unrolled benchmark uses generated functions to emit an unrolled version of the inner loop.
This currently doesn't yield a speed up, but was quite a bit faster in the initial tests.
Needs some further research of why this slowed down - Potentially an N == 16 for the inner iteration is too big.
Image of the benchmarked juliaset:
![](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/juliaset_result.png?raw=true)

#### Juliaset
[![Juliaset](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/Juliaset.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

| device | N = 2¹² | N = 2¹⁶ | N = 2²⁰ | N = 2²⁴ |
| --- | --- | --- | --- | --- |
| gpuarrays cl |  `0.02 ms` `4.0x` | `0.03 ms` `33.3x` | `0.19 ms` `92.3x` | `2.68 ms` `104.0x` |
| cuarrays |  `0.01 ms` `8.0x` | `0.03 ms` `39.0x` | `0.3 ms` `59.5x` | `4.36 ms` `63.9x` |
| gpuarrays threaded |  `0.03 ms` `2.4x` | `0.45 ms` `2.5x` | `6.72 ms` `2.6x` | `109.44 ms` `2.5x` |
| julia base |  `0.08 ms` `1.0x` | `1.13 ms` `1.0x` | `17.59 ms` `1.0x` | `278.79 ms` `1.0x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

___

#### Juliaset Unrolled
[![Juliaset Unrolled](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/Juliaset%20Unrolled.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

| device | N = 2¹² | N = 2¹⁶ | N = 2²⁰ | N = 2²⁴ |
| --- | --- | --- | --- | --- |
| gpuarrays cl |  `0.02 ms` `2.6x` | `0.03 ms` `24.6x` | `0.19 ms` `65.9x` | `2.88 ms` `68.5x` |
| cuarrays |  `0.01 ms` `5.5x` | `0.03 ms` `31.2x` | `0.27 ms` `46.5x` | `4.11 ms` `48.0x` |
| gpuarrays threaded |  `0.03 ms` `1.9x` | `0.39 ms` `2.2x` | `5.88 ms` `2.1x` | `108.38 ms` `1.8x` |
| julia base |  `0.06 ms` `1.0x` | `0.84 ms` `1.0x` | `12.58 ms` `1.0x` | `197.19 ms` `1.0x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

___

### Blackscholes
Blackschole is a nice benchmark for broadcasting performance.
It's a medium heavy calculation per array element, where the calculation is completely
independant from each other.
The CuArray package is a bit slower here compared to GPUArrays, which should be straightforward to fix.
I suspect that it's due to more promotions between integer types in the indexing code.

#### Blackscholes
[![Blackscholes](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/Blackscholes.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/blackscholes.jl/)

| device | N = 10¹ | N = 10³ | N = 10⁵ | N = 10⁷ |
| --- | --- | --- | --- | --- |
| arrayfire cu |  `0.12 ms` `0.0x` | `0.12 ms` `0.6x` | `0.16 ms` `46.7x` | `2.66 ms` `301.2x` |
| gpuarrays cudanative |  `0.01 ms` `0.1x` | `0.01 ms` `6.8x` | `0.04 ms` `189.9x` | `2.66 ms` `300.7x` |
| gpuarrays cl |  `0.03 ms` `0.0x` | `0.03 ms` `2.9x` | `0.05 ms` `145.7x` | `2.76 ms` `290.3x` |
| arrayfire cl |  `0.12 ms` `0.0x` | `0.15 ms` `0.5x` | `0.15 ms` `47.9x` | `3.19 ms` `250.7x` |
| cuarrays |  `0.01 ms` `0.1x` | `0.01 ms` `8.0x` | `0.04 ms` `178.2x` | `3.21 ms` `249.6x` |
| gpuarrays threaded |  `0.0 ms` `0.6x` | `0.02 ms` `3.6x` | `1.44 ms` `5.1x` | `173.76 ms` `4.6x` |
| julia base |  `0.0 ms` `1.0x` | `0.07 ms` `1.0x` | `7.28 ms` `1.0x` | `800.02 ms` `1.0x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/blackscholes.jl/)

___

### Poincare
Poincare section of a chaotic neuronal network.
The domination of OpenCL in this benchmark might be due to a better use of vector intrinsics in Transpiler.jl, but needs some
more investigations.
Result of calculation:
![](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/poincare_result.png?raw=true)

#### Poincare
[![Poincare](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/Poincare.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/poincare.jl/)

| device | N = 10³ | N = 10⁵ | N = 10⁷ | N = 10⁹ |
| --- | --- | --- | --- | --- |
| gpuarrays cl |  `0.0 s` `0.1x` | `0.0 s` `33.0x` | `0.01 s` `59.8x` | `0.66 s` `67.0x` |
| gpuarrays cudanative |  `0.0 s` `0.3x` | `0.0 s` `20.0x` | `0.02 s` `27.2x` | `1.56 s` `28.6x` |
| gpuarrays threaded |  `0.0 s` `0.0x` | `0.0 s` `5.0x` | `0.07 s` `6.0x` | `7.25 s` `6.1x` |
| julia base |  `0.0 s` `1.0x` | `0.0 s` `1.0x` | `0.42 s` `1.0x` | `44.41 s` `1.0x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/poincare.jl/)

___

### PDE
Kuramoto-Sivashinsky algorithm benchmark ([original benchmark](https://github.com/johnfgibson/julia-pde-benchmark/blob/master/1-Kuramoto-Sivashinksy-benchmark.ipynb)).

This benchmark is dominated by the cost of the FFT, leading to worse results for OpenCL with
CLFFT compared to the faster CUFFT.
Similarly the multithreaded backend doesn't improve much over base with the same FFT implementation.
Result of the benchmarked PDE:
![](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/pde_result.png?raw=true)

#### PDE
[![PDE](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/PDE.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/PDE.jl/)

| device | N = 10¹ | N = 10³ | N = 10⁵ | N = 10⁷ |
| --- | --- | --- | --- | --- |
| gpuarrays cudanative |  `0.0 s` `0.0x` | `0.0 s` `0.4x` | `0.01 s` `6.8x` | `1.69 s` `16.4x` |
| gpuarrays cl |  `0.01 s` `0.0x` | `0.01 s` `0.1x` | `0.04 s` `2.5x` | `4.12 s` `6.7x` |
| gpuarrays threaded |  `0.0 s` `0.1x` | `0.01 s` `0.1x` | `0.15 s` `0.6x` | `22.48 s` `1.2x` |
| julia base |  `0.0 s` `1.0x` | `0.0 s` `1.0x` | `0.09 s` `1.0x` | `27.72 s` `1.0x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/PDE.jl/)

___

### Mapreduce
Mapreduce, e.g. sum!.
Interestingly, for the sum benchmark the arrayfire opencl backend is the fastest, while GPUArrays OpenCL backend is the slowest.
This means we should be able to remove the slowdown for GPUArrays + OpenCL and maybe also for all the CUDA backends.

#### Sum
[![sum](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/sum.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/mapreduce.jl/)

| device | N = 10¹ | N = 10³ | N = 10⁵ | N = 10⁷ |
| --- | --- | --- | --- | --- |
| arrayfire cl |  `0.01 ms` `0.0x` | `0.01 ms` `0.0x` | `0.02 ms` `0.3x` | `0.44 ms` `3.8x` |
| gpuarrays cudanative |  `0.02 ms` `0.0x` | `0.02 ms` `0.0x` | `0.04 ms` `0.2x` | `0.47 ms` `3.5x` |
| cuarrays |  `0.03 ms` `0.0x` | `0.03 ms` `0.0x` | `0.04 ms` `0.2x` | `0.47 ms` `3.5x` |
| arrayfire cu |  `0.01 ms` `0.0x` | `0.01 ms` `0.0x` | `0.02 ms` `0.3x` | `0.49 ms` `3.4x` |
| gpuarrays threaded |  `0.01 ms` `0.0x` | `0.01 ms` `0.0x` | `0.03 ms` `0.3x` | `1.45 ms` `1.2x` |
| julia base |  `0.0 ms` `1.0x` | `0.0 ms` `1.0x` | `0.01 ms` `1.0x` | `1.67 ms` `1.0x` |
| gpuarrays cl |  `0.05 ms` `0.0x` | `0.05 ms` `0.0x` | `0.09 ms` `0.1x` | `4.45 ms` `0.4x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/mapreduce.jl/)

___

