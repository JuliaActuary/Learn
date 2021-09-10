### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 9f0add20-11db-11ec-31c8-1933ca9b19c4
begin
	using MortalityTables
	using DataFrames
	using IterTools
	using BenchmarkTools
end

# ╔═╡ 1ed5e587-d0eb-4dc2-bedc-00d13f258ecd
begin
	using PlutoUI
	TableOfContents()
end

# ╔═╡ d8fa5c6d-4fd3-40b6-abb3-6349b9fca7b7
md"# MortalityTables.jl Design notes"

# ╔═╡ 4980df5b-d2aa-4200-b517-bffcf4775971
md"## MortalityTables.jl types"

# ╔═╡ 5455ba9e-11ef-49e4-b877-d12dc45a22f8
md"There are two types of MortalityTable subtypes for SOA data: `SelectUltimateTable` and `UltimateTable`, so define a function for each:"

# ╔═╡ 1242d939-581b-4236-b00c-608efe9a4d08
vbt = MortalityTables.table("2001 VBT Residual Standard Select and Ultimate - Male Nonsmoker, ANB")

# ╔═╡ 2181f078-f538-48b4-a2a3-d7e6c9678ce7
cso = MortalityTables.table("1941 CSO Basic Table, ANB")

# ╔═╡ fcffeb28-ed5d-44f9-9260-f9b631d6988d
vbt isa MortalityTables.SelectUltimateTable

# ╔═╡ 9a9aa632-f773-49ef-bd85-a64148d1d0a4
cso isa MortalityTables.UltimateTable

# ╔═╡ 95b3a432-ad19-47c8-8cf3-831fab934425
md"""
## Candidate function for getting the "long" version of dataframes.
"""

# ╔═╡ 215585ab-d2c3-47e7-b54f-e2719bdeb230
"""
	long(m::MortalityTable)

Return an array of tuples containing `issue_age`,`attained_age`,`duration`,`select` rate, and `ultimate` rate.

"""
function long(m::MortalityTables.SelectUltimateTable)
	earliest_age = min(firstindex(m.select),firstindex(m.ultimate))
	last_age = max(lastindex(m.select),lastindex(m.ultimate))
	
	table = map(earliest_age:last_age) do issue_age
		map(issue_age:last_age) do attained_age
			# use `get` to provide default missing value
			ultimate = get(m.ultimate,attained_age,missing)
			if issue_age <= lastindex(m.select)
				select = get(m.select[issue_age],attained_age,missing)
			else
				select = missing
			end
			duration = attained_age - issue_age + 1
			(;issue_age,attained_age, duration, select,ultimate)
		end
	end
	
	vcat(table...)
		
	
end

# ╔═╡ 99a1a535-87de-4fea-bb83-2bcc0267d70f
"""
	long(m::MortalityTable)

Return an array of tuples containing `issue_age`,`attained_age`,`duration`,`select` rate, and `ultimate` rate.

"""
function long(m::MortalityTables.UltimateTable)
	earliest_age = firstindex(m.ultimate)
	last_age = lastindex(m.ultimate)
	
	table = map(earliest_age:last_age) do issue_age
		map(issue_age:last_age) do attained_age
			# use `get` to provide default missing value
			ultimate = get(m.ultimate,attained_age,missing)
			select = missing
			duration = attained_age - issue_age + 1
			(;issue_age,attained_age, duration, select,ultimate)
		end
	end
	
	vcat(table...)
		
	
end

# ╔═╡ c155fb29-275d-4b56-b125-ca0084c4182e
md"Now this can be called on tabular mortality tables and it will return a vector of named tuples, a very efficient and transferrable structure."

# ╔═╡ 73173e80-d76d-4819-a3e8-dc7138d532ac
long(vbt)

# ╔═╡ 6ead1870-0e5c-44e6-92b7-3e6f90c9e387
md"
**Why use a vector of tuples and not straight to DataFrame?**

In Julia, composability and package interoperability is really easy because packages don't need to know about, or can extend when necessary, other packages' types. See https://www.youtube.com/watch?v=kc9HwsxE1OY for more.

DataFrames can then directly use this result, but an array of tuples is also used by anything that uses the `Tables.jl` interface (e.g. all of these: https://github.com/JuliaData/Tables.jl/blob/main/INTEGRATIONS.md)"




# ╔═╡ 38a9ea42-1c9b-48c0-8d08-3acc00319223
DataFrame(long(vbt))

# ╔═╡ 8f999e94-bfc6-4b08-be35-1da44953dc55
md"## More on the design of MortalityTables.jl"

# ╔═╡ f70c9f2c-d24c-441f-bf24-863c5ba596dd
md"
The design went through many iterations, and it may not be the final design, but here are some of the benefits of the current design:" 

# ╔═╡ 9b43e322-a873-421b-8260-d4368d6cbaa3
md"### Size in memory

Here, the long format is 5x the size of the regular type because duplicate values not needed:"

# ╔═╡ bd1a6dcf-0d91-4774-a267-e19abb8dc0e4
Base.summarysize(long(vbt))

# ╔═╡ 3f31a05a-0a5b-45f6-a718-f43744758472
Base.summarysize(vbt)

# ╔═╡ 09c00dd9-7a2a-478c-bb4f-9a1289f4796e
md"### Encourage data-driven design

Probably best explained with an example. In the following example, we calculate the ultimate survivorship for every age in the `cso` table from above. The table itself gives us the right range of ages to do this with. No need to assume a 100 or 121 omega age and handle edge cases when working with tables that don't line up to the usual expectations."

# ╔═╡ 31b42e8e-9361-45d1-b84a-2b8b54153ec4
map(eachindex(cso.ultimate)) do issue_age
	survival(cso.ultimate,issue_age,omega(cso.ultimate))
end

# ╔═╡ d2c825f3-7203-4905-828a-9be0fd42fe41
md"Of course, here we are limited by the quality of the input tables. For example, in the `vbt` table from the SOA loaded above, select rates are missing from under-18s, even though select rates are defined for a life issued under-18."

# ╔═╡ afa8ae7e-5beb-45fd-87cd-33d1f263b692
md"### Speed of calculation

In modeling contexts, efficiency is often a key part of the model. This is probably close to the fastest computation of survival probabilities possible to acheive:"

# ╔═╡ 03fb84cf-8fe9-4622-b7a3-6b8ff49907c4
@benchmark survival($cso.ultimate,55,100)

# ╔═╡ 01a5d74d-c71b-49f2-833f-1a937cbc89e8
md"### Parametric models

With MortalityTables.jl, virtually transparent to the user of the pacakge, you can drop in parametric models in place of tabular-SOA-like tables. Here is a Makeham mortality model and the same syntax is used as with the SOA tables:

"

# ╔═╡ f84c087d-8963-4835-81d9-8e72ab297b13
survival(MortalityTables.Makeham(),25,50) # 25 to 50 year old survival

# ╔═╡ b5dc0d67-f80b-40ae-a65c-7d8f085e84ae
md"### Table metadata

When you display a table, you get to see related metadata, which can be lost if simply parsing into a matrix or dataframe:"

# ╔═╡ 05a54094-1587-43eb-a3f2-d8945803f482
cso

# ╔═╡ 9b3425d6-0c3a-4395-a2c2-af73928aed01
md"### Parital Year assumptions

Built in are partial year assumptions, making it easy to use more realistic assumptions like Uniform death distribution:"

# ╔═╡ 04162e25-9a74-4bc1-9ceb-66655111897e
survival(cso.ultimate,55,55.5,MortalityTables.Uniform()) 

# ╔═╡ a48efa0b-3c2b-44a9-b808-cf0975fce72d
survival(cso.ultimate,55,55.5,MortalityTables.Constant()) 

# ╔═╡ 841a1fb5-fc52-494c-a2eb-15930b41ced8
survival(cso.ultimate,55,55.5,MortalityTables.Balducci()) 

# ╔═╡ fbbc5e91-3e43-43c8-b23e-0ccd00ba0c71
md"## Where MortalityTables.jl falls short"

# ╔═╡ c74af2e0-99eb-4526-a68a-8fdab5717f16
md"
In no particular order:
- it mainly relies on data from mort.SOA.org. Some of the tables have issues like inconsistent naming, missing fields
- would be nice to offer 'sets' of table to users. Early tests failed to do this in an automated way because of issues with the naming consistency of tables mentioned in the first bullet
- (currently) no automatic conversion to a dataframe-compatible, though this is discussed above
- MortalityTables.jl is a misnomer, as the `ORT` of MORT.SOA.org is 'other rate tables' which are offered in MortalityTables.jl
- no built-in support for mortality improvement
- has issues with autodifferentiation because of the discrete and non-continuous nature of the annual rate tables
"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
IterTools = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
MortalityTables = "4780e19d-04b9-53dc-86c2-9e9aa59b5a12"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
BenchmarkTools = "~1.1.4"
DataFrames = "~1.2.2"
IterTools = "~1.3.0"
MortalityTables = "~2.1.4"
PlutoUI = "~0.7.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Statistics", "UUIDs"]
git-tree-sha1 = "42ac5e523869a84eac9669eaceed9e4aa0e1587b"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.1.4"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "6071cb87be6a444ac75fdbf51b8e7273808ce62f"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.35.0"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "bec2532f8adb82005476c141ec23e921fc20971b"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.8.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d785f42445b63fc86caa08bb9a9351008be9b765"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "0fa3b52a04a4e210aeb1626def9c90df3ae65268"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.1.0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "2ca267b08821e86c5ef4376cffed98a46c2cb205"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MortalityTables]]
deps = ["OffsetArrays", "Parsers", "Pkg", "QuadGK", "Requires", "UnPack", "XMLDict"]
git-tree-sha1 = "cae9281196e40e24cb5885b8463a6f955ae0f3eb"
uuid = "4780e19d-04b9-53dc-86c2-9e9aa59b5a12"
version = "2.1.4"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "c870a0d713b51e4b49be6432eff0e26a4325afee"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.6"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "438d35d2d95ae2c5e8780b330592b6de8494e779"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.3"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a193d6ad9c45ada72c14b731a318bedd3c2f00cf"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.3.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "0d1245a357cc61c8cd61934c07447aa569ff22e6"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.1.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "12fbe86da16df6679be7521dfb39fbc861e1dc7b"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.1"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "368d04a820fe069f9080ff1b432147a6203c3c89"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.5.1"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XMLDict]]
deps = ["EzXML", "IterTools", "OrderedCollections"]
git-tree-sha1 = "d9a3faf078210e477b291c79117676fca54da9dd"
uuid = "228000da-037f-5747-90a9-8195ccbf91a5"
version = "0.4.1"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╠═d8fa5c6d-4fd3-40b6-abb3-6349b9fca7b7
# ╠═9f0add20-11db-11ec-31c8-1933ca9b19c4
# ╟─4980df5b-d2aa-4200-b517-bffcf4775971
# ╟─5455ba9e-11ef-49e4-b877-d12dc45a22f8
# ╠═1242d939-581b-4236-b00c-608efe9a4d08
# ╠═2181f078-f538-48b4-a2a3-d7e6c9678ce7
# ╠═fcffeb28-ed5d-44f9-9260-f9b631d6988d
# ╠═9a9aa632-f773-49ef-bd85-a64148d1d0a4
# ╟─95b3a432-ad19-47c8-8cf3-831fab934425
# ╠═215585ab-d2c3-47e7-b54f-e2719bdeb230
# ╠═99a1a535-87de-4fea-bb83-2bcc0267d70f
# ╟─c155fb29-275d-4b56-b125-ca0084c4182e
# ╠═73173e80-d76d-4819-a3e8-dc7138d532ac
# ╟─6ead1870-0e5c-44e6-92b7-3e6f90c9e387
# ╠═38a9ea42-1c9b-48c0-8d08-3acc00319223
# ╟─8f999e94-bfc6-4b08-be35-1da44953dc55
# ╟─f70c9f2c-d24c-441f-bf24-863c5ba596dd
# ╟─9b43e322-a873-421b-8260-d4368d6cbaa3
# ╠═bd1a6dcf-0d91-4774-a267-e19abb8dc0e4
# ╠═3f31a05a-0a5b-45f6-a718-f43744758472
# ╟─09c00dd9-7a2a-478c-bb4f-9a1289f4796e
# ╠═31b42e8e-9361-45d1-b84a-2b8b54153ec4
# ╟─d2c825f3-7203-4905-828a-9be0fd42fe41
# ╟─afa8ae7e-5beb-45fd-87cd-33d1f263b692
# ╠═03fb84cf-8fe9-4622-b7a3-6b8ff49907c4
# ╟─01a5d74d-c71b-49f2-833f-1a937cbc89e8
# ╠═f84c087d-8963-4835-81d9-8e72ab297b13
# ╟─b5dc0d67-f80b-40ae-a65c-7d8f085e84ae
# ╠═05a54094-1587-43eb-a3f2-d8945803f482
# ╟─9b3425d6-0c3a-4395-a2c2-af73928aed01
# ╠═04162e25-9a74-4bc1-9ceb-66655111897e
# ╠═a48efa0b-3c2b-44a9-b808-cf0975fce72d
# ╠═841a1fb5-fc52-494c-a2eb-15930b41ced8
# ╠═fbbc5e91-3e43-43c8-b23e-0ccd00ba0c71
# ╟─c74af2e0-99eb-4526-a68a-8fdab5717f16
# ╟─1ed5e587-d0eb-4dc2-bedc-00d13f258ecd
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
