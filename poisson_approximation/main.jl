using Turing
using CairoMakie
using StatsBase
using MCMCChains
using DataFrames
using ThreadsX

@model function poisson(N,deaths) 
	q ~ Beta(1,1)
	
	deaths~ Poisson(q*N)
end

@model function binom(N,deaths) 
	q ~ Beta(1,1)
	
	deaths~ Binomial(N,q)
end

qs = 0.05:0.1:0.95
Ns = 5:15:115
model_points =  [(;q,N) for q in qs, N in Ns]

bpchains = map(model_points) do mp
	
    ThreadsX.map(1:20) do i
        claims = sum(rand() < mp.q for _ in 1:mp.N)
        bc = sample(binom(mp.N,claims), NUTS(), 1000)
        pc = sample(poisson(mp.N,claims), NUTS(), 1000)

        (;bc,pc)
    end
end
	

let
    f = Figure()
    ax = Axis(f[1,1],
    xticks=qs,
    yticks=Ns,
    )

    offset = 3
	for n in 1:length(model_points)
		c = bpchains[n]
		y = model_points[n].N
        qtls = [quantile(x.bc["q"][:],[.25,.40,.60,.75]) for x in c]
        xs = vec(mean(hcat(qtls...);dims=2))
        ys = fill(y,length(xs))
        mid = [2,3]
        outer = [1,4]
		lines!(ax,xs[mid],ys[mid] .+ offset,color=:grey30,linewidth=10)
		lines!(ax,xs[outer],ys[outer] .+ offset ,color=:grey30,label="Binomial")
        scatter!(
            vec([p.q for p in model_points]),
            vec([p.N for p in model_points]),
            marker = :vline,
            label="actual value"
            )

        qtls = [quantile(x.pc["q"][:],[.25,.40,.60,.75]) for x in c]
        xs = vec(mean(hcat(qtls...);dims=2))
        ys = fill(y,length(xs))
        mid = [2,3]
        outer = [1,4]
        lines!(ax,xs[mid],ys[mid] .- offset,color=:grey50,linewidth=10)
        lines!(ax,xs[outer],ys[outer] .- offset ,color=:grey50,label="Poisson")

        axislegend(ax,unique=true)
        
	end
    display(f)
end