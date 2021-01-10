### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 621fa420-5392-11eb-1c1e-d35ed6a9ddc0
begin
	using OffsetArrays
	using BenchmarkTools
	using Memoization
end

# ╔═╡ d35a7228-5394-11eb-29b1-43cd660605f0
md"
This notebook shows a translation of [this notebook](https://www.kaggle.com/lewisfogden/the-life-modelling-problem) into Julia and an example of memoization of actuarial calculations.

To *not* memoize, remove the `@memoize` placed before various function definitions.

When memoized, the calculations benchmark goes from `~650µs` to `~15µs`
"


# ╔═╡ 135c48c4-5391-11eb-1941-07f9ffd5e22d
q = OffsetArray([0.001,
     0.002,
     0.003,
     0.003,
     0.004,
     0.004,
     0.005,
     0.007,
     0.009,
     0.011],-1)

# ╔═╡ 3e501fda-5391-11eb-2c84-dfc93c9b8871
w = OffsetArray([0.05,
     0.07,
     0.08,
     0.10,
     0.14,
     0.20,
     0.20,
     0.20,
     0.10,
     0.04],-1)

# ╔═╡ d6f1f9da-5395-11eb-2608-a10b027a9721
md" Note that all of the loose parameters in the source notebook are combined into one parameters tuple:"

# ╔═╡ 55440cf6-5391-11eb-06f7-ed0c64129bde
params = (
	prem = 100,
	face = 25_000,
	term = 10,
	w = w,
	q = q,
	int_rate = 0.02
	)
	

# ╔═╡ 6d50caa0-5391-11eb-0572-9de6d4af4b85
begin 
	@memoize function num_in_force(t,params)
		if t == 0
			return 1.0
		elseif t >= params.term
			return 0.0
		else
			return num_in_force(t-1,params) - num_deaths(t-1,params) - num_lapses(t-1,params)
		end
	end
	
	@memoize function num_deaths(t,params)
		if t < params.term
			return num_in_force(t,params) * params.q[t]
		else
			return 0
		end
	end
	
	@memoize function num_lapses(t,params)
		if t < params.term
			return num_in_force(t,params) * params.w[t]
		end
	end
	
	
end

# ╔═╡ e275cd2a-5392-11eb-2e41-a5eddbdaa5e9
begin
	claims(t,params) = num_deaths(t,params) * params.face
	premiums(t, params) = num_in_force(t,params) * params.prem
	net_cashflows(t,params) = return premiums(t,params) - claims(t,params)
end

# ╔═╡ 9478fbba-5392-11eb-017b-91c4a8ddde90
map(0:10) do t
	(
		time = t,
		ℓ = num_in_force(t,params),
		claims = claims(t,params),
		premiums = premiums(t,params),
		net_cfs = net_cashflows(t,params),
	)
end
		

# ╔═╡ 4109cc9c-5393-11eb-3e82-59e4b89f6e05
function npv(cashflow, params)
	val = 0
	for t in 0:params.term
		val = (val + cashflow(t, params)) / (1 + params.int_rate)
	end
	return val
end
	

# ╔═╡ 83ce88a6-5393-11eb-0c7c-551d48ada79d
@benchmark npv(net_cashflows,params)

# ╔═╡ 24013174-5395-11eb-0ed6-2f9b874a2d20


# ╔═╡ Cell order:
# ╟─d35a7228-5394-11eb-29b1-43cd660605f0
# ╠═621fa420-5392-11eb-1c1e-d35ed6a9ddc0
# ╠═135c48c4-5391-11eb-1941-07f9ffd5e22d
# ╠═3e501fda-5391-11eb-2c84-dfc93c9b8871
# ╟─d6f1f9da-5395-11eb-2608-a10b027a9721
# ╠═55440cf6-5391-11eb-06f7-ed0c64129bde
# ╠═6d50caa0-5391-11eb-0572-9de6d4af4b85
# ╠═e275cd2a-5392-11eb-2e41-a5eddbdaa5e9
# ╠═9478fbba-5392-11eb-017b-91c4a8ddde90
# ╠═4109cc9c-5393-11eb-3e82-59e4b89f6e05
# ╠═83ce88a6-5393-11eb-0c7c-551d48ada79d
# ╠═24013174-5395-11eb-0ed6-2f9b874a2d20
