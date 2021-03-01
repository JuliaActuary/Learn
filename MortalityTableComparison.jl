### A Pluto.jl notebook ###
# v0.12.21

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

# ╔═╡ dbb88400-065d-11eb-3fe8-9b5b7f873d3e
begin
	using MortalityTables
	using PlutoUI
	using Plots
end

# ╔═╡ de790392-065d-11eb-047d-a10af7f2fdc7
md"
# Mortality Table Comparison Tool
"

# ╔═╡ 5322a010-065f-11eb-0864-3d69c92cff6c
md"**Issue Age:** $(@bind issue_age Slider(18:100,show_value=true,default=50))"

# ╔═╡ 968d79c0-0695-11eb-2586-0565817b37a8
md"The rest of the code:"

# ╔═╡ ad6c9830-068e-11eb-2934-6f460c421895
function rate_ratio(a, a_select,b, b_select, issue_age,duration)
		att_age = issue_age + duration - 1
		a = a_select ? a.select[issue_age][att_age] : a.ultimate[att_age]
		b = b_select ? b.select[issue_age][att_age] : b.ultimate[att_age]
		return b / a
end

# ╔═╡ df760e20-0692-11eb-16bb-e5b41f8a5255
available_names = [x.name for x in MortalityTables.table_source_map]

# ╔═╡ 26f84770-065e-11eb-03ca-435dfb6ed5da
md"
**Table A:** $(@bind name_a Select(
available_names,
default=\"2015 VBT Male Non-Smoker RR100 ALB\"
))

*or* Mort.SOA.org table ID (leave blank to use dropdown): $(@bind lookup_a TextField())

Use select rates (if available): $(@bind sel_a CheckBox(default=true))
"

# ╔═╡ b6fbd7f0-065f-11eb-1af7-5141be0a585f
if lookup_a == ""
	
	table_a = MortalityTables.table(name_a)
else
	table_a = MortalityTables.table(parse(Int,lookup_a))
end

# ╔═╡ 7ae73f7e-065e-11eb-1472-b7bc0e5cff29
md"
**Table B:** $(@bind name_b Select(
available_names,
default=\"2015 VBT Male Non-Smoker RR175 ALB\"
))

*or* Mort.SOA.org table ID (leave blank to use dropdown): $(@bind lookup_b TextField())

Use select rates (if available): $(@bind sel_b CheckBox(default=true))
"

# ╔═╡ bb15f410-065f-11eb-2342-9319b0ff6237
if lookup_b == ""
	table_b = MortalityTables.table(name_b)
else
	table_b = MortalityTables.table(parse(Int,lookup_b))
end

# ╔═╡ d60bc480-065e-11eb-2072-b3ac00e39598
let
	if sel_a 
		rates_a = table_a.select[issue_age][issue_age:end]
	else
		rates_a = table_a.ultimate[issue_age:end]
	end
	if sel_b
		rates_b = table_b.select[issue_age][issue_age:end]
	else
		rates_b = table_b.ultimate[issue_age:end]
	end
	# left plot
	p1 = plot(
		rates_a,
		label="$name_a",
		title="unscaled",
		xaxis="duration",
		legend=:topleft
	)
	plot!(p1, rates_b,label="$name_b")
	
	# right plot
	p2 = plot(
		rates_a,
		label="$name_a",
		yaxis=:log,
		title="log scaled",
		xaxis="duration",
		legend=false
	)
	plot!(p2, rates_b,label="$name_b")
	
	plot(p1,p2,size=(980,400))
	
end

# ╔═╡ 378a33f2-0695-11eb-3dee-af6f6298edad
# the matrix of ratios for the contour plots
begin 
	issue_ages = 25:80
	ω = min(omega(table_b.ultimate),omega(table_a.ultimate))
	durations = 1:(ω-80)
	# durations = 1:40
		
	ratio = [rate_ratio(table_a,sel_a,table_b,sel_b,ia,dur) for ia in issue_ages, dur in durations]
end;

# ╔═╡ e38d2460-068f-11eb-3d19-e1902fc7b28c
begin


	c1 = contour(durations,
	        issue_ages,
	        ratio,
			title="Ratio",
	        xlabel="duration",ylabel="select issue age",
			titlefontsize=8,
	        fill=true,
		size=(675,400),
		contour_labels=true
	        )
	hline!(c1,[issue_age],alpha=0.5,color=:grey,linewidth=3,legend=false)
	
	
	c2 = contour(durations,
	        issue_ages,
	        log.(ratio),
	        xlabel="duration",ylabel="issue age",
	        title="Ratio (LOG SCALED)",
			titlefontsize=8,
	        fill=true,
		size=(675,400),
		color=:turbo,
		clim=(-3,3),
		contour_labels=true,
		levels=50
	        )
	hline!(c2,[issue_age],alpha=0.5,color=:grey,linewidth=3,legend=false)
	
	 l = @layout [
    		title{0.05h} 
			grid(1,2)
            ]
	titleplot=plot(title="$name_b over \n $name_a\n(Grey bar is issue age selected above)", leg = false, ticks = nothing, border = :none,titlefontsize=11)
	
	plot(titleplot,c1,c2,size=(980,400),layout= l)
	
end

# ╔═╡ 03dabe48-7a4a-11eb-252f-5bd03b2e0201
# make the notebook just a little wider
html"""<style>
pluto-notebook {
    width: 1000px;
}
"""

# ╔═╡ Cell order:
# ╟─de790392-065d-11eb-047d-a10af7f2fdc7
# ╟─26f84770-065e-11eb-03ca-435dfb6ed5da
# ╟─7ae73f7e-065e-11eb-1472-b7bc0e5cff29
# ╟─5322a010-065f-11eb-0864-3d69c92cff6c
# ╟─d60bc480-065e-11eb-2072-b3ac00e39598
# ╠═e38d2460-068f-11eb-3d19-e1902fc7b28c
# ╟─968d79c0-0695-11eb-2586-0565817b37a8
# ╠═dbb88400-065d-11eb-3fe8-9b5b7f873d3e
# ╠═b6fbd7f0-065f-11eb-1af7-5141be0a585f
# ╠═bb15f410-065f-11eb-2342-9319b0ff6237
# ╠═ad6c9830-068e-11eb-2934-6f460c421895
# ╠═378a33f2-0695-11eb-3dee-af6f6298edad
# ╟─df760e20-0692-11eb-16bb-e5b41f8a5255
# ╟─03dabe48-7a4a-11eb-252f-5bd03b2e0201
