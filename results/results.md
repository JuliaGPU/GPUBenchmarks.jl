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
| gpuarrays cl |  `0.02 ms` `3.96x` | `0.03 ms` `33.28x` | `0.19 ms` `92.34x` | `2.68 ms` `103.96x` |
| cuarrays |  `0.01 ms` `8.04x` | `0.03 ms` `39.01x` | `0.3 ms` `59.53x` | `4.36 ms` `63.93x` |
| gpuarrays threaded |  `0.03 ms` `2.44x` | `0.45 ms` `2.52x` | `6.72 ms` `2.62x` | `109.44 ms` `2.55x` |
| julia base |  `0.08 ms` `1.0x` | `1.13 ms` `1.0x` | `17.59 ms` `1.0x` | `278.79 ms` `1.0x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

___

#### Juliaset Unrolled
[![Juliaset Unrolled](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/Juliaset%20Unrolled.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

| device | N = 2¹² | N = 2¹⁶ | N = 2²⁰ | N = 2²⁴ |
| --- | --- | --- | --- | --- |
| gpuarrays cl |  `0.02 ms` `2.55x` | `0.03 ms` `24.61x` | `0.19 ms` `65.91x` | `2.88 ms` `68.5x` |
| cuarrays |  `0.01 ms` `5.52x` | `0.03 ms` `31.17x` | `0.27 ms` `46.54x` | `4.11 ms` `47.96x` |
| gpuarrays threaded |  `0.03 ms` `1.93x` | `0.39 ms` `2.16x` | `5.88 ms` `2.14x` | `108.38 ms` `1.82x` |
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
| arrayfire cu |  `0.12 ms` `0.01x` | `0.12 ms` `0.58x` | `0.16 ms` `46.72x` | `2.66 ms` `301.24x` |
| gpuarrays cudanative |  `0.01 ms` `0.09x` | `0.01 ms` `6.75x` | `0.04 ms` `189.89x` | `2.66 ms` `300.69x` |
| gpuarrays cl |  `0.03 ms` `0.04x` | `0.03 ms` `2.86x` | `0.05 ms` `145.65x` | `2.76 ms` `290.34x` |
| arrayfire cl |  `0.12 ms` `0.01x` | `0.15 ms` `0.49x` | `0.15 ms` `47.9x` | `3.19 ms` `250.65x` |
| cuarrays |  `0.01 ms` `0.1x` | `0.01 ms` `8.02x` | `0.04 ms` `178.18x` | `3.21 ms` `249.58x` |
| gpuarrays threaded |  `0.0 ms` `0.62x` | `0.02 ms` `3.62x` | `1.44 ms` `5.07x` | `173.76 ms` `4.6x` |
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
| gpuarrays cl |  `0.0 s` `0.14x` | `0.0 s` `33.04x` | `0.01 s` `59.83x` | `0.66 s` `67.02x` |
| gpuarrays cudanative |  `0.0 s` `0.25x` | `0.0 s` `20.02x` | `0.02 s` `27.15x` | `1.56 s` `28.56x` |
| gpuarrays threaded |  `0.0 s` `0.01x` | `0.0 s` `4.98x` | `0.07 s` `5.98x` | `7.25 s` `6.12x` |
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
| gpuarrays cudanative |  `0.0 s` `0.01x` | `0.0 s` `0.37x` | `0.01 s` `6.79x` | `1.69 s` `16.42x` |
| gpuarrays cl |  `0.01 s` `0.0x` | `0.01 s` `0.08x` | `0.04 s` `2.48x` | `4.12 s` `6.73x` |
| gpuarrays threaded |  `0.0 s` `0.05x` | `0.01 s` `0.09x` | `0.15 s` `0.62x` | `22.48 s` `1.23x` |
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
| arrayfire cl |  `0.01 ms` `0.0x` | `0.01 ms` `0.0x` | `0.02 ms` `0.3x` | `0.44 ms` `3.84x` |
| gpuarrays cudanative |  `0.02 ms` `0.0x` | `0.02 ms` `0.0x` | `0.04 ms` `0.19x` | `0.47 ms` `3.53x` |
| cuarrays |  `0.03 ms` `0.0x` | `0.03 ms` `0.0x` | `0.04 ms` `0.18x` | `0.47 ms` `3.52x` |
| arrayfire cu |  `0.01 ms` `0.0x` | `0.01 ms` `0.0x` | `0.02 ms` `0.34x` | `0.49 ms` `3.42x` |
| gpuarrays threaded |  `0.01 ms` `0.0x` | `0.01 ms` `0.0x` | `0.03 ms` `0.28x` | `1.45 ms` `1.15x` |
| julia base |  `0.0 ms` `1.0x` | `0.0 ms` `1.0x` | `0.01 ms` `1.0x` | `1.67 ms` `1.0x` |
| gpuarrays cl |  `0.05 ms` `0.0x` | `0.05 ms` `0.0x` | `0.09 ms` `0.08x` | `4.45 ms` `0.38x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/mapreduce.jl/)

___

