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

| device | N = 2^12 | N = 2^14 | N = 2^16 | N = 2^18 | N = 2^20 | N = 2^22 | N = 2^24 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| opencl | `0.020731 ms` `3.9603009985046547x` | `0.024548 ms` `12.74401173211667x` | `0.033985 ms` `33.276210092687954x` | `0.065579 ms` `65.40688330105674x` | `0.190517 ms` `92.34396405570106x` | `0.689681 ms` `101.32754998325312x` | `2.681856 ms` `103.95576570852424x` | cuarrays | `0.010217 ms` `8.035724772438094x` | `0.013961 ms` `22.408136952940335x` | `0.028988 ms` `39.01241893197185x` | `0.084312 ms` `50.87434766106841x` | `0.295547 ms` `59.5272325552281x` | `1.116963 ms` `62.5658020901319x` | `4.361108 ms` `63.92742257242884x` | julia | `0.033666 ms` `2.438691855284263x` | `0.11896 ms` `2.629791526563551x` | `0.449528 ms` `2.5157320567350645x` | `1.696962 ms` `2.527645286105405x` | `6.719646 ms` `2.618158010109461x` | `30.399441 ms` `2.2988477321013896x` | `109.436044 ms` `2.5475554836393757x` | julia_base | `0.082101 ms` `1.0x` | `0.31284 ms` `1.0x` | `1.130892 ms` `1.0x` | `4.289318 ms` `1.0x` | `17.593095 ms` `1.0x` | `69.883686 ms` `1.0x` | `278.794394 ms` `1.0x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

___

#### Juliaset Unrolled
[![Juliaset Unrolled](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/Juliaset%20Unrolled.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/juliaset.jl/)

| device | N = 2^12 | N = 2^14 | N = 2^16 | N = 2^18 | N = 2^20 | N = 2^22 | N = 2^24 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| opencl | `0.021626 ms` `2.5502173309904745x` | `0.024442 ms` `9.265567465837492x` | `0.03397 ms` `24.606446864880777x` | `0.065355 ms` `47.47769872236248x` | `0.190922 ms` `65.91151360241355x` | `0.689178 ms` `72.22336464599857x` | `2.878792 ms` `68.49866923348405x` | cuarrays | `0.009989 ms` `5.521173290619681x` | `0.013103 ms` `17.28375181256201x` | `0.026821 ms` `31.165169083926774x` | `0.077384 ms` `40.09750077535408x` | `0.270397 ms` `46.53882254610813x` | `1.042539 ms` `47.74378128779835x` | `4.111463 ms` `47.96186199413688x` | julia | `0.028536 ms` `1.932681525091113x` | `0.104252 ms` `2.172322833135096x` | `0.387723 ms` `2.15587158873732x` | `1.490174 ms` `2.082243415869556x` | `5.879361 ms` `2.140361512075887x` | `24.02087 ms` `2.072146179551365x` | `108.382019 ms` `1.8194293003528565x` | julia_base | `0.055151 ms` `1.0x` | `0.226469 ms` `1.0x` | `0.835881 ms` `1.0x` | `3.102905 ms` `1.0x` | `12.583958 ms` `1.0x` | `49.774754 ms` `1.0x` | `197.193421 ms` `1.0x` |

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

| device | N = 10^1 | N = 10^2 | N = 10^3 | N = 10^4 | N = 10^5 | N = 10^6 | N = 10^7 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| arrayfire_cu | `0.123744 ms` `0.007533563916903715x` | `0.123832 ms` `0.06005313650752633x` | `0.123881 ms` `0.5797983548728215x` | `0.126226 ms` `5.681452315687735x` | `0.155724 ms` `46.71992756415196x` | `0.375095 ms` `207.09419746997426x` | `2.655769 ms` `301.23936569784496x` | cudanative | `0.010225 ms` `0.0911719641401793x` | `0.010504 ms` `0.7079683929931455x` | `0.010634 ms` `6.754372766597705x` | `0.012056 ms` `59.48465494359655x` | `0.038314 ms` `189.8891788902229x` | `0.272952 ms` `284.592155397286x` | `2.660663 ms` `300.68526867175586x` | opencl | `0.025497 ms` `0.03656247140186427x` | `0.02516 ms` `0.2955683624801272x` | `0.025105 ms` `2.8610237004580763x` | `0.027268 ms` `26.299948657767345x` | `0.04995 ms` `145.65393393393393x` | `0.276616 ms` `280.82250484426066x` | `2.755498 ms` `290.3366901373182x` | arrayfire_cl | `0.122091 ms` `0.007635561452796138x` | `0.121133 ms` `0.061391198104562755x` | `0.145741 ms` `0.49283317666270987x` | `0.124987 ms` `5.737772728363749x` | `0.151889 ms` `47.89954506251276x` | `0.425257 ms` `182.6660066736115x` | `3.191746 ms` `250.65345707333853x` | cuarrays | `0.009086 ms` `0.10260107124513905x` | `0.009606 ms` `0.7741515719342078x` | `0.008958 ms` `8.01808439383791x` | `0.011338 ms` `63.2516316810725x` | `0.040832 ms` `178.17922217868337x` | `0.308422 ms` `251.86270110433108x` | `3.205507 ms` `249.57742067011552x` | julia | `0.0015039 ms` `0.6198772081477049x` | `0.00758875 ms` `0.9799374073464009x` | `0.019815 ms` `3.6248296744890234x` | `0.148888 ms` `4.816687711568427x` | `1.436396 ms` `5.065047521714067x` | `16.870433 ms` `4.604505290409558x` | `173.763702 ms` `4.604081058309865x` | julia_base | `0.0009322333333333334 ms` `1.0x` | `0.0074365 ms` `1.0x` | `0.071826 ms` `1.0x` | `0.717147 ms` `1.0x` | `7.275414 ms` `1.0x` | `77.679998 ms` `1.0x` | `800.022169 ms` `1.0x` |

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

| device | N = 10^3 | N = 10^4 | N = 10^5 | N = 10^6 | N = 10^7 | N = 10^8 | N = 10^9 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| opencl | `2.839e-5 s` `0.14363206360388467x` | `3.4268e-5 s` `8.881084393603361x` | `0.000103761 s` `33.04016923506905x` | `0.000757266 s` `54.56004495117964x` | `0.007089896 s` `59.83385524978082x` | `0.068640098 s` `62.435808687219534x` | `0.662652513 s` `67.02185924555604x` | cudanative | `1.6134e-5 s` `0.252740441658255x` | `2.8684e-5 s` `10.609991632966114x` | `0.000171205 s` `20.024421015741364x` | `0.001592878 s` `25.938249508123032x` | `0.015623479 s` `27.15245503258269x` | `0.155503719 s` `27.559469667731868x` | `1.555094839 s` `28.559160728460242x` | julia | `0.000324641 s` `0.012560687915926473x` | `0.000362327 s` `0.8399512042988792x` | `0.000688293 s` `4.980845366726089x` | `0.005954144 s` `6.93911114679121x` | `0.07092169 s` `5.9814678838025435x` | `0.717779129 s` `5.97063895264082x` | `7.251904592 s` `6.124212321269877x` | julia_base | `4.077714285714286e-6 s` `1.0x` | `0.000304337 s` `1.0x` | `0.003428281 s` `1.0x` | `0.041316467 s` `1.0x` | `0.424215811 s` `1.0x` | `4.285600027 s` `1.0x` | `44.412203455 s` `1.0x` |

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

| device | N = 10^1 | N = 10^2 | N = 10^3 | N = 10^4 | N = 10^5 | N = 10^6 | N = 10^7 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| cudanative | `0.001260562 s` `0.006916491744687422x` | `0.001442064 s` `0.040737442998369004x` | `0.001632029 s` `0.36584398929185696x` | `0.003217 s` `1.8180310848616723x` | `0.013882076 s` `6.785162464173226x` | `0.150109303 s` `22.49486982162591x` | `1.687662927 s` `16.42296541067528x` | opencl | `0.008193641 s` `0.0010640772114212309x` | `0.007776222 s` `0.0075545682723564215x` | `0.007870141 s` `0.07586496862000312x` | `0.011529233 s` `0.5072849165248027x` | `0.038044846 s` `2.4758186956519683x` | `0.317844393 s` `10.623718097175935x` | `4.118864269 s` `6.729143779658742x` | julia | `0.00016425 s` `0.05308168442415018x` | `0.00533425 s` `0.011012982143694052x` | `0.006312096 s` `0.09459108353231636x` | `0.019956859 s` `0.2930624503585459x` | `0.15138273 s` `0.6222119326293032x` | `5.725396592 s` `0.5897738568395753x` | `22.478433909 s` `1.23302317177456x` | julia_base | `8.718666666666667e-6 s` `1.0x` | `5.8746e-5 s` `1.0x` | `0.000597068 s` `1.0x` | `0.005848606 s` `1.0x` | `0.094192141 s` `1.0x` | `3.37668923 s` `1.0x` | `27.716429875 s` `1.0x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/PDE.jl/)

___

### Mapreduce
Mapreduce, e.g. sum!.
Interestingly, for the sum benchmark the arrayfire opencl backend is the fastest, while GPUArrays OpenCL backend is the slowest.
This means we should be able to remove the slowdown for GPUArrays + OpenCL and maybe also for all the CUDA backends.

#### Sum
[![sum](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/sum.png/?raw=true)](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/mapreduce.jl/)

| device | N = 10^1 | N = 10^2 | N = 10^3 | N = 10^4 | N = 10^5 | N = 10^6 | N = 10^7 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| arrayfire_cl | `0.010631 ms` `0.0004949675477377481x` | `0.010577 ms` `0.0009917263391783578x` | `0.012578 ms` `0.004334578247992688x` | `0.02171 ms` `0.033168976731850985x` | `0.023449 ms` `0.30404281632478997x` | `0.063471 ms` `1.1354319295426258x` | `0.435955 ms` `3.835310983931828x` | cudanative | `0.017944 ms` `0.0002932456531431119x` | `0.017295 ms` `0.0006065041624451859x` | `0.017651 ms` `0.003088795263908676x` | `0.019506 ms` `0.03691676842245898x` | `0.038046 ms` `0.18739157861536035x` | `0.088728 ms` `0.8122238752141376x` | `0.473985 ms` `3.527586316022659x` | cuarrays | `0.025401 ms` `0.00020715719853549072x` | `0.024947 ms` `0.00042047097805305206x` | `0.025354 ms` `0.002150363855930111x` | `0.025744 ms` `0.027971507335631016x` | `0.040483 ms` `0.1761109601561149x` | `0.119869 ms` `0.6012146593364422x` | `0.474546 ms` `3.523416065039006x` | arrayfire_cu | `0.009552 ms` `0.0005508793969849245x` | `0.011143 ms` `0.0009413523727442779x` | `0.011112 ms` `0.004906436753352415x` | `0.019859 ms` `0.03626056119887632x` | `0.020672 ms` `0.34488680340557276x` | `0.066743 ms` `1.079768664878714x` | `0.48841 ms` `3.423400421776786x` | julia | `0.011412 ms` `0.0004610935856992639x` | `0.011407 ms` `0.0009195660111764258x` | `0.011457 ms` `0.004758691210897446x` | `0.012724 ms` `0.05659371933735342x` | `0.025037 ms` `0.284758557335144x` | `0.146549 ms` `0.4917604350763226x` | `1.447729 ms` `1.154928166804699x` | julia_base | `5.262e-6 ms` `1.0x` | `1.048948948948949e-5 ms` `1.0x` | `5.4520325203252036e-5 ms` `1.0x` | `0.0007200984848484849 ms` `1.0x` | `0.0071295 ms` `1.0x` | `0.072067 ms` `1.0x` | `1.672023 ms` `1.0x` | opencl | `0.054363 ms` `9.679377517797031e-5x` | `0.054437 ms` `0.0001926904401324373x` | `0.054429 ms` `0.001001677877661762x` | `0.058518 ms` `0.012305589474152993x` | `0.094503 ms` `0.07544204945874734x` | `0.488419 ms` `0.14755158992586284x` | `4.450145 ms` `0.3757232629498589x` |

[code](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/benchmark/mapreduce.jl/)

___

