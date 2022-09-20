using Tullio
using MortalityTables
using Random

# Background:
# "Einstein summation notation" is in Numpy via np.einsum, and Julia with Tullio.jl
# For example, we can multiply two matrices:
a = rand(10, 20)
b = rand(20, 30)
@tullio c[i, j] := a[i, k] * b[k, j]

# It might be simpler to just multiply them directly:
c = a * b

# Sometimes we also want to reduce over a dimension, einsum is good at this
@tullio d[i] := a[i, k] * b[k, j]

# Also helpful for managing the dimensions of the result
@tullio d[1, i, 1] := a[i, k] * b[k, j]

# You can avoid learning about all sorts of stuff by using Tullio
b_transpose = permutedims(b, (2, 1))
b_transpose = b'
@tullio b_transpose[i, j] := b[j, i]

# Reshaping tensors is also easy
@tullio reshaped_a[1, i, j] := a[i, j] # arr[None, :, :] in NumPy
# More discussion of the comparison to NumPy reshaping is here - 
# https://discourse.julialang.org/t/cumbersome-array-reshaping-for-broadcasting-unlike-numpy/21566/20

# Now, actuarial applications. 
# Many of these quantities can be computed without creating arrays, saving memory and time.
# But by creating the arrays, we get to use einsum, which is nice, especially for interactive work.

### Setting up model points and assumptions ###
tbls = [MortalityTables.table(i) for i in 3299:3308]
issue_ages = 18:50
durations = 1:25
timesteps = 0:29
q = [
    tbl.select[issue_age][issue_age+(duration-1)+timestep]
    for (tbl, issue_age, duration) in vec(collect(Iterators.product(tbls, issue_ages, durations))), timestep in timesteps
]
face = rand(MersenneTwister(0), (25, 100, 250, 500), size(q, 1)) .* 1000 # "face amounts"
#######################

# Matrix of survival probabilities with shape (policies, timesteps)
# I don't think Tullio can do cumulative operations
npx = [ones(size(q, 1)) cumprod(1 .- q[:, begin:end-1], dims=2)]

# Calculate unit benefits in Tullio
@tullio A[i, j] := npx[i, j] * q[i, j]

# Because everything broadcasts easily, Tullio might be overkill
A ≈ npx .* q

# We can do reductions, like how many policies will die in each year?
@tullio expected_yearly_deaths[t] := A[p, t]

# The shape from Base.sum remains broadcastable with original dimensions, unlike Tullio.
size(sum(A, dims=1)) == (1, 30)
# We don't care as much about broadcastability, because we are using Tullio.
size(expected_yearly_deaths) == (30,)
# But if we did care, it is no issue
size(@tullio broadcastable_yearly_deaths[1, t] := A[p, t]) == (1, 30)

# What is the probability of each policy dying during the contract?
@tullio p_death[p] := A[p, t]

# Some identity
p_death ≈ sum(A, dims=2) ≈ 1 .- prod(1 .- q, dims=2)

# Multiply unit benefits by face amounts
@tullio FA[p, t] := face[p] * A[p, t]

# This is broadcastable, maybe it is easier, but I enjoy the explicitness of Tullio
FA ≈ face .* A

# discount rate
v = 1 / (1 + 0.02)

# Present value of future benefits
@tullio expected_pv_benefits := FA[p, t] * v .^ t

# Let's try with multiple interest rates
vs = 1 ./ (1 .+ collect(0.01:0.1:0.5))

# Present value of future benefits for multiple interest rates
@tullio expected_pv_benefits_by_scenario[s] := FA[p, t] * vs[s] .^ t