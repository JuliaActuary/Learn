using BenchmarkTools
using DelimitedFiles

q = [0.001,0.002,0.003,0.003,0.004,0.004,0.005,0.007,0.009,0.011]
w = [0.05,0.07,0.08,0.10,0.14,0.20,0.20,0.20,0.10,0.04]
P = 100
S = 25000
r = 0.02

function npv1(q,w,P,S,r) 
	inforce = [1.; cumprod(1 .- q .- w)[1:end-1]] 
  	ncf = inforce .* P .- inforce .* q .* S
 	d = (1 ./ (1 + r)) .^ (1:length(ncf))
  	return sum(ncf .* d)
end

function npv2(q,w,P,S,r) 
	inforce = append!([1.0],@view cumprod(1 .- q .- w)[1:end-1])
  	ncf = inforce .* P .- inforce .* q .* S
 	d = (1 ./ (1 + r)) .^ (1:length(ncf))
  	return sum(ncf .* d)
end

@inline function npv3(q,w,P,S,r,term=nothing)
    term = term === nothing ? length(q) + 1 : term + 1
    inforce = 1.0
    result = 0.0
    v = (1 / ( 1 + r))
    v_t = v
    
    for (t,(q,w)) in enumerate(zip(q,w))
        deaths = t < term ? inforce * q : 0.0
        lapses = t < term ? inforce * w : 0.0
        premiums = inforce * P
        claims = deaths * S
        ncf = premiums - claims
        result += ncf *  v_t
        v_t *= v
        inforce = inforce - deaths - lapses
    end
    
    return result
end

@inline function npv4(q,w,P,S,r,term=nothing)
    term = term === nothing ? length(q) : term
    inforce = 1.0
    result = 0.0
    v = (1 / ( 1 + r))
    v_t = v
    
    for (t,(q,w)) in enumerate(zip(q,w))
        t > term && return result
        result += inforce * (P - S * q) * v_t
        inforce -= inforce * q + inforce * w
        v_t *= v
    end
    
    return result
end

# suggested by Stefan Karpinski
@inline function npv5(q,w,P,S,r,term=nothing)
    term = term === nothing ? length(q) : term
    inforce = 1.0
    result = 0.0
    v = (1 / ( 1 + r))
    v_t = v
    for (q,w,_) in zip(q,w,1:term)
        result += inforce * (P - S * q) * v_t
        inforce -= inforce * q + inforce * w
        v_t *= v
    end
    return result
end

# suggested by Michael Abbott
@inline function npv6(qs,ws,P,S,r,term=length(qs))
    inforce, result = 1.0, 0.0
    v = 1 / ( 1 + r)
    v_t = v

    for t in 1:min(term, length(qs), length(ws))
        @inbounds q, w = qs[t], ws[t]
        result += inforce * (P - S * q) * v_t
        inforce -= inforce * (q + w)
        v_t *= v
    end

    return result
end

# suggested by Peter J
@inline function npv7(qs,ws,P,S,r,term=length(qs))
    inforce, result = 1.0, 0.0
    v = 1 / ( 1 + r)
    v_t = v

    for t in 1:min(term, length(qs), length(ws))
        @inbounds q, w = qs[t], ws[t]
        result += inforce * (P - S * q) * v_t
        inforce = inforce*(1 - (q + w))
        v_t *= v
    end

    return result
end

# suggested by Peter J
@inline function npv8(qs,ws,P,S,r,term=length(qs))
    inforce, result = 1.0, 0.0
    v = 1 / ( 1 + r)
    v_t = v
    @inbounds @simd for t in 1:min(term, length(qs), length(ws))
        q, w = qs[t], ws[t]
        result += inforce * (P - S * q) * v_t
        inforce = inforce*(1 - (q + w))
        v_t *= v
    end
    return result
end

# suggested by Michael Abbott
@inline function npv9(qs,ws,P,S,r,term=length(qs))
    inforce, result = 1.0, 0.0
    v = 1 / ( 1 + r)
    v_t = v
    @inbounds @fastmath for t in 1:min(term, length(qs), length(ws))
        q, w = qs[t], ws[t]
        result += inforce * (P - S * q) * v_t
        inforce = inforce*(1 - (q + w))
        v_t *= v
    end
    return result
end

results = map([npv1,npv2,npv3,npv4,npv5,npv6,npv7,npv8,npv9]) do f
    b = @benchmark $f($q,$w,$P,$S,$r)
    (f="$f",mean=mean(b),median=median(b))
end


writedlm("julia_results.csv",results, ',')
