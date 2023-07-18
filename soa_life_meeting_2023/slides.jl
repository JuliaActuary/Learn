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

# ╔═╡ 1c0ccd93-59b8-46e2-bf3a-45ae79b35af0
using MortalityTables, Yields, LifeContingencies, ActuaryUtilities

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

The following shows sample code snippets and benchmarking results in various languages.

$(Resource("https://raw.githubusercontent.com/leeyuntien-milli/LifeMeeting/main/Potential_Benefits.png"))
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
    return LinearAlgebra.dot(x, y)
end

function like(r, s) # for numerical fields
    return LinearAlgebra.dot(r, s)
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

# ╔═╡ 8b7ceb12-548c-49e0-af3a-6bb101a581e6
md"""

#### Rust Code

```Rust
use rayon::prelude::*;

pub fn and_count_par(a: &[i32], b: &[i32]) -> u32 {
    let vec: Vec<i32> = a.par_iter().zip(b.par_iter()).map(|(&a, &b)| a & b).collect();
    let count = vec.par_iter().map(|&byte| byte.count_ones()).sum();
    return count;
}

pub fn main() {
    let bits = 100_000_000;
    let x = rand_vec(bits);
    let y = rand_vec(bits);
	and_count_par(&x,&y);
}
```

"""

# ╔═╡ 75338a1c-9684-4bf7-9952-cdeaf315e15b
md"""

#### C++ Code

```Cpp
#include <iostream>
#include <functional>
#include <boost/chrono.hpp>
#include <boost/random/mersenne_twister.hpp>
#include <boost/dynamic_bitset.hpp>
#include <boost/iterator/function_input_iterator.hpp>
#include <boost/iterator/function_output_iterator.hpp>

#include "profile.hpp"
#include "profile_config.hpp"
#include "collector/json.hpp"

using namespace boost;

const size_t BIT_CAPACITY = 100000000;

typedef random::mt19937 prng_type;
typedef prng_type::result_type block_type;
typedef dynamic_bitset<block_type> bitvector_type;
typedef bitvector_type::size_type size_type;

class specialization_tag
{
};

template <typename SPECIALIZATION>
size_type count_bits(bitvector_type const& bitvector, SPECIALIZATION const& specialization)
{
	return bitvector.count();
}

#if defined(USE_KERNIGHAN_BIT_COUNT_ALGORITHM)

class bit_counter
{
public:
	bit_counter(size_type* counter) :
		counter_(counter)
	{
	}

	bit_counter(bit_counter const& other) :
		counter_(other.counter_)
	{
	}

	bit_counter& operator=(bit_counter const& other)
	{
		counter_ = other.counter_;
		return *this;
	}

	void operator()(block_type integer)
	{
		size_type bits = 0;
		while (integer)
		{
			++bits;
			integer &= integer - 1;
		}
		*counter_ += bits;
	}

private:
	size_type* counter_;
};

template <>
size_type count_bits<specialization_tag>(bitvector_type const& bitvector, specialization_tag const& specialization)
{
	size_type count = 0;
	bit_counter counter(&count);
	to_block_range(bitvector, make_function_output_iterator(counter));
	return count;
}

#endif /* USE_KERNIGHAN_BIT_COUNT_ALGORITHM */

class profiler_subject
{
protected:
	profiler_subject() :
		x_bitvector_(BIT_CAPACITY),
		y_bitvector_(BIT_CAPACITY),
		bitcount_(0),
		prng_(static_cast<block_type>(std::time(0)))
	{
	}

protected:
	void setup()
	{
	}

	void begin_sample(int trial)
	{
		size_type zero(0);

		std::cerr << "[PROGRESS] starting trial #" << trial << "..." << std::endl;

		from_block_range(make_function_input_iterator(prng_, zero), make_function_input_iterator(prng_, x_bitvector_.num_blocks()), x_bitvector_);
		from_block_range(make_function_input_iterator(prng_, zero), make_function_input_iterator(prng_, y_bitvector_.num_blocks()), y_bitvector_);
	}

	void sample(int trial)
	{
		dynamic_bitset<block_type> intersection(x_bitvector_);
		intersection &= y_bitvector_;
		bitcount_ = count_bits(intersection, specialization_tag());
	}

	void end_sample(int trial)
	{
		std::cerr << "[PROGRESS] bit count for trial #" << trial << " of " << BIT_CAPACITY << ": " << bitcount_ << std::endl;
	}

	void teardown()
	{
	}

private:
	bitvector_type x_bitvector_;
	bitvector_type y_bitvector_;
	size_type bitcount_;
	prng_type prng_;
};

int main(int argc, char* argv[])
{
	int result = 0;
	json_output collector;
	argv_collection arguments(argc - 1, argv + 1);
	
	try
	{
		profile_config<argv_collection::const_iterator> config(arguments.begin(), arguments.end());
		profiler<profiler_subject, json_output> metrics(config.get_trial_count(), collector);
		metrics.run();
	}
	catch (std::exception const& e)
	{
		std::cerr << "[ERROR] " << e.what() << std::endl;
		result = 1;
	}
	
	return result;
}
```

"""

# ╔═╡ 675e95d9-2d12-4324-9418-a12de6e8c082
md"""

Benchmarking results

$(Resource("https://raw.githubusercontent.com/leeyuntien-milli/LifeMeeting/main/similarity1.png"))

$(Resource("https://raw.githubusercontent.com/leeyuntien-milli/LifeMeeting/main/similarity2.png"))

"""

# ╔═╡ cceb9793-c1fc-437d-8b76-e613da8212b6
md"""
## Use case 2 - simulation

In applications like insurance buying or agency force behavior analyses, risk analyses or reserving on variable annuities or interest-sensitive products, one would normally do simulation to find out how distributions of variables in question look like. Summary statistics like mean or value-at-risk can be derived to help characterize the distributions.

"""

# ╔═╡ b4fa8e12-1a5a-4b57-970d-b8c877233c25
md"""

#### Julia Code

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

# ╔═╡ 00570477-26d7-4030-9ae9-3baaf0cef8a9
md"""

#### Python Code

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

# ╔═╡ 8da63366-88ea-48c1-a696-0a3442793232
md"""

#### Rust Code

```Rust
use rayon::prelude::*;
use serde::Serialize;
use std::env;
use std::{time::Duration};
use std::fs::File;
use std::io::prelude::*;
use serde_json::{self, to_string_pretty};

#[derive(Serialize)]
struct Stats { pub min: Duration, pub max: Duration, pub avg: Duration }

#[allow(non_snake_case)]
pub fn sima(res:&mut [f64], survival:&[f64], YIELD:&[f64], POL:&(Vec<f64>,Vec<f64>), MORT:&[f64],n:usize){
    let max_val = |x: f64, y: f64| if x > y { x } else { y };
    let sm:Vec<f64> = survival.iter().zip(MORT.iter()).map(|(a,b)| a * b ).collect();
    let  res_par:Vec<f64> = YIELD.par_iter().map(|&yield_value| { //number of scenarions
        let mut r = vec![0.0;n]; //accumulated deficiency
        let mut av = vec![1.0;n];
        for j in 0..MORT.len() { //number of timepoints
            let gc : Vec<f64> = av.iter().zip(POL.0.iter()).map(|(a,b)| a * b ).collect();
            av = av.iter().zip(gc.iter()).map(|(a,b)|a-b).collect();
            av = av.iter().map(|a|a*yield_value).collect();
            let bl:Vec<f64> = POL.1.iter().zip(av.iter()).map(|(a,b)|a-b).collect();
            let b:Vec<f64> = bl.iter().map(|a| a * sm[j]).collect();
            let e = j as f64 + 1.0;
            for i in 0..r.len() {
                let val = (b[i] - gc[i]) / yield_value.powf(e);
                *r.get_mut(i).unwrap() = max_val(val, r[i]);
            }
        }
        
        r.iter().map(|a|a).sum()
        
    }).collect();
    res.copy_from_slice(&res_par)
}

#[allow(non_snake_case)]
pub fn main(){
    let τ = 120 * 12; // policy duration
    let n = 10_000; // number of policies
    let scen = match env::var("SCENARIOS") { Ok(val) => val, Err(_) => String::new()
    };
    let m = scen.parse::<usize>().unwrap_or(12);
   
    let MORT=  vec![0.001/12.0; τ];
    let p: Vec<f64> = MORT.iter().map(|&a| { 1.0 - a }).collect();
    let mut survival_prod = 1.0;
    let survival: Vec<f64> = p.iter()
    .map(|&n| { survival_prod *= n; survival_prod }).collect();
    let Σ = load_data(m);
    let POL = (vec![0.02/12.0; n] , vec![1000.0; n]);
    let YIELD: Vec<f64> = Σ.iter().map(|&a| { 1.0 + a }).collect();
    let mut res = vec![0.0; m]; // reserve

	sima(&mut res,&survival,&YIELD,&POL,&MORT,n);
}
```

"""

# ╔═╡ 534286c2-5f08-41b9-adac-29ecd2d71316
md"""

#### C++ Code

```Cpp

#include <iostream>
#include <assert.h>

#include <boost/asio.hpp>
#include <boost/bind/bind.hpp>
#include <boost/thread/latch.hpp>
#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/matrix_proxy.hpp>

#include "parallelization.hpp"
#include "matrix_io.hpp"
#include "profile.hpp"
#include "profile_config.hpp"
#include "collector/json.hpp"

using namespace std;
using namespace boost;
using namespace boost::asio;

#if defined(DISABLE_PARALLELIZATION)
typedef parallelization<parallelism::single_threaded> parallelization_type;
#else
typedef parallelization<parallelism::multi_threaded> parallelization_type;
#endif /* DISABLE_PARALLELIZATION */

/* Constants */
const size_t POLICY_COUNT = 10000;
const size_t TIMESTEP_COUNT = 12 * 120;

/* Shorthand for real vector type */
typedef vector<double> real_vector_type;

/* Modeled policy fields */
struct policy_record
{
	double av;
	double benefit;
};

/* Shorthand for policy vector type */
typedef vector<policy_record> policy_vector_type;

/* Simulation inputs (read-only during simulation phase) */
struct simulation_input
{
	real_vector_type mortality;
	real_vector_type survival;
	real_vector_type yield;
	policy_vector_type inforce;
};

/* Simulation output(s) (mutable during simulation phase) */
struct simulation_output
{
	real_vector_type reserves;
};

/* Boost function object called to execute parallel tasks */
class simulation_tasks
{
public:
	/* Required of function object */
	typedef size_t result_type;

public:
	/* Constructor assigns task count and references to synchronization helper, read-only input and muable output */
	simulation_tasks(size_t count, latch* synchronizer, simulation_input const* input, simulation_output* output) :
		count_(count),
		synchronizer_(synchronizer),
		input_(input),
		output_(output)
	{
		assert(input != NULL);
		assert(output != NULL);
	}

	/* Required of function object (bound to task number in scheduling loop) */
	result_type operator ()(size_t task_number)
	{
		assert(task_number < count_);

		double reserve = 0.0;
		double yield = input().yield[task_number];

		/* Loop over policies */
		for (policy_vector_type::const_iterator policy_iter = input().inforce.begin(); policy_iter != input().inforce.end(); ++policy_iter)
		{
			double compounded_yield = 1.0;
			double deficiency = 0.0;
			double av = 1.0;

			/* Loop over timesteps */
			for (size_t timestep = 0; timestep < TIMESTEP_COUNT; ++timestep)
			{
				double charge = av * policy_iter->av;

				av -= charge;
				av *= yield;

				double benefit = (policy_iter->benefit - av) * input().survival[timestep];

				compounded_yield *= yield;
				double exposure = (benefit - charge) / compounded_yield;

				if (exposure > deficiency)
				{
					deficiency = exposure;
				}
			}

			/* Accumulate total reserves over all policies */
			reserve += deficiency;
		}

		/* Commit reserve for given scenario */
		output().reserves[task_number] = reserve;

		/* Deduct number of outstanding scenario-specific parallel calculations */
		synchronizer_->count_down();

		return task_number;
	}

	/* Convenience accessor */
	simulation_input const& input() const
	{
		return *input_;
	}

	/* Convenience accessor */
	simulation_output& output()
	{
		return *output_;
	}

private:
	size_t count_;
	latch* synchronizer_;
	simulation_input const* input_;
	simulation_output* output_;
};

class profiler_subject
{
protected:
	profiler_subject()
	{
	}

	std::ostream& progress_line(char const* text = NULL)
	{
		std::cerr << "[PROGRESS] ";

		if (text != NULL)
		{
			std::cerr << text;
		}

		return std::cerr;
	}

private:
	/* Helper to load tabular CSV source into 1D vector */
	void load_1d_csv(vector<double>& target, char const* filename)
	{
		boost::numeric::ublas::matrix<double> intermediate;
		load_dense_data(intermediate, filename);

		assert(intermediate.size2() == 1);
		boost::numeric::ublas::matrix_column<boost::numeric::ublas::matrix<double>> slice = boost::numeric::ublas::column(intermediate, 0);

		target.resize(intermediate.size1());
		target.assign(slice.begin(), slice.end());
	}

	/* Helper just for input data */
	void prepare_input(simulation_input& input)
	{
		/* Load vectorized data from disk */
		load_1d_csv(input.mortality, "mortality.csv");
		load_1d_csv(input.yield, "sigma.csv");
		
		input.survival.reserve(std::max(input.mortality.size(), TIMESTEP_COUNT));

		/* Calculate survival by timestep from mortality rates */
		double survival = 1.0;
		for (real_vector_type::const_iterator iter = input.mortality.begin(); iter != input.mortality.end(); ++iter)
		{
			survival *= 1.0 - (*iter);
			/* REVIEW: is application of mortality rate correct? */
			input.survival.push_back(survival * (*iter));
		}

		/* Pad survival for timesteps beyond mortality with zero */
		while (input.survival.size() < TIMESTEP_COUNT)
		{
			input.survival.push_back(0.0);
		}

		/* Adjust returns by 1.0 */
		for (real_vector_type::iterator iter = input.yield.begin(); iter != input.yield.end(); ++iter)
		{
			*iter += 1.0;
		}

		/* Synthesize (invariant) policy data */
		input.inforce.resize(POLICY_COUNT);
		for (policy_vector_type::iterator iter = input.inforce.begin(); iter != input.inforce.end(); ++iter)
		{
			iter->av = 0.02 / 12.0;
			iter->benefit = 1000;
		}
	}

	/* Helper just for output data */
	void prepare_output(simulation_input const& input, simulation_output& output)
	{
		output.reserves.resize(input.yield.size());
	}

protected:
	/* Setup prepares input and output structures for all trials */
	void setup()
	{
		progress_line("preparing data...") << std::endl;

		prepare_input(input_);
		prepare_output(input_, output_);

		progress_line("data preparation complete") << std::endl;
	}

	void begin_sample(int trial)
	{
		progress_line() << "starting trial #" << trial << "..." << std::endl;
	}

	/* Each sample of performance data processes all scenarios, policies and timesteps */
	void sample(int trial)
	{
		size_t scenario_count = output_.reserves.size();

		/* Prepare tasks one-to-one with scenarios */
		latch synchonizer(scenario_count);
		simulation_tasks tasks(scenario_count, &synchonizer, &input_, &output_);

		/* Zero reserves across all scenarios */
		fill(output_.reserves.begin(), output_.reserves.end(), 0.0);

		/* Loop over scenarios */
		for (size_t i = 0; i < scenario_count; ++i)
		{
			/* Schedule each task (all-tasks object bound to a scenario selector (task number) */
			parallelizer_.post(boost::bind(tasks, i));
		}

		/* Sample is not complete until all tasks are complete */
		/* Note the thread pool itsef remains populated for the next trial */
		synchonizer.wait();
	}

	void end_sample(int trial)
	{
#if defined(DEBUG) || defined(DEBUG_) || defined(DUMP_SELECT_SCENARIO_RESERVES)

#if !defined(DEBUG_SCENARIO_SELECTIONS)
	#define DEBUG_SCENARIO_SELECTIONS 0,1,2,499,999
#endif /* !DEBUG_SCENARIO_SELECTIONS */

		size_t selections[] = { DEBUG_SCENARIO_SELECTIONS };		
		for (size_t i = 0; i < sizeof(selections) / sizeof(selections[0]); ++i)
		{
			std::cerr << "[DEBUG] reserve(" << selections[i] << "): " << output_.reserves[selections[i]] << std::endl;
		}

#endif /* DEBUG */

		progress_line() << "completed trial #" << trial << "..." << std::endl;
	}

	void teardown()
	{
		parallelizer_.join();
	}

private:
	parallelization_type parallelizer_;
	simulation_input input_;
	simulation_output output_;
};

int main(int argc, char* argv[])
{
	int result = 0;
	json_output collector;
	argv_collection arguments(argc - 1, argv + 1);
	
	try
	{
		profile_config<argv_collection::const_iterator> config(arguments.begin(), arguments.end());
		profiler<profiler_subject, json_output> metrics(config.get_trial_count(), collector);
		metrics.run();
	}
	catch (std::exception const& e)
	{
		std::cerr << "[ERROR] " << e.what() << std::endl;
		result = 1;
	}
	
	return result;
}
```

"""

# ╔═╡ bb9f644d-90c3-4167-aed3-fd8e55b2f422
md"""

Benchmarking results

$(Resource("https://raw.githubusercontent.com/leeyuntien-milli/LifeMeeting/main/simulation1.png"))

$(Resource("https://raw.githubusercontent.com/leeyuntien-milli/LifeMeeting/main/simulation2.png"))

"""

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

# ╔═╡ f531927b-0cf2-4ad6-aaff-93457d292c5b
md"""

#### Rust Code

```Rust
#![allow(non_snake_case)]
use std::{time::Instant};
use nalgebra_sparse::{CsrMatrix};
use nalgebra::{Matrix, VecStorage, Dyn};
use sparse_sgd::*;

fn sgd_V(x:&CsrMatrix<f64>,
    total_losses:&Vec<f64>,
    cross_terms:Matrix<f64, Dyn, Dyn, VecStorage<f64,Dyn,Dyn>>,
    v:Matrix<f64, Dyn, Dyn, VecStorage<f64,Dyn,Dyn>>,
    dv:Matrix<f64, Dyn, Dyn, VecStorage<f64,Dyn,Dyn>>,
)->Matrix<f64, Dyn, Dyn, VecStorage<f64,Dyn,Dyn>>{

    let k:usize=10 ;
    let learning_rate=0.99;
    let m_r=0.1;
    let m_l=0.1;
    
    let mut V = v.clone();
    let mut delta_V = dv.clone();
    let currV = v.clone();

    //X shape is (1475055,101856)
    let xrows:f64 = x.nrows()  as f64;
    let xcols:usize = x.ncols();
    let x_loss =  (&x.multiply_vec(&total_losses))/xrows;
    
    //A difference from Python script is that we don't divide
    // by xrows here, but instead in the loop further down
    let xxl = &x.multiply_csr(&x).multiply_vec(&total_losses).sumnnz(); 

    let xvxl = x_loss.transpose()*cross_terms;

     for f in 0..k {
        for i in 0..xcols {
            V[(i, f)] -= learning_rate * 
                ((xvxl[(i, f)] - xxl[i]/xrows * V[(i, f)]) + 
                m_r * delta_V[(i, f)] + m_l * V[(i, f)]);
        }
    }

    delta_V = currV - v;
    return delta_V
}
fn main() {
    
    let w =  coo_matrix("coo.json");
    let m1 = w.select(0..w.nrows(),0..11) ;
    let m2 = w.select(0..w.nrows(),12..w.ncols()) ;
    let x = hcat(&m1,&m2);
    let y = w.select(0..w.nrows(), 11..12);
    
    let v1 = read_matrix("v1.json", 101856,10);
    
    let cross_terms = x.clone()*v1;
    
    let yrows = y.nrows();
    
    let mut total_losses = vec![0.0; yrows];

    for k in 0..y.row_indices().len() {
        total_losses[k] = y.values()[k];
    }

    let v = read_matrix("v.json", 101856,10);
    let delta_v = read_matrix("dv.json", 101856,10);

    let before = Instant::now();
    sgd_V(&x, &total_losses, cross_terms,v,delta_v);
    let elapsed = before.elapsed();
    println!("Elapsed time: {:.6?} seconds ({:.2?})", elapsed.as_secs_f32(),elapsed);
    //println!("{:?}",result[(0,0)])
    
}    
```

"""

# ╔═╡ 96a95a8a-4b7b-4b7d-b7e7-3a0c7a9439e6
md"""

#### C++ Code

```Cpp
﻿#if !defined(DEBUG) && !defined(_DEBUG) && !defined(NDEBUG)
#pragma message("Warning: boost will compiled with checks on non-debug build (NDEBUG should be defined but is not)")
#endif

#include <iostream>
#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/matrix_sparse.hpp>

#include "matrix_io.hpp"
#include "matrix_ops.hpp"

#if defined(DEBUG) || defined(_DEBUG) || defined(INCLUDE_MATRIX_DEBUG)
#include "matrix_debug.hpp"
#endif

#include "profile.hpp"
#include "profile_config.hpp"
#include "collector/json.hpp"

using namespace boost;
using namespace boost::numeric::ublas;

class profiler_subject
{
protected:
	typedef double sparse_matrix_double_t;
	typedef coordinate_matrix<sparse_matrix_double_t> sparse_double_matrix_t;
	typedef matrix<sparse_matrix_double_t> dense_double_matrix_t;

protected:
	std::ostream& progress_line(char const* text = NULL)
	{
		std::cerr << "[PROGRESS] ";

		if (text != NULL)
		{
			std::cerr << text;
		}

		return std::cerr;
	}

	template <class MATRIX_TYPE>
	void emit_progress(MATRIX_TYPE const& matrix, char const* name, char const* status = NULL)
	{
		if (status == NULL)
		{
			status = "ready";
		}

		progress_line() << "matrix " << name << " (" << matrix.size1() << ',' << matrix.size2() << ") " << status << "..." << std::endl;
		dump_matrix(matrix, name);
	}

protected:
	static void sgd_V(dense_double_matrix_t& result, sparse_double_matrix_t& x, dense_double_matrix_t& total_losses, dense_double_matrix_t& cross_terms, dense_double_matrix_t& v, dense_double_matrix_t const& dv, int k = 10, double alpha = 0.99, double gamma = 0.1, double lambda = 0.1)
	{
		double x_row_count_reciprocal = 1.0 / static_cast<double>(x.size1());

		coordinate_matrix<sparse_double_matrix_t::value_type> x_loss(x.size2(), x.size1(), x.nnz());
		vector<sparse_double_matrix_t::value_type> xxl(x.size2());

		/* Boost documentation says the vector above will be zero-filled, but Microsoft debug builds violate this expectation (std::allocator issue) */
#if defined(_DEBUG) && defined(_MSC_VER)
		xxl.clear();
#endif /* _DEBUG && _MSC_VER */

		for (sparse_double_matrix_t::iterator1 major = x.begin1(); major != x.end1(); ++major)
		{
			for (sparse_double_matrix_t::iterator2 minor = major.begin(); minor != major.end(); ++minor)
			{
				sparse_double_matrix_t::value_type xelement = *minor;
				sparse_double_matrix_t::value_type loss = xelement * total_losses(minor.index1(), 0);
				x_loss.append_element(minor.index2(), minor.index1(), loss * x_row_count_reciprocal);
				xxl[minor.index2()] += loss * xelement;
			}
		}

		xxl *= x_row_count_reciprocal;

		dense_double_matrix_t xvxl;
		matrix_multiply(x_loss, cross_terms, xvxl);

		dense_double_matrix_t v_modified(v);

		for (size_t f = 0; f < static_cast<size_t>(k); ++f)
		{
			for (size_t i = 0; i < x.size2(); ++i)
			{
				dense_double_matrix_t::value_type& vref(v_modified.at_element(i, f));
				vref -= alpha * ((xvxl(i, f) - xxl[i] * vref) + gamma * dv(i, f) + lambda * vref);
			}
		}

		v_modified *= -1.0;
		v_modified += v;
		result.assign_temporary(v_modified);
	}

	void setup()
	{
		static char const* dense_load_status = "loaded from dense (tabular) datafile";
		static char const* computed_status = "computed";

		progress_line("preparing data...") << std::endl;

		load_cartesian_data(x_, "x_sparse_1.csv", "x_sparse_2.csv");
		emit_progress(x_, "x", "loaded from sparse (coordinate) datafile");

		load_dense_data(y_, "y.csv");
		emit_progress(y_, "y", dense_load_status);
		
		dense_double_matrix_t v;
		load_dense_data(v, "v1.csv");
		emit_progress(v, "v[temp]", dense_load_status);

		matrix_multiply(x_, v, cross_terms_);
		emit_progress(cross_terms_, "cross-terms", computed_status);

		load_dense_data(v_, "v.csv");
		emit_progress(v_, "v", dense_load_status);

		load_dense_data(dv_, "dv.csv");
		emit_progress(dv_, "dv", dense_load_status);
	}

	void begin_sample(int trial)
	{
		progress_line() << "starting trial #" << trial << "..." << std::endl;
	}

	void sample(int trial)
	{
		sgd_V(result_, x_, y_, cross_terms_, v_, dv_);
	}

	void end_sample(int trial)
	{
		emit_progress(result_, "result", "computed");
		progress_line() << "completed trial #" << trial << "..." << std::endl;
	}

	void teardown()
	{
		progress_line("done") << std::endl;
	}

private:
	sparse_double_matrix_t x_;
	dense_double_matrix_t y_;
	dense_double_matrix_t v_;
	dense_double_matrix_t cross_terms_;
	dense_double_matrix_t dv_;
	dense_double_matrix_t result_;
};

int main(int argc, char* argv[])
{
	int result = 0;
	json_output collector;
	argv_collection arguments(argc - 1, argv + 1);
	
	try
	{
		profile_config<argv_collection::const_iterator> config(arguments.begin(), arguments.end());
		profiler<profiler_subject, json_output> metrics(config.get_trial_count(), collector);
		metrics.run();
	}
	catch (std::exception const& e)
	{
		std::cerr << "[ERROR] " << e.what() << std::endl;
		result = 1;
	}
	
	return result;
}
```

"""

# ╔═╡ ba07960a-f377-4de3-bd04-283908c812e4
md"""

Benchmarking results

$(Resource("https://raw.githubusercontent.com/leeyuntien-milli/LifeMeeting/main/sparsesgd1.png"))

$(Resource("https://raw.githubusercontent.com/leeyuntien-milli/LifeMeeting/main/sparsesgd2.png"))

"""

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

- Yields.jl
  - Simple and composable yield curves and calculations.

- ExperienceAnalysis.jl
  - Easy and flexible exposure calculations.

- EconomicScenarioGenerators.jl
  - Create Yields.jl compatible stochastic economic scenarios


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
    yield = Yields.CMT(rates, maturities)
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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ActuaryUtilities = "bdd23359-8b1c-4f88-b89b-d11982a786f4"
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
CondaPkg = "992eb4ea-22a4-4c89-a5bb-47a3300528ab"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
LifeContingencies = "c8f0d631-89cd-4a1f-93d0-7542c3692561"
MortalityTables = "4780e19d-04b9-53dc-86c2-9e9aa59b5a12"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
ProgressLogging = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
PythonCall = "6099a3de-0909-46bc-b1f4-468b9a2dfc0d"
Yields = "d7e99b2f-e7f3-4d9e-9f01-2338fc023ad3"

[compat]
ActuaryUtilities = "~3.12.0"
BenchmarkTools = "~1.3.2"
CondaPkg = "~0.2.18"
DataFrames = "~1.6.0"
LifeContingencies = "~2.3.1"
MortalityTables = "~2.5.0"
PlutoUI = "~0.7.51"
ProgressLogging = "~0.1.4"
PythonCall = "~0.9.13"
Yields = "~3.5.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.2"
manifest_format = "2.0"
project_hash = "387436577b4fe50d7a924f0bbc2fe72c715063fa"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ActuaryUtilities]]
deps = ["Dates", "Distributions", "FinanceCore", "ForwardDiff", "MuladdMacro", "PrecompileTools", "QuadGK", "Reexport", "StatsBase", "Yields"]
git-tree-sha1 = "03b31ca6d3a7e1f720b43ce5c776bf2f8dbfcf01"
uuid = "bdd23359-8b1c-4f88-b89b-d11982a786f4"
version = "3.12.0"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "76289dc51920fdc6e0013c872ba9551d54961c24"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.6.2"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.ArgCheck]]
git-tree-sha1 = "a3a402a35a2f7e0b87828ccabbd5ebfbebe356b4"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.3.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra", "Requires", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "f83ec24f76d4c8f525099b2ac475fc098138ec31"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.4.11"

    [deps.ArrayInterface.extensions]
    ArrayInterfaceBandedMatricesExt = "BandedMatrices"
    ArrayInterfaceBlockBandedMatricesExt = "BlockBandedMatrices"
    ArrayInterfaceCUDAExt = "CUDA"
    ArrayInterfaceGPUArraysCoreExt = "GPUArraysCore"
    ArrayInterfaceStaticArraysCoreExt = "StaticArraysCore"
    ArrayInterfaceTrackerExt = "Tracker"

    [deps.ArrayInterface.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"

[[deps.ArrayInterfaceCore]]
deps = ["LinearAlgebra", "SnoopPrecompile", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "e5f08b5689b1aad068e01751889f2f615c7db36d"
uuid = "30b0a656-2188-435a-8636-2ec0e6a096e2"
version = "0.1.29"

[[deps.ArrayLayouts]]
deps = ["FillArrays", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "4aff5fa660eb95c2e0deb6bcdabe4d9a96bc4667"
uuid = "4c555306-a7a7-4459-81d9-ec55ddd5c99a"
version = "0.8.18"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.BSplineKit]]
deps = ["ArrayLayouts", "BandedMatrices", "FastGaussQuadrature", "Interpolations", "LazyArrays", "LinearAlgebra", "Random", "Reexport", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "651e79138b30580c5a1586b67c3298be6c7b8afe"
uuid = "093aae92-e908-43d7-9660-e50ee39d5a0a"
version = "0.8.4"

[[deps.BandedMatrices]]
deps = ["ArrayLayouts", "FillArrays", "LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "019aa88766e2493c59cbd0a9955e1bac683ffbcd"
uuid = "aae01518-5342-5314-be14-df237901396f"
version = "0.16.13"

[[deps.BangBang]]
deps = ["Compat", "ConstructionBase", "InitialValues", "LinearAlgebra", "Requires", "Setfield", "Tables"]
git-tree-sha1 = "e28912ce94077686443433c2800104b061a827ed"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.3.39"

    [deps.BangBang.extensions]
    BangBangChainRulesCoreExt = "ChainRulesCore"
    BangBangDataFramesExt = "DataFrames"
    BangBangStaticArraysExt = "StaticArrays"
    BangBangStructArraysExt = "StructArrays"
    BangBangTypedTablesExt = "TypedTables"

    [deps.BangBang.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    TypedTables = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Baselet]]
git-tree-sha1 = "aebf55e6d7795e02ca500a689d326ac979aaf89e"
uuid = "9718e550-a3fa-408a-8086-8db961cd8217"
version = "0.1.1"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.BitTwiddlingConvenienceFunctions]]
deps = ["Static"]
git-tree-sha1 = "0c5f81f47bbbcf4aea7b2959135713459170798b"
uuid = "62783981-4cbd-42fc-bca8-16325de8dc4b"
version = "0.1.5"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.CPUSummary]]
deps = ["CpuId", "IfElse", "PrecompileTools", "Static"]
git-tree-sha1 = "89e0654ed8c7aebad6d5ad235d6242c2d737a928"
uuid = "2a0fbf3d-bb9c-48f3-b0a9-814d99fd7ab9"
version = "0.2.3"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e30f2f4e20f7f186dc36529910beaedc60cfa644"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.16.0"

[[deps.CloseOpenIntervals]]
deps = ["Static", "StaticArrayInterface"]
git-tree-sha1 = "70232f82ffaab9dc52585e0dd043b5e0c6b714f1"
uuid = "fb6a15b2-703c-40df-9091-08a04967cfa9"
version = "0.1.12"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.CommonSolve]]
git-tree-sha1 = "0eee5eb66b1cf62cd6ad1b460238e60e4b09400c"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.4"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "4e88377ae7ebeaf29a047aa1ee40826e0b708a5d"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.7.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

    [deps.CompositionsBase.weakdeps]
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.CondaPkg]]
deps = ["JSON3", "Markdown", "MicroMamba", "Pidfile", "Pkg", "TOML"]
git-tree-sha1 = "741146cf2ced5859faae76a84b541aa9af1a78bb"
uuid = "992eb4ea-22a4-4c89-a5bb-47a3300528ab"
version = "0.2.18"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "738fec4d684a9a6ee9598a8bfee305b26831f28c"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.2"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[deps.CpuId]]
deps = ["Markdown"]
git-tree-sha1 = "fcbb72b032692610bfbdb15018ac16a36cf2e406"
uuid = "adafc99b-e345-5852-983c-f28acb93d879"
version = "0.3.1"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "089d29c0fc00a190661517e4f3cba5dcb3fd0c08"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "cf25ccb972fec4e4817764d01c82386ae94f77b4"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.14"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DefineSingletons]]
git-tree-sha1 = "0fba8b706d0178b4dc7fd44a96a92382c9065c2c"
uuid = "244e2a9f-e319-4986-a169-4d1fe445cd52"
version = "0.1.2"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "49eba9ad9f7ead780bfb7ee319f962c811c6d3b2"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.8"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "e76a3281de2719d7c81ed62c6ea7057380c87b1d"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.98"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.Extents]]
git-tree-sha1 = "5e1e4c53fa39afe63a7d356e30452249365fba99"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.1"

[[deps.EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "0fa3b52a04a4e210aeb1626def9c90df3ae65268"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.1.0"

[[deps.FastGaussQuadrature]]
deps = ["LinearAlgebra", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "58d83dd5a78a36205bdfddb82b1bb67682e64487"
uuid = "442a2c76-b920-505d-bb47-c5924d526838"
version = "0.4.9"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "299dc33549f68299137e51e6d49a13b5b1da9673"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "7072f1e3e5a8be51d525d64f63d3ec1287ff2790"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.11"

[[deps.FinanceCore]]
deps = ["LoopVectorization", "Roots"]
git-tree-sha1 = "9692262f7a2895bd97e1457937be67f25094e7a0"
uuid = "b9b1ffdd-6612-4b69-8227-7663be06e089"
version = "1.1.0"

[[deps.FiniteDiff]]
deps = ["ArrayInterface", "LinearAlgebra", "Requires", "Setfield", "SparseArrays"]
git-tree-sha1 = "c6e4a1fbe73b31a3dea94b1da449503b8830c306"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.21.1"

    [deps.FiniteDiff.extensions]
    FiniteDiffBandedMatricesExt = "BandedMatrices"
    FiniteDiffBlockBandedMatricesExt = "BlockBandedMatrices"
    FiniteDiffStaticArraysExt = "StaticArrays"

    [deps.FiniteDiff.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "00e252f4d706b3d55a8863432e742bf5717b498d"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.35"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "cabd77ab6a6fdff49bfd24af2ebe76e6e018a2b4"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.0.0"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics"]
git-tree-sha1 = "b5c7fe9cea653443736d264b85466bad8c574f4a"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.9.9"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "2d6ca471a6c7b536127afccfa7564b5b39227fe0"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.5"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "bb198ff907228523f3dee1070ceee63b9359b6ab"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.3.1"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "659140c9375afa2f685e37c1a0b9c9a60ef56b40"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.7"

[[deps.HostCPUFeatures]]
deps = ["BitTwiddlingConvenienceFunctions", "IfElse", "Libdl", "Static"]
git-tree-sha1 = "d38bd0d9759e3c6cfa19bdccc314eccf8ce596cc"
uuid = "3e5b6fbb-0976-4d2c-9146-d79de83f2fb0"
version = "0.1.15"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "83e95aaab9dc184a6dcd9c4c52aa0dc26cd14a1d"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.21"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[deps.InitialValues]]
git-tree-sha1 = "4da0f88e9a39111c2fa3add390ab15f3a44f3ca3"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.3.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "b7bc05649af456efc75d178846f47006c2c4c3c7"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.6"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IterTools]]
git-tree-sha1 = "4ced6667f9974fc5c5943fa5e2ef1ca43ea9e450"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.8.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "5b62d93f2582b09e469b3099d839c2d2ebf5066d"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.13.1"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LayoutPointers]]
deps = ["ArrayInterface", "LinearAlgebra", "ManualMemory", "SIMDTypes", "Static", "StaticArrayInterface"]
git-tree-sha1 = "88b8f66b604da079a627b6fb2860d3704a6729a1"
uuid = "10f19ff3-798f-405d-979b-55457f8fc047"
version = "0.1.14"

[[deps.LazyArrays]]
deps = ["ArrayLayouts", "FillArrays", "LinearAlgebra", "MacroTools", "MatrixFactorizations", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "7402f6be1a28a05516c6881596879e6d18d28039"
uuid = "5078a376-72f3-5289-bfd5-ec5146d43c02"
version = "0.22.18"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.LifeContingencies]]
deps = ["ActuaryUtilities", "Dates", "MortalityTables", "Transducers", "Yields"]
git-tree-sha1 = "1f23243b8143a69c1acff6f7c1818fabfb269a15"
uuid = "c8f0d631-89cd-4a1f-93d0-7542c3692561"
version = "2.3.1"

[[deps.LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "Printf"]
git-tree-sha1 = "7bbea35cec17305fc70a0e5b4641477dc0789d9d"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.2.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "c3ce8e7420b3a6e071e0fe4745f5d4300e37b13f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.24"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoopVectorization]]
deps = ["ArrayInterface", "ArrayInterfaceCore", "CPUSummary", "CloseOpenIntervals", "DocStringExtensions", "HostCPUFeatures", "IfElse", "LayoutPointers", "LinearAlgebra", "OffsetArrays", "PolyesterWeave", "PrecompileTools", "SIMDTypes", "SLEEFPirates", "Static", "StaticArrayInterface", "ThreadingUtilities", "UnPack", "VectorizationBase"]
git-tree-sha1 = "24e6c5697a6c93b5e10af2acf95f0b2e15303332"
uuid = "bdcacae8-1622-11e9-2a5c-532679323890"
version = "0.12.163"
weakdeps = ["ChainRulesCore", "ForwardDiff", "SpecialFunctions"]

    [deps.LoopVectorization.extensions]
    ForwardDiffExt = ["ChainRulesCore", "ForwardDiff"]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.LsqFit]]
deps = ["Distributions", "ForwardDiff", "LinearAlgebra", "NLSolversBase", "OptimBase", "Random", "StatsBase"]
git-tree-sha1 = "91aa1442e63a77f101aff01dec5a821a17f43922"
uuid = "2fda8390-95c7-5789-9bda-21331edee243"
version = "0.12.1"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.ManualMemory]]
git-tree-sha1 = "bcaef4fc7a0cfe2cba636d84cda54b5e4e4ca3cd"
uuid = "d125e4d3-2237-4719-b19c-fa641b8a4667"
version = "0.1.8"

[[deps.MarchingCubes]]
deps = ["PrecompileTools", "StaticArrays"]
git-tree-sha1 = "c8e29e2bacb98c9b6f10445227a8b0402f2f173a"
uuid = "299715c1-40a9-479a-aaf9-4a633d36f717"
version = "0.1.8"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MatrixFactorizations]]
deps = ["ArrayLayouts", "LinearAlgebra", "Printf", "Random"]
git-tree-sha1 = "0ff59b4b9024ab9a736db1ad902d2b1b48441c19"
uuid = "a3b82374-2e81-5b9e-98ce-41277c0e4c87"
version = "0.9.6"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Memoize]]
deps = ["MacroTools"]
git-tree-sha1 = "2b1dfcba103de714d31c033b5dacc2e4a12c7caa"
uuid = "c03570c3-d221-55d1-a50c-7939bbd78826"
version = "0.4.4"

[[deps.MicroCollections]]
deps = ["BangBang", "InitialValues", "Setfield"]
git-tree-sha1 = "629afd7d10dbc6935ec59b32daeb33bc4460a42e"
uuid = "128add7d-3638-4c79-886c-908ea0c25c34"
version = "0.1.4"

[[deps.MicroMamba]]
deps = ["Pkg", "Scratch", "micromamba_jll"]
git-tree-sha1 = "6f0e43750a94574c18933e9456b18d4d94a4a671"
uuid = "0b3b1443-0f03-428d-bdfb-f27f9c1191ea"
version = "0.1.13"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MortalityTables]]
deps = ["Memoize", "OffsetArrays", "Parsers", "Pkg", "QuadGK", "Requires", "StringDistances", "UnPack", "XMLDict"]
git-tree-sha1 = "ca3a8be338a505aa19e8c9d3c0fe5f4c903779c1"
uuid = "4780e19d-04b9-53dc-86c2-9e9aa59b5a12"
version = "2.5.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.MuladdMacro]]
git-tree-sha1 = "cac9cc5499c25554cba55cd3c30543cff5ca4fab"
uuid = "46d2c3a1-f734-5fdb-9937-b9b9aeba4221"
version = "0.2.4"

[[deps.NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "a0b464d183da839699f4c79e7606d9d186ec172c"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.3"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "2ac17d29c523ce1cd38e27785a7d23024853a4bb"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.10"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Optim]]
deps = ["Compat", "FillArrays", "ForwardDiff", "LineSearches", "LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "PositiveFactorizations", "Printf", "SparseArrays", "StatsBase"]
git-tree-sha1 = "e3a6546c1577bfd701771b477b794a52949e7594"
uuid = "429524aa-4258-5aef-a3af-852621145aeb"
version = "1.7.6"

[[deps.OptimBase]]
deps = ["NLSolversBase", "Printf", "Reexport"]
git-tree-sha1 = "9cb1fee807b599b5f803809e85c81b582d2009d6"
uuid = "87e2bd06-a317-5318-96d9-3ecbac512eee"
version = "2.0.2"

[[deps.OrderedCollections]]
git-tree-sha1 = "d321bf2de576bf25ec4d3e4360faca399afca282"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "67eae2738d63117a196f497d7db789821bce61d1"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.17"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "4b2e829ee66d4218e0cef22c0a64ee37cf258c29"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.1"

[[deps.Pidfile]]
deps = ["FileWatching", "Test"]
git-tree-sha1 = "2d8aaf8ee10df53d0dfb9b8ee44ae7c04ced2b03"
uuid = "fa939f87-e72e-5be4-a000-7fc836dbe307"
version = "1.3.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "b478a748be27bd2f2c73a7690da219d0844db305"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.51"

[[deps.PolyesterWeave]]
deps = ["BitTwiddlingConvenienceFunctions", "CPUSummary", "IfElse", "Static", "ThreadingUtilities"]
git-tree-sha1 = "240d7170f5ffdb285f9427b92333c3463bf65bf6"
uuid = "1d0040c9-8b98-4ee7-8388-3f51789ca0ad"
version = "0.2.1"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.PositiveFactorizations]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "17275485f373e6673f7e7f97051f703ed5b15b20"
uuid = "85a6dd25-e78a-55b7-8502-1745935b8125"
version = "0.2.4"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "9673d39decc5feece56ef3940e5dafba15ba0f81"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.1.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "331cc8048cba270591eab381e7aa3e2e3fef7f5e"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.5"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.ProgressLogging]]
deps = ["Logging", "SHA", "UUIDs"]
git-tree-sha1 = "80d919dee55b9c50e8d9e2da5eeafff3fe58b539"
uuid = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
version = "0.1.4"

[[deps.PythonCall]]
deps = ["CondaPkg", "Dates", "Libdl", "MacroTools", "Markdown", "Pkg", "REPL", "Requires", "Serialization", "Tables", "UnsafePointers"]
git-tree-sha1 = "0d15cb32f52654921169b4305dae8f66a0e345dc"
uuid = "6099a3de-0909-46bc-b1f4-468b9a2dfc0d"
version = "0.9.13"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "6ec7ac8412e83d57e313393220879ede1740f9ee"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.8.2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "f65dcb5fa46aee0cf9ed6274ccbd597adc49aa7b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.1"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6ed52fdd3382cf21947b15e8870ac0ddbff736da"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.4.0+0"

[[deps.Roots]]
deps = ["CommonSolve", "Printf"]
git-tree-sha1 = "06ba8114bf7fc4fd1688e2e4d2259d2000535985"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "1.2.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMDTypes]]
git-tree-sha1 = "330289636fb8107c5f32088d2741e9fd7a061a5c"
uuid = "94e857df-77ce-4151-89e5-788b33177be4"
version = "0.1.0"

[[deps.SLEEFPirates]]
deps = ["IfElse", "Static", "VectorizationBase"]
git-tree-sha1 = "4b8586aece42bee682399c4c4aee95446aa5cd19"
uuid = "476501e8-09a2-5ece-8869-fb82de89a1fa"
version = "0.6.39"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "30449ee12237627992a99d5e30ae63e4d78cd24a"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "04bdff0b09c65ff3e06a05e3eb7b120223da3d39"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "c60ec5c62180f27efea3ba2908480f8055e17cee"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "7beb031cf8145577fbccacd94b8a8f4ce78428d3"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.0"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "e08a62abc517eb79667d0a29dc08a3b589516bb5"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.15"

[[deps.Static]]
deps = ["IfElse"]
git-tree-sha1 = "dbde6766fc677423598138a5951269432b0fcc90"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.8.7"

[[deps.StaticArrayInterface]]
deps = ["ArrayInterface", "Compat", "IfElse", "LinearAlgebra", "Requires", "SnoopPrecompile", "SparseArrays", "Static", "SuiteSparse"]
git-tree-sha1 = "33040351d2403b84afce74dae2e22d3f5b18edcb"
uuid = "0d7ed370-da01-4f52-bd93-41d350b8b718"
version = "1.4.0"
weakdeps = ["OffsetArrays", "StaticArrays"]

    [deps.StaticArrayInterface.extensions]
    StaticArrayInterfaceOffsetArraysExt = "OffsetArrays"
    StaticArrayInterfaceStaticArraysExt = "StaticArrays"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore"]
git-tree-sha1 = "fffc14c695c17bfdbfa92a2a01836cdc542a1e46"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.6.1"
weakdeps = ["Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "1d5708d926c76a505052d0d24a846d5da08bc3a4"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.1"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "45a7769a04a3cf80da1c1c7c60caf932e6f4c9f7"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.6.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "f625d686d5a88bcd2b15cd81f18f98186fdc0c9a"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.0"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.StringDistances]]
deps = ["Distances", "StatsAPI"]
git-tree-sha1 = "ceeef74797d961aee825aabf71446d6aba898acb"
uuid = "88034a9c-02f8-509d-84a9-84ec65e18404"
version = "0.11.2"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "GPUArraysCore", "StaticArraysCore", "Tables"]
git-tree-sha1 = "521a0e828e98bb69042fec1809c1b5a680eb7389"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.15"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.ThreadingUtilities]]
deps = ["ManualMemory"]
git-tree-sha1 = "eda08f7e9818eb53661b3deb74e3159460dfbc27"
uuid = "8290d209-cae3-49c0-8002-c8c24d57dab5"
version = "0.5.2"

[[deps.Transducers]]
deps = ["Adapt", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "Setfield", "SplittablesBase", "Tables"]
git-tree-sha1 = "a66fb81baec325cf6ccafa243af573b031e87b00"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.77"

    [deps.Transducers.extensions]
    TransducersBlockArraysExt = "BlockArrays"
    TransducersDataFramesExt = "DataFrames"
    TransducersLazyArraysExt = "LazyArrays"
    TransducersOnlineStatsBaseExt = "OnlineStatsBase"
    TransducersReferenceablesExt = "Referenceables"

    [deps.Transducers.weakdeps]
    BlockArrays = "8e7c35d0-a365-5155-bbbb-fb81a777f24e"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    LazyArrays = "5078a376-72f3-5289-bfd5-ec5146d43c02"
    OnlineStatsBase = "925886fa-5bf2-5e8e-b522-a9147a512338"
    Referenceables = "42d2dcc6-99eb-4e98-b66c-637b7d73030e"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodePlots]]
deps = ["ColorTypes", "Contour", "Crayons", "Dates", "FileIO", "FreeTypeAbstraction", "LazyModules", "LinearAlgebra", "MarchingCubes", "NaNMath", "Printf", "SparseArrays", "StaticArrays", "StatsBase", "Unitful"]
git-tree-sha1 = "ae67ab0505b9453655f7d5ea65183a1cd1b3cfa0"
uuid = "b8865327-cd53-5732-bb35-84acbb429228"
version = "2.12.4"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "c4d2a349259c8eba66a00a540d550f122a3ab228"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.15.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.UnsafePointers]]
git-tree-sha1 = "c81331b3b2e60a982be57c046ec91f599ede674a"
uuid = "e17b2a0c-0bdf-430a-bd0c-3a23cae4ff39"
version = "1.0.0"

[[deps.VectorizationBase]]
deps = ["ArrayInterface", "CPUSummary", "HostCPUFeatures", "IfElse", "LayoutPointers", "Libdl", "LinearAlgebra", "SIMDTypes", "Static", "StaticArrayInterface"]
git-tree-sha1 = "b182207d4af54ac64cbc71797765068fdeff475d"
uuid = "3d5dd08c-fd9d-11e8-17fa-ed2836048c2f"
version = "0.21.64"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[deps.XMLDict]]
deps = ["EzXML", "IterTools", "OrderedCollections"]
git-tree-sha1 = "d9a3faf078210e477b291c79117676fca54da9dd"
uuid = "228000da-037f-5747-90a9-8195ccbf91a5"
version = "0.4.1"

[[deps.Yields]]
deps = ["BSplineKit", "FinanceCore", "ForwardDiff", "LinearAlgebra", "LsqFit", "Optim", "PrecompileTools", "Reexport", "Roots", "UnicodePlots"]
git-tree-sha1 = "a421322c1d9539b6d5288ae959e586ed865e0b92"
uuid = "d7e99b2f-e7f3-4d9e-9f01-2338fc023ad3"
version = "3.5.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.micromamba_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "087555b0405ed6adf526cef22b6931606b5af8ac"
uuid = "f8abcde7-e9b7-5caa-b8af-a437887ae8e4"
version = "1.4.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
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
# ╟─8b7ceb12-548c-49e0-af3a-6bb101a581e6
# ╟─75338a1c-9684-4bf7-9952-cdeaf315e15b
# ╟─675e95d9-2d12-4324-9418-a12de6e8c082
# ╟─cceb9793-c1fc-437d-8b76-e613da8212b6
# ╟─b4fa8e12-1a5a-4b57-970d-b8c877233c25
# ╟─00570477-26d7-4030-9ae9-3baaf0cef8a9
# ╟─8da63366-88ea-48c1-a696-0a3442793232
# ╟─534286c2-5f08-41b9-adac-29ecd2d71316
# ╟─bb9f644d-90c3-4167-aed3-fd8e55b2f422
# ╟─a9c284b4-c851-46f1-b7d2-aa70456ab7d8
# ╟─753cff1f-0648-43f4-9aaf-56dc4686cd3d
# ╟─22270d64-5a92-4677-8d91-c4f5644e6bd3
# ╟─f531927b-0cf2-4ad6-aaff-93457d292c5b
# ╟─96a95a8a-4b7b-4b7d-b7e7-3a0c7a9439e6
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
# ╠═3b3c4951-7c85-41b1-9f5b-1a23f4b4c465
# ╟─f1675cb1-ece0-4a5f-a0eb-7fd16010461c
# ╠═8320edcc-ef78-11ec-0445-b100a477c027
# ╠═1e3e432b-3027-4dfe-992c-14189f675181
# ╟─25e6509e-80ae-4946-bc67-cfa42fe1beef
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
