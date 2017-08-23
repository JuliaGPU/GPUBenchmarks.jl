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

| device | N = 2¹² | N = 2²⁴ |
| --- | --- | --- |
| ![gpuarrays cl](https://placehold.it/15/b2df8a/000000?text=+) gpuarrays cl |  `0.0207 ms` `4.0x` | `2.7 ms` `104.0x` |
| ![cuarrays](https://placehold.it/15/33a02c/000000?text=+) cuarrays |  `0.0102 ms` `8.0x` | `4.4 ms` `63.9x` |
| ![gpuarrays threaded](https://placehold.it/15/a6cee3/000000?text=+) gpuarrays threaded |  `0.0337 ms` `2.4x` | `109.4 ms` `2.5x` |
| ![julia base](https://placehold.it/15/fb9a99/000000?text=+) julia base |  `0.0821 ms` `1.0x` | `278.8 ms` `1.0x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

___

#### Juliaset Unrolled
[![Juliaset Unrolled](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/Juliaset%20Unrolled.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

| device | N = 2¹² | N = 2²⁴ |
| --- | --- | --- |
| ![gpuarrays cl](https://placehold.it/15/b2df8a/000000?text=+) gpuarrays cl |  `0.0216 ms` `2.6x` | `2.9 ms` `68.5x` |
| ![cuarrays](https://placehold.it/15/33a02c/000000?text=+) cuarrays |  `0.01 ms` `5.5x` | `4.1 ms` `48.0x` |
| ![gpuarrays threaded](https://placehold.it/15/a6cee3/000000?text=+) gpuarrays threaded |  `0.0285 ms` `1.9x` | `108.4 ms` `1.8x` |
| ![julia base](https://placehold.it/15/fb9a99/000000?text=+) julia base |  `0.0552 ms` `1.0x` | `197.2 ms` `1.0x` |

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

| device | N = 10¹ | N = 10⁷ |
| --- | --- | --- |
| ![arrayfire cu](https://placehold.it/15/fdbf6f/000000?text=+) arrayfire cu |  `0.1 ms` `0.0075x` | `2.7 ms` `301.2x` |
| ![gpuarrays cudanative](https://placehold.it/15/b2df8a/000000?text=+) gpuarrays cudanative |  `0.0102 ms` `0.0912x` | `2.7 ms` `300.7x` |
| ![gpuarrays cl](https://placehold.it/15/33a02c/000000?text=+) gpuarrays cl |  `0.0255 ms` `0.0366x` | `2.8 ms` `290.3x` |
| ![arrayfire cl](https://placehold.it/15/e31a1c/000000?text=+) arrayfire cl |  `0.1 ms` `0.0076x` | `3.2 ms` `250.7x` |
| ![cuarrays](https://placehold.it/15/fb9a99/000000?text=+) cuarrays |  `0.0091 ms` `0.1x` | `3.2 ms` `249.6x` |
| ![gpuarrays threaded](https://placehold.it/15/a6cee3/000000?text=+) gpuarrays threaded |  `0.0015 ms` `0.6x` | `173.8 ms` `4.6x` |
| ![julia base](https://placehold.it/15/ff7f00/000000?text=+) julia base |  `0.0009 ms` `1.0x` | `800.0 ms` `1.0x` |

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

| device | N = 10³ | N = 10⁹ |
| --- | --- | --- |
| ![gpuarrays cl](https://placehold.it/15/33a02c/000000?text=+) gpuarrays cl |  `2.839e-5 s` `0.1x` | `0.7 s` `67.0x` |
| ![gpuarrays cudanative](https://placehold.it/15/b2df8a/000000?text=+) gpuarrays cudanative |  `1.6134e-5 s` `0.3x` | `1.6 s` `28.6x` |
| ![gpuarrays threaded](https://placehold.it/15/a6cee3/000000?text=+) gpuarrays threaded |  `0.0003 s` `0.0126x` | `7.3 s` `6.1x` |
| ![julia base](https://placehold.it/15/fb9a99/000000?text=+) julia base |  `4.078e-6 s` `1.0x` | `44.4 s` `1.0x` |

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

| device | N = 10¹ | N = 10⁷ |
| --- | --- | --- |
| ![gpuarrays cudanative](https://placehold.it/15/b2df8a/000000?text=+) gpuarrays cudanative |  `0.0013 s` `0.0069x` | `1.7 s` `16.4x` |
| ![gpuarrays cl](https://placehold.it/15/33a02c/000000?text=+) gpuarrays cl |  `0.0082 s` `0.0011x` | `4.1 s` `6.7x` |
| ![gpuarrays threaded](https://placehold.it/15/a6cee3/000000?text=+) gpuarrays threaded |  `0.0002 s` `0.0531x` | `22.5 s` `1.2x` |
| ![julia base](https://placehold.it/15/fb9a99/000000?text=+) julia base |  `8.719e-6 s` `1.0x` | `27.7 s` `1.0x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/PDE.jl/)

___

### Mapreduce
Mapreduce, e.g. sum!.
Interestingly, for the sum benchmark the arrayfire opencl backend is the fastest, while GPUArrays OpenCL backend is the slowest.
This means we should be able to remove the slowdown for GPUArrays + OpenCL and maybe also for all the CUDA backends.

#### Sum
[![sum](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/sum.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/mapreduce.jl/)

| device | N = 10¹ | N = 10⁷ |
| --- | --- | --- |
| ![arrayfire cl](https://placehold.it/15/fb9a99/000000?text=+) arrayfire cl |  `0.0106 ms` `0.0005x` | `0.4 ms` `3.8x` |
| ![gpuarrays cudanative](https://placehold.it/15/b2df8a/000000?text=+) gpuarrays cudanative |  `0.0179 ms` `0.0003x` | `0.5 ms` `3.5x` |
| ![cuarrays](https://placehold.it/15/ff7f00/000000?text=+) cuarrays |  `0.0254 ms` `0.0002x` | `0.5 ms` `3.5x` |
| ![arrayfire cu](https://placehold.it/15/e31a1c/000000?text=+) arrayfire cu |  `0.0096 ms` `0.0006x` | `0.5 ms` `3.4x` |
| ![gpuarrays threaded](https://placehold.it/15/a6cee3/000000?text=+) gpuarrays threaded |  `0.0114 ms` `0.0005x` | `1.4 ms` `1.2x` |
| ![julia base](https://placehold.it/15/fdbf6f/000000?text=+) julia base |  `5.262e-6 ms` `1.0x` | `1.7 ms` `1.0x` |
| ![gpuarrays cl](https://placehold.it/15/33a02c/000000?text=+) gpuarrays cl |  `0.0544 ms` `9.6794e-5x` | `4.5 ms` `0.4x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/mapreduce.jl/)

___

