module PDE

using GPUBenchmarks, BenchmarkTools, Primes

description = """
Kuramoto-Sivashinsky algorithm benchmark.
[Original code](https://github.com/johnfgibson/julia-pde-benchmark/blob/master/1-Kuramoto-Sivashinksy-benchmark.ipynb)
This benchmark is dominated by the cost of the FFT, leading to worse results for OpenCL with
CLFFT compared to the faster CUFFT.
Similarly the multithreaded backend doesn't improve much over base with the same FFT implementation.
Result of the benchmarked PDE:
![](https://github.com/JuliaGPU/GPUBenchmarks.jl/blob/master/results/plots/pde_result.png?raw=true)
"""


sq3(x) = Complex64(x * x * x) # cudanative doesn't like Complex64 directly broadcasted.

# source: http://nbviewer.jupyter.org/url/homepages.warwick.ac.uk/staff/C.Ortner/julia/PlaneWaves.ipynb
# an optimised implementation of CH_vectorised!

function inner_loop(
        nruns,
        planv, planw, planwi, u0, u, v, w, Â,
        c1, c2, c3, c4
    )
    u .= identity.(u0)
    w .= tocomplex64.(u0)
    for n = 1:nruns
        v .= sq3.(u)
        planv * v
        planw * w
        @. w = ((1f0+c1*Â)*w - (c2*Â)*v) / ((1f0+c3*Â+c4)*Â)
        planwi * w
        u .= real.(w)
    end
    synchronize(u)
    return u
end


function makeresult(bench, N, device, hardware, mdiff)
    BenchResult(
        "PDE",
        bench,
        N,
        Float32,
        string(device),
        hardware,
        @__FILE__,
        mdiff
    )
end

function execute2(device)
    hardware, array_type = init(device)
    T = Float32
    results = BenchResult[]
    for x in (4,)
        N = 2 ^ x
        # initialisations
        h = 2*π/N; epsn = h * 3; C = 2/epsn; tau = epsn * h
        k = [0:N/2; -N/2+1:-1]
        acpu = kron(k.^2, ones(1,N)) + kron(ones(N), k'.^2)
        ucpu = 2*(rand(N, N)-0.5)

        Â = array_type(T.(acpu))
        u = array_type(T.(ucpu))

        w = tocomplex64.(u)
        v = copy(w)
        c1 = (C*tau + tau/epsn)
        c2 = (tau / epsn)
        c3 = (epsn * tau)
        c4 = (C*tau)
        planv = plan_fft!(v)
        planw = plan_fft!(w)
        planwi = plan_ifft!(w)
        nruns = 5
        u0 = copy(u)
        bench = @benchmark $(inner_loop)(
                $nruns,
                $planv, $planw, $planwi,$u0, $u, $v, $w, $Â,
                $c1, $c2, $c3, $c4
        )
        wcpu = tocomplex64.(ucpu)
        vcpu = copy(wcpu)
        planvcpu = plan_fft!(vcpu)
        planwcpu = plan_fft!(wcpu)
        planwicpu = plan_ifft!(wcpu)
        inner_loop(
                nruns,
                planvcpu, planwcpu, planwicpu, copy(ucpu), ucpu, vcpu, wcpu, acpu,
                c1, c2, c3, c4
        )
        println(Array(ucpu))
        # mdiff = meandifference(ucpu, u)
        # @show mdiff
        # push!(results, makeresult(bench, N, device, hardware, mdiff))
        # free(Â); free(u0); free(u); free(v); free(w)
    end
    results
end

# execute(Float32, 512, :opencl)

function CH_memory_af!(nruns, N, AT)
    # initialisations
    h = Float32(2*π/N); epsn = Float32(h * 3); C = Float32(2/epsn); tau = Float32(epsn * h)
    k = [0:N/2; -N/2+1:-1]
    Â = AT((Float32.(kron(k.^2, ones(1,N)) + kron(ones(N), k'.^2))))
    u = AT(Float32.((2*(rand(N, N)-0.5))))


    # ============= ACTUAL CODE THAT IS BEING TESTED ======================
    # allocate arrays and define constants
    w = AT{Complex64}(u)
    v = copy(w)
    c1 = (C*tau + tau/epsn)
    c2 = (tau / epsn)
    c3 = (epsn * tau)
    c4 = (C*tau)
    tic()
    for n = 1:nruns
        v .= complex.(u .* u .* u)
        v = fft(v)
        w = fft(w)
        w .= (( (1f0 + c1) .* Â) .* w .- (c2 .* Â) .* v) ./ ((1f0 + c3 .* Â .+ c4) .* Â)
        w = ifft(w)
        u .= real.(w)
    end
    GPUArrays.synchronize(u)
    toc()
    # ======================================================================
    u
end

# source: https://github.com/johnfgibson/julia-pde-benchmark/blob/master/1-Kuramoto-Sivashinksy-benchmark.ipynb
function inner_ks(IFFT!, FFT!, Nt, Nn, Nn1, u, G, A_inv, B, dt2, dt32)
    for n = 1:Nt
        Nn1 .= Nn       # shift nonlinear term in time
        Nn .= u         # put u into Nn in prep for comp of nonlinear term

        IFFT! * Nn
            # transform Nn to gridpt values, in place
        Nn .= Nn .* Nn   # collocation calculation of u^2
        FFT!*Nn        # transform Nn back to spectral coeffs, in place

        Nn .= G .* Nn    # compute Nn == -1/2 d/dx (u^2) = -u u_x

        # loop fusion! Julia translates the folling line of code to a single for loop.
        u .= A_inv .* (B .* u .+ dt32 .* Nn .- dt2 .* Nn1)
    end
    synchronize(u)
end

function makeresult(bench, N, device, hardware, mdiff)
    BenchResult(
        "PDE",
        bench,
        N,
        Complex64,
        string(device),
        hardware,
        @__FILE__,
        mdiff
    )
end
function execute(device)
    hardware, AT = init(device)
    results = BenchResult[]
    is_gpuarrays(device) || device == :julia_base || return results
    T = Float32
    for i = 1:7
        N = 10^i
        Lx = T(64*pi)
        Nx = T(N)
        dt = T(1/16)
        Nt = 50

        x = Lx*(0:Nx-1)/Nx
        u = T.(cos.(x) + 0.1*sin.(x/8) + 0.01*cos.((2*pi/Lx)*x))

        u = AT((T(1)+T(0)im)*u)             # force u to be complex
        Nx = length(u)                      # number of gridpoints
        kx = T.(vcat(0:Nx/2-1, 0:0, -Nx/2+1:-1))# integer wavenumbers: exp(2*pi*kx*x/L)
        alpha = T(2)*pi*kx/Lx                  # real wavenumbers:    exp(alpha*x)

        D = T(1)im*alpha                       # spectral D = d/dx operator

        L = alpha.^2 .- alpha.^4            # spectral L = -D^2 - D^4 operator

        G = AT(T(-0.5) .* D)               # spectral -1/2 D operator, to eval -u u_x = 1/2 d/dx u^2

        # convenience variables
        dt2  = T(dt/2)
        dt32 = T(3*dt/2)
        A_inv = AT((ones(T, Nx) - dt2*L).^(-1))
        B = AT(ones(T, Nx) + dt2*L)

        # compute in-place FFTW plans
        FFT! = plan_fft!(u)
        IFFT! = plan_ifft!(u)

        # compute nonlinear term Nn == -u u_x
        powed = u .* u
        Nn = G .* fft(powed);    # Nn == -1/2 d/dx (u^2) = -u u_x
        Nn1 = copy(Nn);        # Nn1 = Nn at first time step
        FFT! * u;

        # timestepping loop
        bench = @benchmark $inner_ks($(IFFT!), $(FFT!), $Nt, $Nn, $Nn1, $u, $G, $A_inv, $B, $dt2, $dt32)
        push!(results, makeresult(bench, N, device, hardware, 0.0))
    end
    results
end


function ksintegrateNaive(u, Lx, dt, Nt, nsave)
    Nx = length(u)                  # number of gridpoints
    x = collect(0:(Nx-1)/Nx)*Lx
    kx = vcat(0:Nx/2-1, 0, -Nx/2+1:-1)  # integer wavenumbers: exp(2*pi*kx*x/L)
    alpha = 2*pi*kx/Lx              # real wavenumbers:    exp(alpha*x)
    D = 1im*alpha;                  # D = d/dx operator in Fourier space
    L = alpha.^2 - alpha.^4         # linear operator -D^2 - D^4 in Fourier space
    G = -0.5*D                      # -1/2 D operator in Fourier space

    Nsave = div(Nt, nsave)+1        # number of saved time steps, including t=0
    t = (0:Nsave)*(dt*nsave)        # t timesteps
    U = zeros(Nsave, Nx)            # matrix of u(xⱼ, tᵢ) values
    U[1,:] = u                      # assign initial condition to U
    s = 2                           # counter for saved data

    dt2  = dt/2
    dt32 = 3*dt/2;
    A_inv = (ones(Nx) - dt2*L).^(-1)
    B     =  ones(Nx) + dt2*L

    Nn  = G.*fft(u.*u) # -u u_x (spectral), notation Nn = N^n     = N(u(n dt))
    Nn1 = copy(Nn)     #                   notation Nn1 = N^{n-1} = N(u((n-1) dt))
    u  = fft(u)        # transform u to spectral

    # timestepping loop
    for n = 1:Nt
        Nn1 = copy(Nn)                 # shift nonlinear term in time: N^{n-1} <- N^n
        Nn  = G.*fft(real(ifft(u)).^2) # compute Nn = -u u_x

        u = A_inv .* (B .* u + dt32*Nn - dt2*Nn1)

        if mod(n, nsave) == 0
            U[s,:] = real(ifft(u))
            s += 1
        end
    end
    t,U
end
#
# using FileIO, Interpolations, Colors, GPUBenchmarks, GPUArrays, ColorVectorSpace, FixedPointNumbers
# Lx = 64*pi
# Nx = 1024
# dt = 1/16
# nsave = 8
# Nt = 3200
#
# x = Lx*(0:Nx-1)/Nx
# u = cos.(x) + 0.1*sin.(x/8) + 0.01*cos.((2*pi/Lx)*x);
# t,U = ksintegrateNaive(u, Lx, dt, Nt, nsave)
# cn = 100
# cmap = interpolate(colormap("Oranges", cn), BSpline(Linear()), OnCell());
# mini, maxi = extrema(U)
# img_color = map(U) do val
#     val = (val - mini) / (maxi - mini)
#     val = 1 - clamp(val, 0f0, 1f0);
#     idx = (val * (cn - 1)) + 1.0
#     RGB{N0f8}(cmap[idx])
# end
# save(GPUBenchmarks.dir("results", "plots", "pde_result.png"), img_color)

end
