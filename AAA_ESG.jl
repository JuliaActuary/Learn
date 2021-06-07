### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 7056a580-e8b6-11ea-2ac9-ad6ced139615
begin 
    using Random
    using UnPack
	using Plots
	using Statistics
	using ActuaryUtilities
	using ThreadsX # for easy multithreading
end

# ╔═╡ f04b8ce0-ea39-11ea-05ad-a996c592cc82
md"""
# AAA ESG Exploration Tool
This reactive notebook explores the sensitivity of the American Academy of Actuaries' (AAA) [Economic Scenario Generator (ESG)](https://www.actuary.org/content/economic-scenario-generators) to changing parameters.  

It's a simple demo intended to be informative about the underlying model producing the interest rates, as well as showcase some aspects of the Julia ecosystem:
- **Reactive Notebooks** interact with and learn from your data in ways traditional notebooks won't let you. 
   - Cell order doesn't matter!
   - Hover over the cells and click the eye icon to expand the cell to see any hidden code cells.
- **Performance** - Work with thousands of simulations and visualize them in realtime
- **Syntax** - Expand some of the code cells below to see code that looks more like math, e.g. this line of code:
```julia
α_τ =(1-β₂) * α_τ + β₂ * τ₂ + ϕ * (log(r₁) - log(τ₁)) + σ₂ * shock_short * r₁^θ
```
- **Dynamic and robust plotting libaraies** - `Plots.jl` in this case



"""

# ╔═╡ 018237f0-ea3c-11ea-387e-abf5110ac1fa
md"""
## Interactive ESG
### Interactive Parameters:
You can edit these and watch the results change in realtime.
"""

# ╔═╡ dabece20-ea37-11ea-2e6a-61eda948928f
@bind n_scenarios html"""
	Number of Scenarios: <input type='number' min='1' max='5' value='200' />
    
	"""

# ╔═╡ 63507e40-ea34-11ea-00c3-31bd881aa1bc
@bind τ₁ html"""
	Long Term Mean Reversion Point <input type='range' min='0.0' max='0.1' value='0.035' step='0.005'
	oninput=\"document.getElementById('fPrice').innerHTML = this.value\" />
        <label id='fPrice'>0.035</label>
	"""

# ╔═╡ 13c9baf0-ea37-11ea-16d5-f9f87c35e4f4
@bind vol html"""
	Process Volatility <input type='range' min='0.05' max='0.3' value='0.11489' step='0.005'
	oninput=\"document.getElementById('fPrice').innerHTML = this.value\" />
        <label id='fPrice'>0.11489</label>
	"""

# ╔═╡ 2cc3d3b0-ea3c-11ea-2c4f-4bd1db712846
md"### Scenario Visualization"

# ╔═╡ 9a6a036e-b4f1-40a8-b3ea-724a1542fb26
md"
#### Long Rate Statistics:
"

# ╔═╡ 56f67070-ea3c-11ea-31f5-b7d1f7182a31
md"This histogram was inspired by the article [Illuminating the Low Interest Peril](https://www.soa.org/globalassets/assets/library/newsletters/financial-reporter/2020/july/fr-2020-iss-07.pdf) in the July 2020 Financial Reporter:"

# ╔═╡ 844a9e50-f128-11ea-10b1-a1d7792c8fc4
md"Example of one of the the scenarios:"

# ╔═╡ 23cba4a0-ea3b-11ea-2b62-8dfc856875b7
md"""
# Notebook Details
The following cells contain the code that generates the parameters and scenarios

## Deploying a dashboard/tool like this

You likely had to download it and run it yourself because [JuliaActuary](https://juliaactuary.org/) doesn't have a server laying around for you to run stochastic simulations on!

However, as you can see it's running over HTTP so would be straightforward to take something like this and make it an end-user dashboard.
"""

# ╔═╡ f15e18e0-ea3a-11ea-3868-d9236a4810a1
md"The starting curve is based on 12/31/2020:"

# ╔═╡ 79cfe060-e9f4-11ea-2fc8-b769419cc4fd
start_curve = [0.0155, 0.0160, 0.0159, 0.0158, 0.0162, 0.0169, 0.0183, 0.0192, 0.0225, 0.0239]

# ╔═╡ 49419d10-e861-11ea-36e0-e19ece503681
# this is a function which takes a couple of input parameters and returns a named 
# tuple with all of the required parameters for the AAA ESG
full_params(τ₁=0.035,vol=0.11489
	) = (
	τ₁ = τ₁,   # Long term rate (LTR) mean reversion
	β₁ = 0.00509, # Mean reversion strength for the log of the LTR
	θ = 1,
	τ₂ = 0.01,    # Mean reversion point for the slope
	β₂ = 0.02685, # Mean reversion strength for the slope
	σ₂ = 0.04148, # Volatitlity of the slope
	τ₃ = 0.0287,  # mean reversion point for the vol of the log of LTR
	β₃ = 0.04001, # mean reversion strength for the log of the vol of the log of LTR
	σ₃ = vol, # vol of the stochastic vol process
	ρ₁₂ = -0.19197, # correlation of shocks to LTR and slope (long - short)
	ρ₁₃ = 0.0,  # correlation of shocks to long rate and volatility
	ρ₂₃ = 0.0,  # correlation of shocks to slope and volatility
	ψ = 0.25164,
	ϕ = 0.0002,
	r₂_min = 0.01, # soft floor on the short rate
	r₂_max = 0.4, # unused - maximum short rate
	r₁_min = 0.015, # soft floor on long rate before random shock
	r₁_max = 0.18, # soft cap on long rate before random shock
	κ = 0.25, # unused - when the short rate would be less than r₂_min it was κ * long 
	γ = 0.0, # unused - don't change from zero
	σ_init = 0.0287,
	months = 12 * 30,
	rate_floor = 0.0001, # absolute rate floor
	maturities = [0.25,0.5,1,2,3,5,7,10,20,30],
)

# ╔═╡ 1a5bb1b0-ea33-11ea-3514-e1c85b65d356
params = full_params(τ₁,vol)

# ╔═╡ 4ff1ccc0-e8b6-11ea-20be-d7992829086d
# This replicates the American Academy of Actuaries' scenario generator v7.1.202005
# No guarantees on the output!
function scenario(start_curve,params)
    @unpack τ₁,β₁,θ,τ₂,β₂,σ₂,τ₃,β₃,σ₃,ρ₁₂,ρ₁₃,ρ₂₃,ψ,ϕ,r₂_min,r₂_max,r₁_min,r₁_max,κ,γ,σ_init,months,rate_floor,maturities = params
    # some constants
	const1 =  √(1-ρ₁₂^2)
	const2 = (ρ₂₃-ρ₁₂*ρ₁₃)/(const1)
	const3 = √(1-((ρ₂₃ - ρ₁₂*ρ₁₃)^2)/(1ρ₁₂^2)-ρ₁₃^2)
	const4 = β₃ * log(τ₃)
	const5 = β₁ * log(τ₁)
	
	# Nelson Siegel interpolation factors
	ns_interp = [(1 - exp(-0.4 * m)) / ( 0.4 * m) for m in maturities]
	
	
	# containers for hot values
	rates = zeros(months,10) # allocate initial 
	shock = zeros(3)
	ns_fitted = zeros(10)
	
	# initial values
	v_τ = log(σ_init) # long rate log vol
	σ_longvol = σ_init
	α_τ = start_curve[9]-start_curve[3]
	pertubation = 1.0
	
	r₁ = start_curve[9]
	r₂ = max(r₂_min,start_curve[3])
    
    b₁ = (r₂ - r₁) / (ns_interp[3] - ns_interp[9])
    b₀ = r₂ - b₁ * ns_interp[3]

	
	ns_fitted .= b₀ .+ b₁ .* ns_interp 
	start_diff = ns_fitted .- start_curve 
	
	for month in 1:months

		## Correlated Normals
        randn!(shock)
        # shock .= norms'[:,month]
		shock_long  = shock[1]
		shock_short = shock[1] * ρ₁₂ + shock[2] * const1
		shock_vol   = shock[1] * ρ₁₃ + shock[2] * const2 + shock[3] * const3
			
		## Generator Process
		v_τ =(1-β₃) * v_τ + const4 + σ₃ * shock_vol
		σ_longvol = exp(v_τ)
		
        # moved this after r₁ because it uses the prior val
        
        
        α_τ_prior = α_τ
        α_τ =(1-β₂) * α_τ + β₂ * τ₂ + ϕ * (log(r₁) - log(τ₁)) + σ₂ * shock_short * r₁^θ
		
        ## Generator Results
        
        r_pre = (1-β₁)*log(r₁)+const5+ψ*(τ₂-α_τ_prior)
		r₁ = exp(clamp(r_pre,log(r₁_min),log(r₁_max)) + σ_longvol * shock_long)
		
		
		r₂ = max(r₁ - α_τ,r₂_min)
        
        
		## Nelson-Siegel Fitted Curve
		ns_fitted .= b₀ .+ b₁ .* ns_interp
		
        b₁ = (r₂ - r₁) / (ns_interp[3] - ns_interp[9])
        b₀ = r₂ - b₁ * ns_interp[3]
        
        ## Fully Interpolated Curve
		
		rates[month,:] .= max.(rate_floor, ns_fitted .- pertubation .* start_diff)
		
		# Update values for next loop
		pertubation = max(0.0,pertubation - 1/12)


	end
	
	return rates
end

# ╔═╡ c5078e00-e8b6-11ea-105b-9731d9852664
scenarios = ThreadsX.map(i -> scenario(start_curve,params), 1:n_scenarios);

# ╔═╡ 076facc0-e9f5-11ea-2fa5-91cfaa965d08
# note that the CTE function requires ActuaryUtilities v2.1 or higher
let
	# average and CTE70 and CTE98 of 20 year rates
	stats = ThreadsX.map(s -> (
			mean= mean(s[:,9]),
			CTE70=CTE(s[:,9],.7,rev=true),
			CTE98=CTE(s[:,9],.98,rev=true)
			),scenarios)
	h1 = histogram(
		[x.mean for x in stats],  
		label="",
		orientation = :horizontal,
		alpha=0.5,
		ylim = (0.,.1),
		ylabel="20-Year Interset Rate",
		xlim=(0,(n_scenarios ÷ 20)),
		xtick=:none,
		grid=false,
		title="Mean",
		bins = 0.:0.0025:.1,
	)
 		h2 = histogram(
		[x.CTE70 for x in stats],
		alpha=0.5,
		title="CTE70",
		label="",
		ylim = (0.,.1),
		xlim=(0,(n_scenarios ÷ 20)),
		xtick=:none,
		ytick=:none,
		orientation = :horizontal,
		bins = 0.:0.0025:.1,
	)
	 	h3 = histogram(
		[x.CTE98 for x in stats],
		alpha=0.5,
		title="CTE98",
		label="",
		ylim = (0.,.1),
		xlim=(0,(n_scenarios ÷ 20)),
		xtick=:none,
				ytick=:none,
		orientation = :horizontal,
		
		bins = 0.:0.0025:.1,
	)
	plot([h1,h2,h3]...,layout=(1,3))
end

# ╔═╡ 7f7a2280-ea2d-11ea-2ee8-79bc4c3a72ec
 let
 	p = plot(legend=false,title="Long Rate Paths",ylim=(0,.15))

 	for s in scenarios
 		plot!(p,s[:,9], color=:blue, alpha=0.05)
 	end
 	p
 end

# ╔═╡ 783904d0-f128-11ea-22f9-43d6dc7b8439
scenarios[1]

# ╔═╡ 69730d30-ea37-11ea-05be-8350df76fd06
md"""
The same disclaimer from the Academy applies:

    From time to time, the American Academy of Actuaries makes available through its website or other means various scenarios and tools. The Academy takes reasonable steps to develop such scenarios and tools consistent with accepted actuarial principles and practices. However, the Academy does not warranty these scenarios and tools as fit for use in any respect, and no warranty should be assumed or implied by any individual. Actuaries, insurers, regulators and other parties use the Academy's scenarios and tools at their own risk. The Academy disclaims all responsibility for any party's use or misuse of its scenarios or tools and for any work product generated through use or misuse of the scenarios and tools.

"""

# ╔═╡ Cell order:
# ╟─f04b8ce0-ea39-11ea-05ad-a996c592cc82
# ╟─018237f0-ea3c-11ea-387e-abf5110ac1fa
# ╟─dabece20-ea37-11ea-2e6a-61eda948928f
# ╟─63507e40-ea34-11ea-00c3-31bd881aa1bc
# ╟─13c9baf0-ea37-11ea-16d5-f9f87c35e4f4
# ╟─2cc3d3b0-ea3c-11ea-2c4f-4bd1db712846
# ╟─9a6a036e-b4f1-40a8-b3ea-724a1542fb26
# ╠═076facc0-e9f5-11ea-2fa5-91cfaa965d08
# ╟─7f7a2280-ea2d-11ea-2ee8-79bc4c3a72ec
# ╟─56f67070-ea3c-11ea-31f5-b7d1f7182a31
# ╟─844a9e50-f128-11ea-10b1-a1d7792c8fc4
# ╟─783904d0-f128-11ea-22f9-43d6dc7b8439
# ╟─23cba4a0-ea3b-11ea-2b62-8dfc856875b7
# ╠═7056a580-e8b6-11ea-2ac9-ad6ced139615
# ╟─f15e18e0-ea3a-11ea-3868-d9236a4810a1
# ╟─79cfe060-e9f4-11ea-2fc8-b769419cc4fd
# ╟─1a5bb1b0-ea33-11ea-3514-e1c85b65d356
# ╟─49419d10-e861-11ea-36e0-e19ece503681
# ╟─4ff1ccc0-e8b6-11ea-20be-d7992829086d
# ╠═c5078e00-e8b6-11ea-105b-9731d9852664
# ╟─69730d30-ea37-11ea-05be-8350df76fd06
