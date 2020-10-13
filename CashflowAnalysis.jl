### A Pluto.jl notebook ###
# v0.12.3

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

# ╔═╡ 228bfdfe-0d40-11eb-1dbb-4f01ce119bb1
# the packages used in this notebook:
begin
	using Yields
	using ActuaryUtilities
	using Plots
	using PlutoUI
end

# ╔═╡ 641950d0-0d44-11eb-260c-ed92def0b60a
md"# Cashflow Analysis with ActuaryUtilities"

# ╔═╡ 8a5d9f90-0d48-11eb-1be6-8d6836ff1dbe
md" 
This notebook has two examples of cashflow analysis:

1. Bond pricing, duration, and convexity
2. Investment anaylsis that contrasts two projects' IRRs and breakeven time points
"

# ╔═╡ cc0232a0-0d46-11eb-06a6-8d7fa5c047ef
md"## Example 1: Bond metrics"

# ╔═╡ 8deba520-0d44-11eb-3dab-ab18e69d2dde
md"**Bond Maturity Time:** $(@bind maturity Slider(1:30,
show_value=true,
default=20
))"

# ╔═╡ 68c87dd0-0d40-11eb-16bf-8ff874bc3ea3
md"**Bond Yield To Maturity:** $(@bind yield_to_maturity Slider(0.01:0.005:0.25,
show_value=true,
default=0.12
))"

# ╔═╡ 8a005e00-0d40-11eb-09b4-8b555c921337
par = 100

# ╔═╡ 32705820-0d45-11eb-2582-e75cd402b760
md"First, let's create some cashflows to analyze by constructing a semi-annual coupon bond: with $par par"

# ╔═╡ 68b096c0-0d45-11eb-2a97-293edb087ded
times = [t for t in 0.5:0.5:maturity]

# ╔═╡ 4924d230-0d40-11eb-1485-4f320034b132
bond_cfs = map(times) do t
	if t == maturity
		par * (1 + yield_to_maturity / 2)
	else
		par * yield_to_maturity / 2 
	end
end


# ╔═╡ 4539f4b0-0d46-11eb-1976-e7a12682c958
md"There are a number of functions for common metrics:"

# ╔═╡ 42d85ace-0d42-11eb-1814-97ae8f46a2f8
md"**Discount rate:** $(@bind disc_rate Slider(0.01:0.005:0.15,show_value=true,default=0.05))"

# ╔═╡ 75bd8030-0d45-11eb-1546-3b5e18fb4144
(
	PV        = present_value(       disc_rate, bond_cfs, times),
	Duration  = duration(            disc_rate, bond_cfs, times),
	Macaulay  = duration(Macaulay(), disc_rate, bond_cfs, times),
	DV01      = duration(DV01(),     disc_rate, bond_cfs, times),
	Convexity = convexity(           disc_rate, bond_cfs, times),
)

# ╔═╡ 3d2c97a0-0d41-11eb-31b3-67ce8f27c211
begin
	scatter(
		times,
		bond_cfs,
		legend=:topleft,
		ylim=(0,maximum(bond_cfs)*1.05),
		xlim=(0,maturity * 1.05),
		xlabel=time,
		label="Bond Cashflows",
		title="Bond cashflows and durations: $(disc_rate*100)% discount",
		marker=(:grey, 5, 0.7),
		markerstroke=0,
	)
	vline!(
		[duration(disc_rate,bond_cfs,times)],
		label="Duration",
		line=(:blue,4,0.5)
	)
	vline!(
		[duration(Macaulay(),disc_rate,bond_cfs,times)],
		label="Macaulay Duration",
		line=(:purple,4,0.5)
	)
	vline!(
		[duration(DV01(),disc_rate,bond_cfs,times)],
		label="DV01",
		line=(:orange,4,0.5)
	)
end

# ╔═╡ fe2288c0-0d46-11eb-3195-3bb968cba644
md"## Example 2: Investment Cashflows"

# ╔═╡ 0e8d432e-0d47-11eb-3eb0-ffd26ebdbd0e
project_A = [-10,4,3,3,2,1,1]

# ╔═╡ 2bb71532-0d47-11eb-1bf8-59387e9c40a5
project_B = [-20,5,5,5,5,5]

# ╔═╡ 388a29ee-0d47-11eb-10dc-6fc8ee792c5e
let
	p1 = bar(project_A,title="Project A CFs",ylim=(-25,10),legend=false)
	p2 = bar(project_B,title="Project B CFs",ylim=(-25,10),legend=false)
	plot(p1,p2)
end
	

# ╔═╡ 830f0c60-0d48-11eb-3ba3-d970a349fa6a


# ╔═╡ e69b7940-0d47-11eb-13a4-7f437899aafa
(
	IRR_A = irr(project_A),
	IRR_B = irr(project_B),
	)

# ╔═╡ 70aa2fa0-0d48-11eb-00b9-114c73cc50ee
md"The time until the project breaks even with a borrowing cost of 5%:"

# ╔═╡ 0badd480-0d48-11eb-3e85-cfecde9d1ad5
(
	IRR_A = breakeven(     0.05, project_A),
	PV_A  = present_value( 0.05, project_A),
	IRR_B = breakeven(     0.05, project_B),
	PV_B  = present_value( 0.05, project_B),
)

# ╔═╡ c98e6190-0d48-11eb-17fb-a9413b985194
md"
### Term structure of rates with *Yields.jl*

The yield used doesn't have to be a flat rate. You can use a term structure of rates. Using the project cashflows from above, here's the present value and duration: 
"

# ╔═╡ 3ba513a0-0d49-11eb-39e9-a7728113dfec
curve = let 	
	spot_rates = [0.06, 0.08,0.0975,0.1085,0.1145,0.1168,0.1178,0.1187,0.1187]
	maturities = 1:9
	Yields.Zero(spot_rates,maturities)
end

# ╔═╡ e0717370-0d48-11eb-3629-d32dbb85b749
present_value(curve,project_A)

# ╔═╡ c6333330-0d49-11eb-2b1c-51c85729ba28
md"The duration of the inflows after the initial investment:"

# ╔═╡ e0495c90-0d49-11eb-2fc7-63826c1830c7
duration(curve, project_A[2:end], [1,2,3,4,5,6]) # the last vector is the timepoints

# ╔═╡ 23dfe9b0-0d4a-11eb-2030-5ba3bbf9519e
md"## Extras"

# ╔═╡ Cell order:
# ╟─641950d0-0d44-11eb-260c-ed92def0b60a
# ╟─8a5d9f90-0d48-11eb-1be6-8d6836ff1dbe
# ╟─cc0232a0-0d46-11eb-06a6-8d7fa5c047ef
# ╟─32705820-0d45-11eb-2582-e75cd402b760
# ╟─8deba520-0d44-11eb-3dab-ab18e69d2dde
# ╟─68c87dd0-0d40-11eb-16bf-8ff874bc3ea3
# ╟─8a005e00-0d40-11eb-09b4-8b555c921337
# ╟─68b096c0-0d45-11eb-2a97-293edb087ded
# ╟─4924d230-0d40-11eb-1485-4f320034b132
# ╟─4539f4b0-0d46-11eb-1976-e7a12682c958
# ╟─42d85ace-0d42-11eb-1814-97ae8f46a2f8
# ╠═75bd8030-0d45-11eb-1546-3b5e18fb4144
# ╟─3d2c97a0-0d41-11eb-31b3-67ce8f27c211
# ╟─fe2288c0-0d46-11eb-3195-3bb968cba644
# ╟─388a29ee-0d47-11eb-10dc-6fc8ee792c5e
# ╟─0e8d432e-0d47-11eb-3eb0-ffd26ebdbd0e
# ╟─2bb71532-0d47-11eb-1bf8-59387e9c40a5
# ╠═830f0c60-0d48-11eb-3ba3-d970a349fa6a
# ╠═e69b7940-0d47-11eb-13a4-7f437899aafa
# ╟─70aa2fa0-0d48-11eb-00b9-114c73cc50ee
# ╠═0badd480-0d48-11eb-3e85-cfecde9d1ad5
# ╟─c98e6190-0d48-11eb-17fb-a9413b985194
# ╠═3ba513a0-0d49-11eb-39e9-a7728113dfec
# ╠═e0717370-0d48-11eb-3629-d32dbb85b749
# ╟─c6333330-0d49-11eb-2b1c-51c85729ba28
# ╠═e0495c90-0d49-11eb-2fc7-63826c1830c7
# ╟─23dfe9b0-0d4a-11eb-2030-5ba3bbf9519e
# ╠═228bfdfe-0d40-11eb-1dbb-4f01ce119bb1
