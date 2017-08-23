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


### Juliaset
The Julia Set benchmark.
The unrolled benchmark uses generated functions to emit an unrolled version of the inner loop.
This currently doesn't yield a speed up, but was quite a bit faster in the initial tests.
Needs some further research of why this slowed down - Potentially an N == 16 for the inner iteration is too big.
Image of the benchmarked juliaset:
![](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/juliaset_result.png?raw=true)

#### Juliaset
[![Juliaset](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/Juliaset.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

| device | N = 2¹² | N = 2¹⁴ | N = 2¹⁶ | N = 2¹⁸ | N = 2²⁰ | N = 2²² | N = 2²⁴ |
| --- | --- | --- | --- | --- | --- | --- | --- |
| opencl |  `0.0 ms` `4.0x` | `0.0 ms` `12.7x` | `0.0 ms` `33.3x` | `0.1 ms` `65.4x` | `0.2 ms` `92.3x` | `0.7 ms` `101.3x` | `2.7 ms` `104.0x` |
| cuarrays |  `0.0 ms` `8.0x` | `0.0 ms` `22.4x` | `0.0 ms` `39.0x` | `0.1 ms` `50.9x` | `0.3 ms` `59.5x` | `1.1 ms` `62.6x` | `4.4 ms` `63.9x` |
| julia |  `0.0 ms` `2.4x` | `0.1 ms` `2.6x` | `0.4 ms` `2.5x` | `1.7 ms` `2.5x` | `6.7 ms` `2.6x` | `30.4 ms` `2.3x` | `109.4 ms` `2.5x` |
| julia_base |  `0.1 ms` `1.0x` | `0.3 ms` `1.0x` | `1.1 ms` `1.0x` | `4.3 ms` `1.0x` | `17.6 ms` `1.0x` | `69.9 ms` `1.0x` | `278.8 ms` `1.0x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

___

#### Juliaset Unrolled
[![Juliaset Unrolled](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/Juliaset%20Unrolled.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

| device | N = 2¹² | N = 2¹⁴ | N = 2¹⁶ | N = 2¹⁸ | N = 2²⁰ | N = 2²² | N = 2²⁴ |
| --- | --- | --- | --- | --- | --- | --- | --- |
| opencl |  `0.0 ms` `2.6x` | `0.0 ms` `9.3x` | `0.0 ms` `24.6x` | `0.1 ms` `47.5x` | `0.2 ms` `65.9x` | `0.7 ms` `72.2x` | `2.9 ms` `68.5x` |
| cuarrays |  `0.0 ms` `5.5x` | `0.0 ms` `17.3x` | `0.0 ms` `31.2x` | `0.1 ms` `40.1x` | `0.3 ms` `46.5x` | `1.0 ms` `47.7x` | `4.1 ms` `48.0x` |
| julia |  `0.0 ms` `1.9x` | `0.1 ms` `2.2x` | `0.4 ms` `2.2x` | `1.5 ms` `2.1x` | `5.9 ms` `2.1x` | `24.0 ms` `2.1x` | `108.4 ms` `1.8x` |
| julia_base |  `0.1 ms` `1.0x` | `0.2 ms` `1.0x` | `0.8 ms` `1.0x` | `3.1 ms` `1.0x` | `12.6 ms` `1.0x` | `49.8 ms` `1.0x` | `197.2 ms` `1.0x` |

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

| device | N = 10¹ | N = 10² | N = 10³ | N = 10⁴ | N = 10⁵ | N = 10⁶ | N = 10⁷ |
| --- | --- | --- | --- | --- | --- | --- | --- |
| arrayfire_cu |  `0.1 ms` `0.0x` | `0.1 ms` `0.1x` | `0.1 ms` `0.6x` | `0.1 ms` `5.7x` | `0.2 ms` `46.7x` | `0.4 ms` `207.1x` | `2.7 ms` `301.2x` |
| cudanative |  `0.0 ms` `0.1x` | `0.0 ms` `0.7x` | `0.0 ms` `6.8x` | `0.0 ms` `59.5x` | `0.0 ms` `189.9x` | `0.3 ms` `284.6x` | `2.7 ms` `300.7x` |
| opencl |  `0.0 ms` `0.0x` | `0.0 ms` `0.3x` | `0.0 ms` `2.9x` | `0.0 ms` `26.3x` | `0.0 ms` `145.7x` | `0.3 ms` `280.8x` | `2.8 ms` `290.3x` |
| arrayfire_cl |  `0.1 ms` `0.0x` | `0.1 ms` `0.1x` | `0.1 ms` `0.5x` | `0.1 ms` `5.7x` | `0.2 ms` `47.9x` | `0.4 ms` `182.7x` | `3.2 ms` `250.7x` |
| cuarrays |  `0.0 ms` `0.1x` | `0.0 ms` `0.8x` | `0.0 ms` `8.0x` | `0.0 ms` `63.3x` | `0.0 ms` `178.2x` | `0.3 ms` `251.9x` | `3.2 ms` `249.6x` |
| julia |  `0.0 ms` `0.6x` | `0.0 ms` `1.0x` | `0.0 ms` `3.6x` | `0.1 ms` `4.8x` | `1.4 ms` `5.1x` | `16.9 ms` `4.6x` | `173.8 ms` `4.6x` |
| julia_base |  `0.0 ms` `1.0x` | `0.0 ms` `1.0x` | `0.1 ms` `1.0x` | `0.7 ms` `1.0x` | `7.3 ms` `1.0x` | `77.7 ms` `1.0x` | `800.0 ms` `1.0x` |

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

| device | N = 10³ | N = 10⁴ | N = 10⁵ | N = 10⁶ | N = 10⁷ | N = 10⁸ | N = 10⁹ |
| --- | --- | --- | --- | --- | --- | --- | --- |
| opencl |  `0.0 s` `0.1x` | `0.0 s` `8.9x` | `0.0 s` `33.0x` | `0.0 s` `54.6x` | `0.0 s` `59.8x` | `0.1 s` `62.4x` | `0.7 s` `67.0x` |
| cudanative |  `0.0 s` `0.3x` | `0.0 s` `10.6x` | `0.0 s` `20.0x` | `0.0 s` `25.9x` | `0.0 s` `27.2x` | `0.2 s` `27.6x` | `1.6 s` `28.6x` |
| julia |  `0.0 s` `0.0x` | `0.0 s` `0.8x` | `0.0 s` `5.0x` | `0.0 s` `6.9x` | `0.1 s` `6.0x` | `0.7 s` `6.0x` | `7.3 s` `6.1x` |
| julia_base |  `0.0 s` `1.0x` | `0.0 s` `1.0x` | `0.0 s` `1.0x` | `0.0 s` `1.0x` | `0.4 s` `1.0x` | `4.3 s` `1.0x` | `44.4 s` `1.0x` |

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

| device | N = 10¹ | N = 10² | N = 10³ | N = 10⁴ | N = 10⁵ | N = 10⁶ | N = 10⁷ |
| --- | --- | --- | --- | --- | --- | --- | --- |
| cudanative |  `0.0 s` `0.0x` | `0.0 s` `0.0x` | `0.0 s` `0.4x` | `0.0 s` `1.8x` | `0.0 s` `6.8x` | `0.2 s` `22.5x` | `1.7 s` `16.4x` |
| opencl |  `0.0 s` `0.0x` | `0.0 s` `0.0x` | `0.0 s` `0.1x` | `0.0 s` `0.5x` | `0.0 s` `2.5x` | `0.3 s` `10.6x` | `4.1 s` `6.7x` |
| julia |  `0.0 s` `0.1x` | `0.0 s` `0.0x` | `0.0 s` `0.1x` | `0.0 s` `0.3x` | `0.2 s` `0.6x` | `5.7 s` `0.6x` | `22.5 s` `1.2x` |
| julia_base |  `0.0 s` `1.0x` | `0.0 s` `1.0x` | `0.0 s` `1.0x` | `0.0 s` `1.0x` | `0.1 s` `1.0x` | `3.4 s` `1.0x` | `27.7 s` `1.0x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/PDE.jl/)

___

### Mapreduce
Mapreduce, e.g. sum!.
Interestingly, for the sum benchmark the arrayfire opencl backend is the fastest, while GPUArrays OpenCL backend is the slowest.
This means we should be able to remove the slowdown for GPUArrays + OpenCL and maybe also for all the CUDA backends.

#### Sum
[![sum](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/sum.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/mapreduce.jl/)

| device | N = 10¹ | N = 10² | N = 10³ | N = 10⁴ | N = 10⁵ | N = 10⁶ | N = 10⁷ |
| --- | --- | --- | --- | --- | --- | --- | --- |
| arrayfire_cl |  `0.0 ms` `0.0x` | `0.0 ms` `0.0x` | `0.0 ms` `0.0x` | `0.0 ms` `0.0x` | `0.0 ms` `0.3x` | `0.1 ms` `1.1x` | `0.4 ms` `3.8x` |
| cudanative |  `0.0 ms` `0.0x` | `0.0 ms` `0.0x` | `0.0 ms` `0.0x` | `0.0 ms` `0.0x` | `0.0 ms` `0.2x` | `0.1 ms` `0.8x` | `0.5 ms` `3.5x` |
| cuarrays |  `0.0 ms` `0.0x` | `0.0 ms` `0.0x` | `0.0 ms` `0.0x` | `0.0 ms` `0.0x` | `0.0 ms` `0.2x` | `0.1 ms` `0.6x` | `0.5 ms` `3.5x` |
| arrayfire_cu |  `0.0 ms` `0.0x` | `0.0 ms` `0.0x` | `0.0 ms` `0.0x` | `0.0 ms` `0.0x` | `0.0 ms` `0.3x` | `0.1 ms` `1.1x` | `0.5 ms` `3.4x` |
| julia |  `0.0 ms` `0.0x` | `0.0 ms` `0.0x` | `0.0 ms` `0.0x` | `0.0 ms` `0.1x` | `0.0 ms` `0.3x` | `0.1 ms` `0.5x` | `1.4 ms` `1.2x` |
| julia_base |  `0.0 ms` `1.0x` | `0.0 ms` `1.0x` | `0.0 ms` `1.0x` | `0.0 ms` `1.0x` | `0.0 ms` `1.0x` | `0.1 ms` `1.0x` | `1.7 ms` `1.0x` |
| opencl |  `0.1 ms` `0.0x` | `0.1 ms` `0.0x` | `0.1 ms` `0.0x` | `0.1 ms` `0.0x` | `0.1 ms` `0.1x` | `0.5 ms` `0.1x` | `4.5 ms` `0.4x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/mapreduce.jl/)

___
