### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 4daea69e-a4b5-48f6-b932-b90a38544105
using BenchmarkTools

# ╔═╡ 51105b4d-cd07-4244-9715-7160e629f998
using ProgressLogging

# ╔═╡ 009b8e21-a7a2-41d0-af6c-5be89ea819f7
# ╠═╡ show_logs = false
begin
    using CondaPkg
    CondaPkg.add("seaborn")
    using PythonCall
    using DataFrames
end

# ╔═╡ 675e95d9-2d12-4324-9418-a12de6e8c082
begin
	using Plots, StatsPlots

	lang = ["Julia", "Python", "Rust", "C++", "C#", "Julia", "Python", "Rust", "C++", "C#", "Julia", "Python", "Rust", "C++", "C#"]
	similarity_time_linux = [1.81, 9.29, 3.09, 21.31, 1.62, 1.51, 8.1, 2.66, 14.39, 1.49, 2.96, 17.67, 12.39, 32.68, 1.93]
	similarity_time_windows = [0.49, 5.13, 1.84, 9.17, 0.25, 0.42, 4.81, 1.55, 8.92, 0.22, 0.88, 5.8, 3.53, 9.42, 0.28]
	
	plot(boxplot(lang, similarity_time_linux, title = "Similarity (Linux)", label = "runtime in ms", colour = :blue), boxplot(lang, similarity_time_windows, title = "Similarity (Windows)", label = "runtime in ms", colour = :lightblue), layout=[1 1])
	
end

# ╔═╡ 1c0ccd93-59b8-46e2-bf3a-45ae79b35af0
using MortalityTables, FinanceModels, LifeContingencies, ActuaryUtilities

# ╔═╡ 8320edcc-ef78-11ec-0445-b100a477c027
begin
    using PlutoUI
end

# ╔═╡ 458f2690-e3fb-40a8-a657-e3a0666af69c
html"<button onclick='present()'>Press this to switch to presentation mode</button>"

# ╔═╡ 3c2da572-90d0-4206-9586-18f2cea6b6ca
md"# Introduction to Julia
Download this notebook: [https://github.com/JuliaActuary/Learn/blob/master/soa_life_meeting_2023/slides.jl](https://github.com/JuliaActuary/Learn/blob/master/soa_life_meeting_2023/slides.jl)

## SOA Life Meeting 2023
### Presented by Yun-Tien Lee and Alec Loudenback

*The views and opinions expressed in this presentation are those of the presenter and do not necessarily represent the official policy or position of Fortitude Re or any of its affiliates.*"

# ╔═╡ 6c77e9ff-caec-4713-a71a-744df5bf7660
md"## SOA Antitrust Compliance Guidelines
Active participation in the Society of Actuaries is an important aspect of membership.  While the positive contributions of professional societies and associations are well-recognized and encouraged, association activities are vulnerable to close antitrust scrutiny.  By their very nature, associations bring together industry competitors and other market participants.  
The United States antitrust laws aim to protect consumers by preserving the free economy and prohibiting anti-competitive business practices; they promote competition.  There are both state and federal antitrust laws, although state antitrust laws closely follow federal law.  The Sherman Act, is the primary U.S. antitrust law pertaining to association activities.   The Sherman Act prohibits every contract, combination or conspiracy that places an unreasonable restraint on trade.  There are, however, some activities that are illegal under all circumstances, such as price fixing, market allocation and collusive bidding.  

There is no safe harbor under the antitrust law for professional association activities.  Therefore, association meeting participants should refrain from discussing any activity that could potentially be construed as having an anti-competitive effect. Discussions relating to product or service pricing, market allocations, membership restrictions, product standardization or other conditions on trade could arguably be perceived as a restraint on trade and may expose the SOA and its members to antitrust enforcement procedures.

While participating in all SOA in person meetings, webinars, teleconferences or side discussions, you should avoid discussing competitively sensitive information with competitors and follow these guidelines:

- Do not discuss prices for services or products or anything else that might affect prices
- Do not discuss what you or other entities plan to do in a particular geographic or product markets or with particular customers.
- Do not speak on behalf of the SOA or any of its committees unless specifically authorized to do so.
- Do leave a meeting where any anticompetitive pricing or market allocation discussion occurs.
- Do alert SOA staff and/or legal counsel to any concerning discussions
- Do consult with legal counsel before raising any matter or making a statement that may involve competitively sensitive information.

Adherence to these guidelines involves not only avoidance of antitrust violations, but avoidance of behavior which might be so construed.  These guidelines only provide an overview of prohibited activities.  SOA legal counsel reviews meeting agenda and materials as deemed appropriate and any discussion that departs from the formal agenda should be scrutinized carefully.  Antitrust compliance is everyone’s responsibility; however, please seek legal counsel if you have any questions or concerns.
"


# ╔═╡ 434f336d-63ff-40f6-b64f-e538b6f08fd9
md" ## Presentation Disclaimer
Presentations are intended for educational purposes only and do not replace independent professional judgment.  Statements of fact and opinions expressed are those of the participants individually and, unless expressly stated to the contrary, are not the opinion or position of the Society of Actuaries, its cosponsors or its committees.  The Society of Actuaries does not endorse or approve, and assumes no responsibility for, the content, accuracy or completeness of the information presented.  Attendees should note that the sessions are audio-recorded and may be published in various media, including print, audio and video formats without further notice.
"

# ╔═╡ 142954b2-9615-4527-9a1a-d687583ff38e
md"""
# Outline for today

1. Why Julia? An Introduction to the Language *(20 minutes)*
2. Three actuarial case studies *(20 minutes)*
3. An Actuarial-oriented Ecosystem overview *(15 minutes)*

"""

# ╔═╡ 47c7ecd8-1610-4ce8-bff1-814a48336368
md"# Why Julia

- Highly expressive and pleasant syntax
- High performance in a high level language
- Modern tooling and large ecosystem

"

# ╔═╡ 7b86f12b-de88-40e0-bee3-1d9ba188fd40
md"""
## Who uses Julia today?

$(Resource("https://raw.githubusercontent.com/JuliaActuary/Learn/master/intro-video/assets/Julia-Users.png"))
"""

# ╔═╡ fb686b8b-bbb8-43b5-8241-493463275346
md"""
## Expressiveness and pleasant syntax

### 90 second syntax introduction
What does Julia look like?
"""

# ╔═╡ 3fcc0272-814a-423b-aad0-63030a32b8f5
a = [1, 2, 3]

# ╔═╡ 3d8916c4-2315-4420-a19b-61ac58ea9d60
f(x) = x^2

# ╔═╡ 0c66ed9c-4fd2-4636-ad56-5bcc0b606f07
f(2)

# ╔═╡ bba42bba-d76e-48f1-a376-0c03a817f880
x = "string are written like this"

# ╔═╡ 494265ee-e0c5-4644-9cd8-63e0f40de78b
x[1:5]

# ╔═╡ bb75f7b0-5cb2-425d-8c3c-13f49862d44a
let
    1 + 1                        # Addition
    arr = [1, 2, 3] 			 # array of data
    [x^2 for x in arr] 			 # array comprehension
    x = 1 						 # variable assignment
    x, y = 1, 2 				 # multiple variable assignment
    arr[1:2] 					 # slicing, note 1-indexed
    Dict("a" => 123, "b" => 456) # dictionaries
    f(x) = x^2 					 # functions
    "this is a string" 			 # strings
end;

# ╔═╡ b72b91c5-c6df-4eb5-a5e0-63ef8f20d34c
md"""
### Expresiveness

Accomplish similar tasks with less code, written in an easy-to-understand way:

```python
# Python
x = np.arange(15, dtype=np.int64).reshape(3, 5)
```

```julia
# Julia
x = reshape(0:14, 3,5)
```
"""

# ╔═╡ f23b4b4e-baf5-4a7d-9a33-14050f1993e6
reshape(0:14, 3, 5) # can infer type from 0 or 0.

# ╔═╡ 5c811d55-53df-4a9c-b75f-4656168b70e2
md"""
### Programming paradigm

Julia is multi-paradigm, which means you create code in your own style, or the style that best suits the problem at hand.

- Functional
- Object Oriented
  - Multiple dispatch is an extension of single dispatch commonly associated with OOP
- Data Oriented
- Domain-Specific-Language
- Concurency/Parallel
- Literate
- ...

Sometimes this can be a pitfall, as there's not one cannonical way to accomplish some things.

"""

# ╔═╡ 7bb2e1bc-ed41-406f-993d-1cc3a75af478
md"""
#### Extensability & Ecosystem



**`object1.method(object2)`** is semantically the same as **`method(object1,object2)`**


##### Python example:

Object Method:
```

library                       object                            method
   |                              |                               |
|-----|--------------------------------------------------------|-----|

 numpy.array([-250000, 100000, 150000, 200000, 250000, 300000]).sum()

```

Library Function:
```
library       function
   |             |
|--------------|---|

numpy_financial.irr([-250000, 100000, 150000, 200000, 250000, 300000])

                    |------------------------------------------------|
                                            |
                                          object
```

Comments:
 - despite both being operations `array -> scalar`, `irr` has to be implemented as a library function instead as an array method becuase there's no mechanism in Python to cleanly implement a new method on another package's type

##### Julia example:

Julia uses the `function(object1,object2)` syntax:
```

function                                             
  |                                                       
|---|

 sum([-250000, 100000, 150000, 200000, 250000, 300000])

     |-----------------------------------------------|
                             |
                          object
```

Library Function:
```
library      function
    |             |
|--------------|----|

ActuaryUtilities.irr([-250000, 100000, 150000, 200000, 250000, 300000])
          
                     |------------------------------------------------|
                                            |
                                          object
```

Ability to extend functionality is not limited by the class-based object-oriented inhertiance. Code re-use is achieved through compositon rather than inheritance.



"""

# ╔═╡ 57a4d392-6579-41dd-a79b-87b3c8dfba72
md"""
#### Multiple Dispatch

Implemting a custom `sum` in a single dispatch language:

```julia

function mysum(x, y)                                # same as x.sum(y) in OO-syntax
    if isa(x, Float64) && isa(y, Float64)
        return add64_using_the_fpu(x, y)            # FPU = floating-point unit
    elseif isa(x, Float32) && isa(y, Float32)
        return add32_using_the_fpu(x, y)
    elseif isa(x, Int64) && isa(y, Int64)
        return add64_using_the_integer_unit(x, y)   # integer unit is in the "core CPU"
    elseif isa(x, Int32) && isa(y, Int32)
        return add64_using_the_integer_unit(x, y)
    else
        # convert everything to Float64
        x64, y64 = Float64(x), Float64(y)
        return add64_using_the_fpu(x64, y64)
    end
end
```
*Example taken from [Advanced Scientific Computing course](https://github.com/timholy/AdvancedScientificComputing)).*

In Julia, the above is accomplished by the compiler at compile-time while in the above example, the logic has to be computed at run-time. Performance is easy to show in simple examples, but for the actuary the greatest benefit may be in design and ergonomics. 
"""

# ╔═╡ 44ec070b-4732-4b7b-9f75-51dd06032a4b
md"""
#### Multiple dispatch & Extensibility examples:

- You define a type of data that has a default plot when visualized - this doesn't require adding very niche methods to your data's class, nor do you have to modify plotting library.
- You want to fit a yield curve to observed asset quotes. The logic differs depending on the *combination* of model you want to fit (spline, parametric), asset quoted, and method (Bootstrap, least squares). In an object oriented world, where do you put the logic for fitting the yield curve: the assets, the model, or the fitting algorithm?
"""

# ╔═╡ b77156a3-1180-434e-90ec-841b8ef8d632
md"""
## High Performance in a high level language

Julia is compiled *just ahead of time* which is different than Python and R, which are interpreted. 

- *Compiled* means translated to efficient machine code in advance of actually running the code 
- *Interpreted* means that when the code is run, each line is effectively read consecutively by a middle layer called an interpreter

"""

# ╔═╡ e4266932-a4c6-4345-ae62-e18a0561dcb2
md"""
### The "Life modeling problem" benchmarks

$(Resource("https://d33wubrfki0l68.cloudfront.net/66d90b5ada11fc740cec59cc8ca00f70ba0bfe92/05f69/assets/benchmarks/code/output/lmp_benchmarks.svg"))

"""

# ╔═╡ 48ac1891-9047-47bf-9536-ec841c746907
md"""
## A Guided Tour of Language Features
### Unicode 

**Example**: Black scholes $$d_1$$ component:

```math
d_1 = \frac{\ln\left(\frac{S}{K}\right) + \tau\left(r + \frac{\sigma^2}{2}\right)}{\sigma\sqrt{\tau}} \\
```

```julia
function d1(S, K, τ, r, σ, q)
    return (log(S / K) +  τ * (r - q + σ^2 / 2)) / (σ * √(τ))
end
```

**Easy to type:** `\sigma[TAB]` creates `σ`
"""

# ╔═╡ 0fa9947b-0d09-416f-869e-4b62861cdcc7
md"""
### Broadcasting 

Simple syntax to automatically extend functionality to work on single arguments 
"""

# ╔═╡ e8696f90-3295-4054-89ca-9ef21595d036
ispositive(x) = x ≥ 0

# ╔═╡ 12f34e76-f2c3-4ab0-a52e-e45f67b92943
ispositive(-1)

# ╔═╡ 80b2e45b-e024-4b3b-9d6d-bf67ba0bddfb
md"We didn't define how this would work on arrays so this will error:"

# ╔═╡ e26e3daf-ee55-434d-9d46-c083537df72a
ispositive([1, 2, 3])

# ╔═╡ 47556a7c-230a-4211-af06-f6fb61fbd7c1
md"But we can broadcast (using the dot, `.`) across arrays:"

# ╔═╡ ae5ed9ec-c4a3-4765-a3e2-35e9e2a285f1
ispositive.([1, 2, 3, -2])

# ╔═╡ 8855b283-153e-4b9c-9758-97e0dea133a4
md"""

### Notebooks

#### Jupyter

- First class support Jupyter (**Julia**, **Pyt**hon, **R**)

#### Pluto Notebooks
Has several features note found in Jupyter notebooks:

- Reactive (each cell knows about and understands the others)
- Version-controll-able (each notebook is just a plain `.jl` Julia file)
- First class interactivity (add slides, buttons, etc. for dynamicism)
- Pulls public dependencies/data on it's own
"""

# ╔═╡ dcaec0a0-ba12-4021-8169-9a4043e38758
@bind b Slider(1:20, show_value=true)

# ╔═╡ 7c668208-8fe7-4f9d-b23c-4725a244d176
b^2

# ╔═╡ 6e4662da-72a5-42a5-80c5-a5846513a1ff
md"""
### Macros and Introspection

Code itself can be operated on!

It's not unique to Julia, but never before bundled with such a dynamic and performant language.

This capability is what enables Pluto notebooks!
"""

# ╔═╡ 37e2e205-0c7e-4135-9e25-901d03fe38a1
md"""
### Macros

Kind of like "magics" in Jupyter/Python, but even more powerful and language-wide.

(Macros are a more advanced topic to *create*, but very easy to *use*.)
"""

# ╔═╡ 519a702a-0dfd-4ecd-a66e-58a5bac0d97b
@benchmark sum(x^2 for x in rand(1000))

# ╔═╡ 5c7f46f6-3a9d-430e-85ce-c692b6903845
# add progress bar to a for loop
@progress for i in 1:50
    sleep(0.1)
end

# ╔═╡ c414d316-454e-4a0c-aeac-54826cc6b203
md"""
#### Other cool macros

- `@edit` will open the function to edit in your default editor
- `@which` will indicate where the function you are using is defined

Performance optimzers (use with special consideration):

- `@inbounds` will disable index checking on arrays
- `@simd` wiil parrallelize within a CPU core (single instruction, multiple dispatch)
- `@threads` will split computation across CPU threads
- `@fastmath` will allow compiler to re-arange math operations for performance, but at the cost of accuracy!

Digging deeper:

- `@code_warntype` will tell you if your code is not type stable
- `@code_llvm` and `@code_native` to see the combiled LLVM and assembly code 

"""

# ╔═╡ a1ea0a4f-8074-4a3f-a88b-eb9f4e8ece3d
md"""
## Modern tooling and large ecosystem

$(Resource("https://imgs.xkcd.com/comics/python_environment.png"))

### Reproducibility and Environment Management

Julia *environments* are defined by the presence of two files:

#### `Project.toml`

This defines the project and its dependencies:

```toml
# Project.toml
name = "ActuaryUtilities"
uuid = "bdd23359-8b1c-4f88-b89b-d11982a786f4"
authors = ["Alec Loudenback"]
version = "3.4.0"

[deps]
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
... more...

[compat]
Distributions = "0.23,0.24,0.25"
ForwardDiff = "^0.10"
QuadGK = "^2"
...more...

```

#### `Manifest.toml`

After *resolving* package versions in the `Project.toml` file, it will record the exact set of packages used. You can share this file with your project, and someone else can `instantiate` with the exact same set of packages/versions that you used (as long as OS and Julia version is the same).

```toml
#Manifest.toml
# This file is machine-generated - editing it directly is not advised

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArrayInterfaceCore]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "7d255eb1d2e409335835dc8624c35d97453011eb"
uuid = "30b0a656-2188-435a-8636-2ec0e6a096e2"
version = "0.1.14"
... more...
```

### Package Management

Built-in `Pkg.jl` allows:

- Package installation and management
- Stacked environments keep projects distinct and non-conflicting
- Using combined public and private repositories 
  - at its simplest, registries are just git repositories, nothing fancy!


### Artifacts

Julia has an Artifacts system, which allows it to bundle platform-specific dependencies/binaries, and data. 

**Example:** a copy of the entire [Mort.SOA.org](https://mort.soa.org/) table set is included as a <10MB file with [MortalityTables.jl](https://github.com/JuliaActuary/MortalityTables.jl)

"""

# ╔═╡ baee42c3-b745-4657-8904-56e3f69c66ca
md"""
### Testing and Documentation built in

Testing and documentation is as important to ensure high quality packages. Because Julia has such easy tools, Julia likely has some of the highest proportion of registered pacakges with docstrings and tests for packages.

```julia
using Test

@test 1 + 1 == 2
```


Simply adding comments creates documenation that is accessible interactively and with built docpages (include math support!):

"""

# ╔═╡ 4b92b938-b5e1-4389-9a94-f8ded9d8c4d9
"""
	mysum(a,b)

Sum numbers `a` and `b`:

``(a + b) = c ``
"""
function mysum(a, b)
    return a + b
end

# ╔═╡ 9a237e79-80ec-4dce-a3f4-4856ae8dcd5b
mysum(1, 2)

# ╔═╡ 93647fd4-e466-48d1-b2e4-eb47d3e0f813
md""" 

### Open ecosystem and range of tools

$(Resource("https://www.julia-vscode.org/img/newscreen1.png"))

- Interactive REPL
- Debugger
- Dynamic recompilation (see `Revise.jl`)
- Can use preferred editor (VS Code is IMO best option for most users)
  - comparable to RStudio experience for R users
    - Variable browser
    - plotting pane
    - documentation
    - intelligent auto-complete
    - integrated REPL
- Notebooks (Jupyter and Pluto)


"""

# ╔═╡ 721d4318-071b-4ff2-a29f-a005b4ff2ffc
md"""
### Python and R Integration

Use existing Python and R code/libraries within Julia!

#### Example: using `seaborn` to plot a pairplot
"""

# ╔═╡ 1d6c8644-fe0e-48c7-8bf0-e69ce366922a
begin
    sns = pyimport("seaborn")
    sns.pairplot(pytable(DataFrame(w=rand(50), x=rand(50), y=rand(50), z=rand(50))), hue="z")
end


# ╔═╡ 00ec6209-f11b-468b-aee5-70689d82c1ea
md"""
### Excel Integration

- ClipData.jl lets you copy and paste data to and from Excel
$(Resource("https://user-images.githubusercontent.com/711879/116339390-f44a9080-a7a2-11eb-9e3b-9d4716747bd1.mp4"))

- JuliaExcel lets you interop Excel and Julia

$(Resource("https://raw.githubusercontent.com/PGS62/JuliaExcel.jl/master/images/Demo4-take3.gif"))

"""

# ╔═╡ ab4a3d0c-e83a-4d24-a3a7-7a5b8400bc20
md" # Insurance Analytics Oriented Case Studies"

# ╔═╡ db87f649-4680-4e5a-9ec0-1e2d998f8205
md"""

An excerpt from one of our previous research papers shows several important and interesting applications in various phases during the insurance sales process. Generally the process consists of three phases - before, during and after sales.

$(Resource("https://raw.githubusercontent.com/leeyuntien-milli/LifeMeeting/main/Potential_Benefits.png"))

The following shows sample code snippets and benchmarking results in various languages.
"""

# ╔═╡ 1465fdd0-f13b-4eee-a7d5-3fde591dea55
md"""
## Use case 1 - similarity calculation

In applications like customer or risk segmentation or fraud detection, one would like to get to know how similar two or more customers, risks or claims look like. Usually the calculation entails a measurement of degree of overlap. Depending on data types, the implementation of one-hot encoded categorical fields may be different from numerical fields.

"""

# ╔═╡ 0810b84a-3129-4809-b71b-9155354985d0
md"""

#### Julia Code

```Julia
using LinearAlgebra

n = 100_000_000
x = BitVector(rand(Bool, n))
y = BitVector(rand(Bool, n))
r = rand(n)
s = rand(n)

function popcnt(x, y) # for one-hot encoded categorical fields
    return LinearAlgebra.dot(x, y) # x ⋅ y for mathophiles
end

function closeness(r, s) # for numerical fields
    return LinearAlgebra.dot(r, s) # r ⋅ s for philomaths
end
```

"""

# ╔═╡ 43ac6ec6-7a55-4cba-a4db-f2f9758ac7ac
md"""

#### Python Code

```Python
import numpy, util, bitarray

n = 100_000_000
x = util.urandom(n)
y = util.urandom(n)
r = numpy.random.rand(n)
s = numpy.random.rand(n)

def popcnt(x, y): # for one-hot encoded categorical fields
    return bitarray.count(x & y)

def like(r, s): # for numerical fields
    return numpy.dot(r, s)
```

"""

# ╔═╡ 650d53d0-588c-4440-bfd8-448f756f4037
md"""

#### Machine specifications

Two machines were selected to test the runtime of the code, one windows and the other linux.

Linux machine. Ubuntu 22.04.2 LTS. 1 physical core and 2 virtual cores on Intel® Xeon® Platinum 8168 @ 2.70GHz. 4G memory.

Windows machine. Windows 10 Enterprise. 16 physical cores and 24 virtual cores on 12th Gen Intel® Core™ i9-12900 @ 2.40 GHz. 64G memory.

Benchmarking results

"""

# ╔═╡ cceb9793-c1fc-437d-8b76-e613da8212b6
md"""
## Use case 2 - simulation

In applications like insurance buying or agency force behavior analyses, risk analyses or reserving on variable annuities or interest-sensitive products, one would normally do simulation to find out how distributions of variables in question look like. Summary statistics like mean or value-at-risk can be derived to help characterize the distributions.

"""

# ╔═╡ 547de723-9a38-4024-b1ec-44d3a34e8b4a
md"""

#### Julia Code - straight

```Julia
using Distribution, Distributed, DistributedArrays

τ = 120 * 12 # policy duration
n = 10_000 # number of policies
m = 1_000 # number of scenarios # number of scenarios
MORT = fill(0.001 / 12, τ) # Mortality for simplicity
survival = cumprod(1.0 .- MORT) # mortality decrement only
POL = (fill(0.02 / 12, n), fill(1000, n)) # charges, benefits
YIELD = 1.0 .+ rand(Uniform(-0.02, 0.08) / 12, m, τ)
res = zeros(m)

function sima(res, survival, YIELD, POL, MORT, m, n, τ)
    for k = 1:m
	    gc = zeros(n) # policy charge
	    av = ones(n) # account value
	    r = zeros(n) # accumulated deficiency
	    b = zeros(n) # benefit
	    for j = 1:τ
	        gc .= av .* POL[1]
	        av .-= gc
	        av .*= y
	        b .= (POL[2] .- av) .* (survival[j] * MORT[j])
	        r .= max.((b .- gc) ./ (YIELD[k, j] ^ j), r)
	    end
		res[k] = sum(r)
    end
end
```

"""

# ╔═╡ b4fa8e12-1a5a-4b57-970d-b8c877233c25
md"""

#### Julia Code - distributed

```Julia
using Distribution, Distributed, DistributedArrays

τ = 120 * 12 # policy duration
n = 10_000 # number of policies
m = 1_000 # number of scenarios # number of scenarios
MORT = fill(0.001 / 12, τ) # Mortality for simplicity
survival = cumprod(1.0 .- MORT) # mortality decrement only
POL = (fill(0.02 / 12, n), fill(1000, n)) # charges, benefits
YIELD = 1.0 .+ rand(Uniform(-0.02, 0.08) / 12, m, τ)
res = zeros((m ÷ nworkers() + 1) * nworkers())
res = distribute(res; dist = nworkers())

@everywhere function simt(survival, YIELD, POL, MORT, n, τ)
    gc = zeros(n) # policy charge
    av = ones(n) # account value
    r = zeros(n) # accumulated deficiency
    b = zeros(n) # benefit
    @inbounds for j = 1:τ
        gc .= av .* POL[1]
        av .-= gc
        av .*= YIELD
        b .= (POL[2] .- av) .* (survival[j] * MORT[j])
        r .= max.((b .- gc) ./ (YIELD ^ j), r)
    end
    return sum(r)
end

function sima(res, survival, YIELD, POL, MORT, m, n, τ)
    @sync @distributed for k = 1:m
        res_local = localpart(res)
        res_local[(k - 1) % (m ÷ nworkers() + 1) + 1] =
        simt(survival, YIELD[k, :], POL, MORT, n, τ)
    end
end
```

"""

# ╔═╡ 196e0fbd-7f1f-45ff-854e-dc2d957d3eb0
md"""

#### Julia Code - distributed with looping

```Julia
using Distribution, Distributed, DistributedArrays

τ = 120 * 12 # policy duration
n = 10_000 # number of policies
m = 1_000 # number of scenarios # number of scenarios
MORT = fill(0.001 / 12, τ) # Mortality for simplicity
survival = cumprod(1.0 .- MORT) # mortality decrement only
POL = (fill(0.02 / 12, n), fill(1000, n)) # charges, benefits
YIELD = 1.0 .+ rand(Uniform(-0.02, 0.08) / 12, m, τ)
res = zeros((m ÷ nworkers() + 1) * nworkers())
res = distribute(res; dist = nworkers())

@everywhere function simt(YIELD, POL, survival, n, τ)
    gc = zeros(n) # policy charge
    av = ones(n) # account value
    r = zeros(n) # accumulated deficiency
    @inbounds @fastmath for j = 1:τ
		@inbounds @fastmath for k = 1:n
	        gc[k] = av[k] * POL[1][k]
	        av[k] -= gc[k]
	        av[k] *= YIELD[j]
	        r = max(((POL[2][k] - av[k]) * survival[j] - gc[k]) / (YIELD[j] ^ j), r[k])
		end
    end
    return sum(r)
end

function sima(res, survival, YIELD, POL, MORT, m, n, τ)
    @sync @distributed for k = 1:m
        res_local = localpart(res)
        res_local[(k - 1) % (m ÷ nworkers() + 1) + 1] =
        simt(YIELD[k, :], POL, survival .* MORT, n, τ)
    end
end
```

"""

# ╔═╡ 00570477-26d7-4030-9ae9-3baaf0cef8a9
md"""

#### Python Code (un-parallelized)

```Python
t = 120 * 12 # policy duration
n = 10_000 # number of policies
m = 1_000 # number of scenarios
MORT = np.full(t, 0.001 / 12)
survival = np.cumprod(1.0 - MORT)
POL = (np.full(n, 0.02 / 12), np.full(n, 1000))
YIELD = 1.0 + np.array([np.random.uniform(-0.02, 0.08, (m, t))])
res = np.zeros(m) # reserve

def sima(gc, b, res, survival, YIELD, POL, MORT, m, n, t):
  for k in range(m): # number of scenarios
      gc = np.zeros(n) # policy charge
      b = np.zeros(n) # benefit
      r = np.zeros(n) # accumulated deficiency
      av = np.ones(n) # account value
      for j in range(t): # timepoints
          gc = av * POL[0]
          av -= gc
          av *= YIELD[k, j]
          b = (POL[1] - av) * (survival[j] * MORT[j])
          r = np.maximum((b - gc) / (YIELD[k, j] ** (j + 1)), r)
      res[k] = sum(r)
```

"""

# ╔═╡ bb9f644d-90c3-4167-aed3-fd8e55b2f422
begin
	simulation_time_linux = [26431, 78273.5, 83099.95, 14234.42, 33888, 26284, 75330.8, 82765.7, 14162.68, 33861, 26568, 80961.7, 83679.49, 14282.2, 33917]
	simulation_time_windows = [1909.97, 45636.8, 14300.6, 1775.49, 4491, 1837.92, 30660.7, 14152.69, 1753.82, 4405, 2131.97, 88258.9, 14425.36, 1800.11, 4565]
	
	plot(boxplot(lang, simulation_time_linux, title = "Simulation (Linux)", label = "runtime in ms", colour = :purple), boxplot(lang, simulation_time_windows, title = "Simulation (Windows)", label = "runtime in ms", colour = :violet), layout=[1 1])
	
end

# ╔═╡ a9c284b4-c851-46f1-b7d2-aa70456ab7d8
md"""
## Use case 3 - parameter estimation

In applications like automatic underwriting, channel matching or recommendation systems, one would normally like to find out inherent behavior of a user-attribute matrix by decomposing the matrix into sub-components. One typical technique to decompose matrices is through gradient descents. Since the matrices are usually sparse in insurance applications, the following shows an extension to the procedure to deal with sparse matrices.

"""

# ╔═╡ 753cff1f-0648-43f4-9aaf-56dc4686cd3d
md"""

#### Julia Code

```Julia
using PyCall
using SparseArrays

#f is loaded from a pickle file
data = pickle.load(f, encoding = "latin1")
w = sparse(data.nonzero()[1].+1, data.nonzero()[2].+1, data.data)
X = w[:, 2:size(w)[2]]
y = w[:, 1]
κ = 10
V = rand(X.n, κ)
ΔV = rand(X.n, κ)
cross_terms = X * V
cross_terms = X * V
square_terms = (X .* X) * (V .* V)
total_losses = Array(y .- 0.5 .* sum(cross_terms .* cross_terms .- square_terms, dims=2))[:, 1]

function sgd_V(X, total_losses, cross_terms,V,ΔV,κ=10,α=0.99,γ=0.1,λᵥ=0.1)
  x_loss = copy(X);  xxll = copy(X)
  currV = copy(V)
  x_loss.nzval .*=    
      total_losses[X.rowval];    
  x_loss.nzval ./= X.m
  xxll .*= xxll; xxll.nzval .*=  
     total_losses[X.rowval]; 
  xxll.nzval./=X.m; 
  xxl = sum(xxll, dims=1)
  xvxl = x_loss' * cross_terms
   @inbounds for f in 1:κ
      @inbounds for i in 1:X.n
         V[i, f] -= α * ((xvxl[i, f] - xxl[i] * V[i, f]) + γ * ΔV[i, f] + λᵥ * V[i, f])
        end
    end
    ΔV .= currV .- V
end

```

"""

# ╔═╡ 22270d64-5a92-4677-8d91-c4f5644e6bd3
md"""

#### Python Code

```Python
def setup():
    path = "df_csr.pickle"
    f = open(path, "rb")
    w = pickle.load(f, encoding="latin1") 
    X = w[:, 1:w.shape[1]]
    y = w[:, 0];   k = 10
    num_samples, num_attr = X.shape
    V = np.random.rand(num_attr, k)
    cross_terms = X * V
    square_terms = X.multiply(X) * np.multiply(V, V)
    total_losses = y.toarray().flatten() - 0.5 * (np.multiply(cross_terms, cross_terms) - square_terms).sum(axis = 1)
    delta_V = np.random.rand(num_attr, k)
    return X, total_losses,cross_terms,   
           V, delta_V

def sgd_V(X, total_losses, cross_terms, v, dv,
    k=10, learning_rate=0.99, m_r=0.1, m_l=0.1):
    V = v.copy()
    delta_V = dv.copy()
    x_loss = scipy.sparse.csr_matrix.copy(X)
    currV = np.matrix.copy(V)
    x_loss = X.multiply(total_losses) / X.shape[0]
    xxl = X.multiply(X).multiply(total_losses)
           .sum(axis=0) / X.shape[0]
    xvxl = x_loss.T * cross_terms
    for f in range(k):
        for i in range(X.shape[1]):
            V[i, f] -= learning_rate * \
                ((xvxl[i, f] - xxl[0, i] * V[i, f])   
            + m_r * delta_V[i, f] + m_l * V[i, f])
    delta_V = currV - V
    return delta_V

```

"""

# ╔═╡ ba07960a-f377-4de3-bd04-283908c812e4
begin
	sgd_time_linux = [983.37, 2011, 1065.98, 4087.29, 7131, 945.91, 1943.6, 1065.98, 4014.08, 7083, 1002.51, 2094.6, 1065.98, 4139.59, 7152]
	sgd_time_windows = [232, 976.71, 334.16, 2538.01, 3038, 214.8, 971.32, 322.15, 2525.71, 3034, 241.74, 996.67, 348.08, 2557.78, 3042]
	
	plot(boxplot(lang, sgd_time_linux, title = "Sparse-sgd (Linux)", label = "runtime in ms", colour = :green), boxplot(lang, sgd_time_windows, title = "Sparse-sgd (Windows)", label = "runtime in ms", colour = :lightgreen), layout=[1 1])
	
end

# ╔═╡ ad53dcdd-30a7-4b24-84c6-9fcf6e60ded8
md"""
# The Ecosystem for Actuaries

Nearing 10,000 registered packages as of July 2023.

## Misc Packages

### Data Science:
- **DataFrames.jl**
  - **DataFramesMeta.jl** or **Tidier.jl** for R-like syntax
- **CSV.jl**
- **Distributions.jl**
- **StatsBase.jl**
- Has newer columnar packages - **Arrow**/**Parquet**/etc
- Cheatsheets: [https://www.juliafordatascience.com/cheat-sheets/](https://www.juliafordatascience.com/cheat-sheets/)

### Plotting:

Many options available. Suggestions:

- **Plots.jl** Straightforward & robust plotting
- **Makie.jl** Very powerful plotting package
  - The most powerful plotting package (of any language?)
  - https://lazarusa.github.io/BeautifulMakie/
- **Gadfly.jl** grammar-of-graphics like package
- **Bokeh** and **Plotly** - Interactive web plots

### Statistics & Machine Learning

- StatsBase
- Turing.jl - Bayesian probabilistic programming
- GLM.jl - Linear Models
- Flux.jl - neural nets
- ...

### Other

- Optimization
- Automatic differentiation
- Machine learning
- Differential Equations
- Web servers & web scraping
- Dashboards
- Quantum Computing

"""

# ╔═╡ e94fc916-27a9-448d-9237-65a8e954e2af
md"""
## JuliaActuary

A suite of packages intended to make actuarial work very easy. Created by several contributors including your panelists today.

$(Resource("https://d33wubrfki0l68.cloudfront.net/8b9dddb3ea7c5514ebe910544ff7e997af802b83/a30c1/assets/logo_square.svg",:width=>200))

The homepage at [https://juliaactuary.org/](https://juliaactuary.org/) has documentation, tutorials, interactive notebooks, blogs, and community/contributing guidelines.

### Released packages

- MortalityTables.jl
  - Easily work with standard mort.SOA.org tables and parametric models with common survival calculations.

- LifeContingencies.jl
  - Insurance, annuity, premium, and reserve maths.

- ActuaryUtilities.jl
  - Robust and fast calculations for internal_rate_of_return, duration, convexity, present_value, breakeven, and other commonly used routines in insurance.

- FinanceModels.jl
  - Flexible foundations for building an arbitray contract, model, and projection
  - Simple and composable yield curves and calculations.

- ExperienceAnalysis.jl
  - Easy and flexible exposure calculations.

- EconomicScenarioGenerators.jl
  - Create FinanceModels.jl-compatible stochastic economic scenarios


"""

# ╔═╡ be39b864-45cb-480d-9bb2-67d56a495147
md"### An integrated example"

# ╔═╡ af9484e7-7f5c-448e-9b49-a2a9adbcc596
md"""

#### Yields and Rates

##### `Rate`s

`Rate`s are a type defined in Yields.jl:
"""

# ╔═╡ f506bcbe-4d67-4e61-8b2f-af23b0ddf1cd
rates = [
    Periodic(0.04, 1),
    Periodic(0.04, 2),
    Continuous(0.04),
]


# ╔═╡ b3238c9a-a7bc-4dbe-9657-fc23144a400c
c = Continuous(0.04)

# ╔═╡ 969ecaae-c39c-46e6-b7b8-0c6fd910339b
accumulation.(rates, 1) # accumulate the rates for 1 period

# ╔═╡ 119b6051-c1f3-41e5-a415-4358d1366703
discount.(rates, 1) # discount factors for 1 period

# ╔═╡ e92df94f-cb38-486f-89be-5b8a39aa59c9
yield = let
    # 2021-03-31 rates from Treasury.gov
    rates = [0.01, 0.01, 0.03, 0.05, 0.07, 0.16, 0.35, 0.92, 1.40, 1.74, 2.31, 2.41]

    rates = rates ./ 100 # convert from percents to rates

    maturities = [1 / 12, 2 / 12, 3 / 12, 6 / 12, 1, 2, 3, 5, 7, 10, 20, 30]

	quotes = CMTYield.(rates,maturities)

	# bootstrap the CMT rates to a linear spline
    yield = fit(Spline.Linear(),quotes,Fit.Bootstrap())
end

# ╔═╡ 9655b919-bc39-4055-a12c-4c57cf2cff8b
forward(yield, 0, 10)

# ╔═╡ a0af8bfc-357c-452f-9b0f-4b6bef4c2714
md" #### Mortality and other rate tables

For example, the [2001 VBT Male NS table](https://mort.soa.org/ViewTable.aspx?&TableIdentity=1118)"

# ╔═╡ 663067a1-704d-4a1a-bf26-1bccb160bc67
vbt2001 = MortalityTables.table("2001 VBT Residual Standard Select and Ultimate - Male Nonsmoker, ANB")

# ╔═╡ 4a906be4-9c1e-459e-84e0-394601c57a00
md" The table is indexed by issue and attained age, e.g. select rates for ages 65-75 to a policy underwritten at age 65:"

# ╔═╡ 3253db45-ebd8-4047-8182-45fe5a1305e4
vbt2001.ultimate

# ╔═╡ d84db7cb-49e1-4cba-9b9d-b593b0151aeb
vbt2001.select[65][65:end]

# ╔═╡ 0d387f41-24a5-4233-b229-15ada348a20a
vbt2001.select[65][65:70]

# ╔═╡ 7238532c-f2b0-4b63-b028-109caf2c196b
md"##### Survival and decrements"

# ╔═╡ 9675af2c-f6e1-4fbb-8b85-221226d0bd2b
survival(vbt2001.ultimate, 65, 70), decrement(vbt2001.ultimate, 65, 70)

# ╔═╡ 0165537c-7735-4a07-859a-a09a43f4b494
md"#### Life Contingencies"

# ╔═╡ 5332aae1-11ff-42f4-adbf-b131a8b238bc
issue_age = 30

# ╔═╡ 5b690c88-7cb6-4618-9980-933789bf51c2
l = SingleLife(mortality=vbt2001.select[issue_age])

# ╔═╡ b20695b9-b1c3-44c6-9e7e-8927ba007fae
# actuarial present value of Whole Life insurance
insurance = Insurance(LifeContingency(l, yield))

# ╔═╡ c2f6787b-e7d4-4c7e-ab31-f5cad6e75929
cashflows(insurance) |> collect

# ╔═╡ a645d95a-ebb1-4d48-83c0-830faa754f31
timepoints(insurance) |> collect

# ╔═╡ e40482d8-0a49-4681-aa3f-8c04e1f80c96
probability(insurance) |> collect

# ╔═╡ f5c0f9bc-1032-4ab8-b7bd-8149e8d77118
benefit(insurance)

# ╔═╡ c96d27e5-fe7a-46a4-944c-38b767e1b885
survival(insurance) |> collect

# ╔═╡ de6303ac-8da9-4848-ad7e-714ca2c894bb
md"#### Financial Maths"

# ╔═╡ 5405b11b-288e-4e06-917c-1eb6a82a1ac9
pv(insurance)

# ╔═╡ 00567c83-29fc-47a8-911a-a28e77ded7b2
duration(yield, cashflows(insurance))

# ╔═╡ 94264fcb-b69f-4f9b-b8bb-83c31e22ffb1
convexity(yield, cashflows(insurance))

# ╔═╡ 4cb7f1e1-8a07-4bd3-b92e-1a6c0ff3698f
reserve = pv(yield, cashflows(insurance))

# ╔═╡ d73421f8-e2e9-4b9a-90af-d7625a1d30c5
# `...` "splats" the lazy values into an array
cf_vector = [-reserve; cashflows(insurance)...]

# ╔═╡ 0bfc0522-10a1-4d08-a8fb-5c0dcbe1db77
irr(cf_vector)

# ╔═╡ 3b3c4951-7c85-41b1-9f5b-1a23f4b4c465
md""" # Endnotes

## Learning

It's worth an entire session on its own, but some online resources:

- https://juliaacademy.com/ - Online video courses
- https://ucidatascienceinitiative.github.io/IntroToJulia/ - UC Irvine Data Science course
- https://www.juliafordatascience.com/ - Tutorials
- https://juliadatascience.io/ - Online book
- ... many more online

## More stuff for actuaries

- This presentation is a conglomeration of code and ideas from pages/notebooks on JuliActuary.org:
  - [Tutorials and examples](https://juliaactuary.org/community/#learn)
  - [Coding the Future](https://juliaactuary.org/blog/coding-for-the-future/)
  - [Julia for Actuaries](https://juliaactuary.org/blog/julia-actuaries/)
  - [Getting Started with Juila for Actuaries](https://juliaactuary.org/blog/julia-getting-started-actuaries/)
  - [Benchmarks for Actuarial Workflows](https://juliaactuary.org/benchmarks/)

## JuliaActuary website resources

See [JuliaActuary.org](https://juliaactuary.org/) for lots more, such as this interactive mortality table comparison notebook:

$(Resource("https://d33wubrfki0l68.cloudfront.net/6c3f21d50fd8d6a130afabf87ed63de21a67fb89/3d3a3/tutorials/_assets/mortalitytablecomparison/demo.gif"))
"""

# ╔═╡ f1675cb1-ece0-4a5f-a0eb-7fd16010461c
md"## Colophon"

# ╔═╡ 1e3e432b-3027-4dfe-992c-14189f675181
TableOfContents()

# ╔═╡ 25e6509e-80ae-4946-bc67-cfa42fe1beef
html"""
<script>
    const calculate_slide_positions = (/** @type {Event} */ e) => {
        const notebook_node = /** @type {HTMLElement?} */ (e.target)?.closest("pluto-editor")?.querySelector("pluto-notebook")
		console.log(e.target)
        if (!notebook_node) return []

        const height = window.innerHeight
        const headers = Array.from(notebook_node.querySelectorAll("pluto-output h1, pluto-output h2"))
        const pos = headers.map((el) => el.getBoundingClientRect())
        const edges = pos.map((rect) => rect.top + window.pageYOffset)

        edges.push(notebook_node.getBoundingClientRect().bottom + window.pageYOffset)

        const scrollPositions = headers.map((el, i) => {
            if (el.tagName == "H1") {
                // center vertically
                const slideHeight = edges[i + 1] - edges[i] - height
                return edges[i] - Math.max(0, (height - slideHeight) / 2)
            } else {
                // align to top
                return edges[i] - 20
            }
        })

        return scrollPositions
    }

    const go_previous_slide = (/** @type {Event} */ e) => {
        const positions = calculate_slide_positions(e)
        const pos = positions.reverse().find((y) => y < window.pageYOffset - 10)
        if (pos) window.scrollTo(window.pageXOffset, pos)
    }

    const go_next_slide = (/** @type {Event} */ e) => {
        const positions = calculate_slide_positions(e)
        const pos = positions.find((y) => y - 10 > window.pageYOffset)
        if (pos) window.scrollTo(window.pageXOffset, pos)
    }

	const left_button = document.querySelector(".changeslide.prev")
	const right_button = document.querySelector(".changeslide.next")

	left_button.addEventListener("click", go_previous_slide)
	right_button.addEventListener("click", go_next_slide)
</script>
"""

# ╔═╡ Cell order:
# ╟─458f2690-e3fb-40a8-a657-e3a0666af69c
# ╟─3c2da572-90d0-4206-9586-18f2cea6b6ca
# ╟─6c77e9ff-caec-4713-a71a-744df5bf7660
# ╟─434f336d-63ff-40f6-b64f-e538b6f08fd9
# ╟─142954b2-9615-4527-9a1a-d687583ff38e
# ╟─47c7ecd8-1610-4ce8-bff1-814a48336368
# ╟─7b86f12b-de88-40e0-bee3-1d9ba188fd40
# ╟─fb686b8b-bbb8-43b5-8241-493463275346
# ╠═3fcc0272-814a-423b-aad0-63030a32b8f5
# ╠═3d8916c4-2315-4420-a19b-61ac58ea9d60
# ╠═0c66ed9c-4fd2-4636-ad56-5bcc0b606f07
# ╠═bba42bba-d76e-48f1-a376-0c03a817f880
# ╠═494265ee-e0c5-4644-9cd8-63e0f40de78b
# ╠═bb75f7b0-5cb2-425d-8c3c-13f49862d44a
# ╟─b72b91c5-c6df-4eb5-a5e0-63ef8f20d34c
# ╠═f23b4b4e-baf5-4a7d-9a33-14050f1993e6
# ╟─5c811d55-53df-4a9c-b75f-4656168b70e2
# ╟─7bb2e1bc-ed41-406f-993d-1cc3a75af478
# ╟─57a4d392-6579-41dd-a79b-87b3c8dfba72
# ╟─44ec070b-4732-4b7b-9f75-51dd06032a4b
# ╟─b77156a3-1180-434e-90ec-841b8ef8d632
# ╟─e4266932-a4c6-4345-ae62-e18a0561dcb2
# ╟─48ac1891-9047-47bf-9536-ec841c746907
# ╟─0fa9947b-0d09-416f-869e-4b62861cdcc7
# ╠═e8696f90-3295-4054-89ca-9ef21595d036
# ╠═12f34e76-f2c3-4ab0-a52e-e45f67b92943
# ╟─80b2e45b-e024-4b3b-9d6d-bf67ba0bddfb
# ╠═e26e3daf-ee55-434d-9d46-c083537df72a
# ╟─47556a7c-230a-4211-af06-f6fb61fbd7c1
# ╠═ae5ed9ec-c4a3-4765-a3e2-35e9e2a285f1
# ╟─8855b283-153e-4b9c-9758-97e0dea133a4
# ╠═dcaec0a0-ba12-4021-8169-9a4043e38758
# ╠═7c668208-8fe7-4f9d-b23c-4725a244d176
# ╟─6e4662da-72a5-42a5-80c5-a5846513a1ff
# ╟─37e2e205-0c7e-4135-9e25-901d03fe38a1
# ╠═4daea69e-a4b5-48f6-b932-b90a38544105
# ╠═519a702a-0dfd-4ecd-a66e-58a5bac0d97b
# ╠═51105b4d-cd07-4244-9715-7160e629f998
# ╠═5c7f46f6-3a9d-430e-85ce-c692b6903845
# ╟─c414d316-454e-4a0c-aeac-54826cc6b203
# ╠═a1ea0a4f-8074-4a3f-a88b-eb9f4e8ece3d
# ╟─baee42c3-b745-4657-8904-56e3f69c66ca
# ╠═4b92b938-b5e1-4389-9a94-f8ded9d8c4d9
# ╠═9a237e79-80ec-4dce-a3f4-4856ae8dcd5b
# ╟─93647fd4-e466-48d1-b2e4-eb47d3e0f813
# ╟─721d4318-071b-4ff2-a29f-a005b4ff2ffc
# ╠═009b8e21-a7a2-41d0-af6c-5be89ea819f7
# ╠═1d6c8644-fe0e-48c7-8bf0-e69ce366922a
# ╟─00ec6209-f11b-468b-aee5-70689d82c1ea
# ╟─ab4a3d0c-e83a-4d24-a3a7-7a5b8400bc20
# ╟─db87f649-4680-4e5a-9ec0-1e2d998f8205
# ╟─1465fdd0-f13b-4eee-a7d5-3fde591dea55
# ╟─0810b84a-3129-4809-b71b-9155354985d0
# ╟─43ac6ec6-7a55-4cba-a4db-f2f9758ac7ac
# ╟─675e95d9-2d12-4324-9418-a12de6e8c082
# ╟─650d53d0-588c-4440-bfd8-448f756f4037
# ╟─cceb9793-c1fc-437d-8b76-e613da8212b6
# ╟─547de723-9a38-4024-b1ec-44d3a34e8b4a
# ╟─b4fa8e12-1a5a-4b57-970d-b8c877233c25
# ╟─196e0fbd-7f1f-45ff-854e-dc2d957d3eb0
# ╟─00570477-26d7-4030-9ae9-3baaf0cef8a9
# ╟─bb9f644d-90c3-4167-aed3-fd8e55b2f422
# ╟─a9c284b4-c851-46f1-b7d2-aa70456ab7d8
# ╟─753cff1f-0648-43f4-9aaf-56dc4686cd3d
# ╟─22270d64-5a92-4677-8d91-c4f5644e6bd3
# ╟─ba07960a-f377-4de3-bd04-283908c812e4
# ╟─ad53dcdd-30a7-4b24-84c6-9fcf6e60ded8
# ╟─e94fc916-27a9-448d-9237-65a8e954e2af
# ╟─be39b864-45cb-480d-9bb2-67d56a495147
# ╠═1c0ccd93-59b8-46e2-bf3a-45ae79b35af0
# ╟─af9484e7-7f5c-448e-9b49-a2a9adbcc596
# ╠═f506bcbe-4d67-4e61-8b2f-af23b0ddf1cd
# ╠═b3238c9a-a7bc-4dbe-9657-fc23144a400c
# ╠═969ecaae-c39c-46e6-b7b8-0c6fd910339b
# ╠═119b6051-c1f3-41e5-a415-4358d1366703
# ╠═e92df94f-cb38-486f-89be-5b8a39aa59c9
# ╠═9655b919-bc39-4055-a12c-4c57cf2cff8b
# ╟─a0af8bfc-357c-452f-9b0f-4b6bef4c2714
# ╠═663067a1-704d-4a1a-bf26-1bccb160bc67
# ╟─4a906be4-9c1e-459e-84e0-394601c57a00
# ╠═3253db45-ebd8-4047-8182-45fe5a1305e4
# ╠═d84db7cb-49e1-4cba-9b9d-b593b0151aeb
# ╠═0d387f41-24a5-4233-b229-15ada348a20a
# ╟─7238532c-f2b0-4b63-b028-109caf2c196b
# ╠═9675af2c-f6e1-4fbb-8b85-221226d0bd2b
# ╟─0165537c-7735-4a07-859a-a09a43f4b494
# ╠═5332aae1-11ff-42f4-adbf-b131a8b238bc
# ╠═5b690c88-7cb6-4618-9980-933789bf51c2
# ╠═b20695b9-b1c3-44c6-9e7e-8927ba007fae
# ╠═c2f6787b-e7d4-4c7e-ab31-f5cad6e75929
# ╠═a645d95a-ebb1-4d48-83c0-830faa754f31
# ╠═e40482d8-0a49-4681-aa3f-8c04e1f80c96
# ╠═f5c0f9bc-1032-4ab8-b7bd-8149e8d77118
# ╠═c96d27e5-fe7a-46a4-944c-38b767e1b885
# ╟─de6303ac-8da9-4848-ad7e-714ca2c894bb
# ╠═5405b11b-288e-4e06-917c-1eb6a82a1ac9
# ╠═00567c83-29fc-47a8-911a-a28e77ded7b2
# ╠═94264fcb-b69f-4f9b-b8bb-83c31e22ffb1
# ╠═4cb7f1e1-8a07-4bd3-b92e-1a6c0ff3698f
# ╠═d73421f8-e2e9-4b9a-90af-d7625a1d30c5
# ╠═0bfc0522-10a1-4d08-a8fb-5c0dcbe1db77
# ╟─3b3c4951-7c85-41b1-9f5b-1a23f4b4c465
# ╟─f1675cb1-ece0-4a5f-a0eb-7fd16010461c
# ╠═8320edcc-ef78-11ec-0445-b100a477c027
# ╠═1e3e432b-3027-4dfe-992c-14189f675181
# ╟─25e6509e-80ae-4946-bc67-cfa42fe1beef
