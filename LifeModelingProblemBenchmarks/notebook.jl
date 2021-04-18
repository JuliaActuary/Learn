### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 1abee59c-9f2c-11eb-1f94-1b053014099a
begin
	using Plots
	using Dates
	using DataFrames
	using CSV
	using Measures
	using PrettyTables
end



# ╔═╡ 32a297bc-ea16-4aa5-a047-55673778bbc2
benchmarks = DataFrame(CSV.File("benchmarks.csv"))

# ╔═╡ 7f88c1c5-804c-4d2f-b0b7-e1d0b7035d98
begin
	header = (["Language","Algorithm","Function Name","Median","Mean"])
	pretty_table(benchmarks;header=header,formatters = ft_printf("%5.1f"))
end

# ╔═╡ a0e79f1a-21b6-46b3-9cb1-0b78cf02984b
begin
	data = [1 2 3; 4 5 6];
	pretty_table(data;
	                    header = (["Column 1", "Column 2", "Column 3"],
	                              ["A", "B", "C"]))
end

# ╔═╡ 022fbe85-341a-4e5e-976b-c9eb406ca404
begin
	# Reference Grace Hopper explains the nanosecond
	p = plot(palette = :seaborn_colorblind,rotation=15)
	# label equivalents to distance to make log scale more relatable
	scatter!(fill("\n equivalents (ns → ft)",7),[1,1e1,1e2,1e3,.8e4,0.72e5,3.3e6],series_annotations=Plots.text.(["1 foot","basketball hoop","blue whale","Eiffle Tower","avg ocean depth","marathon distance","Space Station altitude"], :left, 8,:grey),marker=0,label="",left_margin=20mm)
	
	# plot mean, or median if not available
	for g in groupby(benchmarks,:algorithm)
		scatter!(g.lang,
			ifelse.(ismissing.(g.mean),g.median,g.mean),
			label="$(g.algorithm[1])",
			yaxis=:log,
			ylabel="Nanoseconds (log scale)",
		marker = (:circle, 5, 0.5, stroke(0)))
	end
	p
end

# ╔═╡ 9f738c56-bfc9-4672-8825-e5dde6a4b55e
1.486035500000071 / 1000000

# ╔═╡ ba082c8a-c519-405d-83cb-e0e76ddf1ca5
md"
## Colophone

### Hardware

Macbook Air (M1, 2020)

### Software 

All languages/libraries are Mac M1 native unless otherwise noted

Julia
```
Julia Version 1.7.0-DEV.938
Commit 2b4c088ee7* (2021-04-16 20:37 UTC)
Platform Info:
  OS: macOS (arm64-apple-darwin20.3.0)
  CPU: Apple M1
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, cyclone)
```
Rust 
```
1.53.0-nightly (b0c818c5e 2021-04-16)
```

Python:
```
Python 3.9.4 (default, Apr  4 2021, 17:42:23) 
[Clang 12.0.0 (clang-1200.0.32.29)] on darwin
```
"

# ╔═╡ Cell order:
# ╠═1abee59c-9f2c-11eb-1f94-1b053014099a
# ╠═32a297bc-ea16-4aa5-a047-55673778bbc2
# ╠═7f88c1c5-804c-4d2f-b0b7-e1d0b7035d98
# ╠═a0e79f1a-21b6-46b3-9cb1-0b78cf02984b
# ╠═022fbe85-341a-4e5e-976b-c9eb406ca404
# ╠═9f738c56-bfc9-4672-8825-e5dde6a4b55e
# ╠═ba082c8a-c519-405d-83cb-e0e76ddf1ca5
