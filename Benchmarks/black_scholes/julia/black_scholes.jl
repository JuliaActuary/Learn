using BenchmarkTools
using Distributions

function d1(S,K,τ,r,σ)
	(log(S/K) + (r + σ^2/2) * τ) / (σ * √(τ))
end

function d2(S,K,τ,r,σ)
	d1(S,K,τ,r,σ) - σ * √(τ)
end

function Call(S,K,τ,r,σ)
	N(x) = cdf(Normal(),x)
	d₁ = d1(S,K,τ,r,σ)
	d₂ = d2(S,K,τ,r,σ)
	return N(d₁)*S - N(d₂) * K * exp(-r*τ)
	
end

S = 300
K = 250
τ = 1
σ = 0.15
r = 0.03

# check that result is as expected 
@assert Call(S,K,τ,r,σ) ≈ 58.81976813699322

b = @benchmark Call($S,$K,$τ,$r,$σ)

@show b