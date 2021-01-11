### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ ceff6126-51fc-11eb-3cf5-dd30d637e267
begin
	using Dates 
	using MortalityTables 
	using DifferentialEquations 
	using Plots 
	using ActuaryUtilities
end

# ╔═╡ cd5e7080-5348-11eb-2c22-455a3556cab0
md"
# Universal Life Policy Account Mechanics as a Differential Equation
"

# ╔═╡ de0ace1a-5348-11eb-35c9-5f0ff4009d97
md"""
## Introduction

This demonstrates an example of defining an universal life policy value roll like a discrete differential equation. 

It then uses the [SciML DifferentialEquations](https://sciml.ai/) package to "solve" the policy projection given a single point, but also to see how the policy projection behaves under different premium and interest rate conditions./
"""

# ╔═╡ ef26ffb6-5348-11eb-04a8-c5cbfdcab72a
md"""
Let's use the 2001 CSO table as the basis for cost of insurance charges:
"""

# ╔═╡ 45dab59c-528d-11eb-357d-af3664466910
begin
	tables = MortalityTables.tables()
	cso = tables["2001 CSO Super Preferred Select and Ultimate - Male Nonsmoker, ANB"]
end

# ╔═╡ ffe9b6e0-5348-11eb-2d38-a5613eb24383
md"""
Next, policy mechanics are coded. It's essentially a discrete differential equation, so it leverages [`DifferentialEquations.jl`](https://diffeq.sciml.ai/dev/)

The projection is coded in the [Discrete DifferentialEquation format](https://diffeq.sciml.ai/dev/types/discrete_types/):

``u_{n+1} = f(u,p,t_{n+1})``

In the code below, this translates to:

- `u` is the *state* of the system. We  will track three variables to represent the `state`:
   - `state[1]` is the account value
   - `state[2]` is the premium paid
   - `state[3]` is the policy duration
- `p` are the parameters of the system.
- `t` is the time, which will represent days since policy issuance
"""

# ╔═╡ da199644-51fc-11eb-0aab-dd68b1fcddc6
function policy_projection(state,p,t)
    # grab the state from the inputs
    av = state[1] 
    
    # calculated variables
    cur_date = p.issue_date + Day(t)
    dur = duration(p.issue_date,cur_date)
    att_age = p.issue_age + dur - 1
	
	# lapse if AV <= 0 
    lapsed = (av <= 0.0 ) & (t > 1) 
    
    if !lapsed 

        monthly_coi_rate = (1 - (1-p.mort_assump[att_age]) ^ (1/12))

		## Periodic Policy elements
		
        # annual events
        if Dates.monthday(cur_date) == Dates.monthday(p.issue_date) || 
			cur_date ==p.issue_date + Day(1) # OR first issue date
			
            premium = p.annual_prem
        else
            premium = 0.0
        end

        # monthly_events
        if Dates.day(cur_date) == Dates.day(p.issue_date)
            coi = max((p.face - av) * monthly_coi_rate,0.0)
        else
            coi = 0.0
        end

        # daily events
        int(av) = av * ((1 + p.int_rate) ^ (1 / 360) - 1.0)


        
        # av
        new_av = max(0.0,av - coi + premium + int(av-coi)) 
	
				# new state
		return [new_av, premium, dur] # AV, Prem, Dur
        
    else
		# new state
		return [0.0, 0.0, dur] # AV, Prem, Dur
        
    end
	
    
end

# ╔═╡ 8a227236-5349-11eb-353d-1d3f94a968d0
md"The following function will create a named tuple of parameters given a varying `prem` (premium) and `int` (credit rate)."

# ╔═╡ 956811e4-5349-11eb-2b34-b5441def32a1
params(prem,int) = (
    int_rate = int,
    issue_date = Date(2010,1,1),
    face = 1e6,
    issue_age = 25,
    mort_assump = tables["2001 CSO Super Preferred Select and Ultimate - Male Nonsmoker, ANB"].ultimate,
    projection_years = 75,
    annual_prem = prem,
)

# ╔═╡ 9ee35710-5349-11eb-0d45-23bc292d8a3d
md"""
## Runing the system

This results in the following plot. The tracked output variables u1 and u2 represent the two vars that we tracked above: account value and cumulative premium.
"""

# ╔═╡ b65ef28c-5349-11eb-1baa-6575ad7fb946
begin
	p = params(
	        8000.0, # 8,000 annual premium
	        0.08    # 8% interest
	        ) 
	
	# calculate the number of days to project
	projection_end_date = p.issue_date + Year(p.projection_years) 
	days_to_project = Dates.value(projection_end_date - p.issue_date)
	        
	# the [0.0,..] are the initial conditions for the tracked variables
	 prob = DiscreteProblem(policy_projection,[0.0,0.0,0],(0,days_to_project),p)
	 proj = solve(prob,FunctionMap())
	
	 plot(proj)
end

# ╔═╡ c4637664-5349-11eb-0e81-59e39974f02e
md"""
## Moving up the ladder of abstraction

An excellent way to understand the behavior of a model is to [move up the ladder of abstraction](http://worrydream.com/LadderOfAbstraction/). Below, we will see what happens to the projection at varying levels of credit rates and annual premiums.
"""

# ╔═╡ 02cc352a-5409-11eb-0fda-336d5fa42fa9
begin
	prem_range = 1000.0:100.0:9000.0
	int_range = 0.02:0.0025:0.08
	
	function ending_av(ann_prem,int,days_to_project)
	    p = params(ann_prem,int)
	    prob = DiscreteProblem(policy_projection,[0.0,0.0,0],(0,days_to_project),p)
	    proj = solve(prob,FunctionMap())
	    end_av = proj[end][1] 
	    if end_av == 0.0
	        lapse_time = findfirst(isequal(0.0),proj[1,2:end])
	    else
	        lapse_time = length(proj)
	    end
	    duration = proj[3,lapse_time]
	    end_age = p.issue_age + duration - 1.0
	    
	    return end_av,end_age
	    
	end
	
	end_age = zeros(length(prem_range),length(int_range))
	end_av = zeros(length(prem_range),length(int_range))
	
	# loop through each projection we did and fill our ranges with the ending AV and ending age
	for (i,vp) in enumerate(prem_range)
	    for (j,vi) in enumerate(int_range)
	        (end_av[i,j],end_age[i,j]) = ending_av(vp,vi,days_to_project)
	    end
	end
end

# ╔═╡ 280d25a6-5409-11eb-17d9-674f218f4351
begin
	using ColorSchemes # for Turbo colors, which emphasize readability
	
	viz = plot(layout=2) # side by side plot
	
	# 
	contour!(viz[1],int_range,
	    prem_range,
	    end_av ./ 1e6, # scale to millions for readability
	
	    contour_labels=true,
	    c=cgrad(ColorSchemes.turbo.colors),
	    fill=true,
	    title="AV at age 100 (\$M)",
	    ylabel="Annual Premium (\$)",
	    
	
	)
	
	contour!(viz[2],int_range,
	    prem_range,
	    end_age, 
	
	    contour_labels=true,
	    c=cgrad(ColorSchemes.turbo.colors),
	    fill=true,
	    yaxis=false,
	    title="Age at Lapse",
	)
	
	annotate!(viz[2],0.055,7000,Plots.text("Doesn't lapse \nbefore age 100", 8, :white, :center))
	
end

# ╔═╡ 21e53f60-5409-11eb-291d-d903da8e16b4
md"
Now let's plot the result. Not surprising, interest has a huge effect on the policy projection. Premium is also a major influence.

One thing that's remarkable is how going from 2000 premium to just ~2200 of premium results in about a $5m difference at 8% interest. The power of compound interest!
"

# ╔═╡ 684f7efc-5409-11eb-0757-19b40c5d418e
md"
## Conclusion

This shows how universal life mechanics are a dynamic system. the growth/decay is governed by two competing feedback loops:

- Growth: the force of interest lets the balance grow exponentially over long periods of time

- Decay: low balances increase the net amount at risk and the resulting COI charges.

"

# ╔═╡ 7e80faf0-5409-11eb-33f6-4f6be6fea835
md" 
## Endnotes

This is not meant to represent any particular insurance product, nor fully replicate typical account mechanics.
"

# ╔═╡ Cell order:
# ╟─cd5e7080-5348-11eb-2c22-455a3556cab0
# ╟─de0ace1a-5348-11eb-35c9-5f0ff4009d97
# ╠═ceff6126-51fc-11eb-3cf5-dd30d637e267
# ╟─ef26ffb6-5348-11eb-04a8-c5cbfdcab72a
# ╠═45dab59c-528d-11eb-357d-af3664466910
# ╟─ffe9b6e0-5348-11eb-2d38-a5613eb24383
# ╠═da199644-51fc-11eb-0aab-dd68b1fcddc6
# ╟─8a227236-5349-11eb-353d-1d3f94a968d0
# ╠═956811e4-5349-11eb-2b34-b5441def32a1
# ╟─9ee35710-5349-11eb-0d45-23bc292d8a3d
# ╠═b65ef28c-5349-11eb-1baa-6575ad7fb946
# ╟─c4637664-5349-11eb-0e81-59e39974f02e
# ╠═02cc352a-5409-11eb-0fda-336d5fa42fa9
# ╟─21e53f60-5409-11eb-291d-d903da8e16b4
# ╠═280d25a6-5409-11eb-17d9-674f218f4351
# ╟─684f7efc-5409-11eb-0757-19b40c5d418e
# ╟─7e80faf0-5409-11eb-33f6-4f6be6fea835
