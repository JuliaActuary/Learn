
import timeit

setup='''
import numpy as np
from numba import njit

q = np.array([0.001, 0.002, 0.003, 0.003, 0.004, 0.004, 0.005, 0.007, 0.009, 0.011])
w = np.array([0.05, 0.07, 0.08, 0.10, 0.14, 0.20, 0.20, 0.20, 0.10, 0.04])
P = 100
S = 25000
r = 0.02


# Numpy Vectorized, via Houstonwp
def npv_vec(q, w, P, S, r):
    decrements = np.cumprod(1-q-w)
    inforce = np.empty_like(decrements)
    inforce[:1] = 1
    inforce[1:] = decrements[:-1]
    ncf = inforce * P - inforce * q * S
    t = np.arange(1, np.size(q)+1)
    d = np.power(1/(1+r), t)
    return np.sum(ncf * d)


# Python Accumulator, via Houstonwp
def npv_loop(q, w, P, S, r):
    inforce = 1.0
    result = 0.0
    v = 1 / (1 + r)
    v_t = v
    for t in range(0, len(q)):
        result = result + inforce * (P-S*q[t]) * v_t
        inforce = inforce * (1 - (q[t] + w[t]))
        v_t = v_t * v
    return result


# Numba Accumulator
@njit
def npv_numba(q, w, P, S, r):
    inforce = 1.0
    result = 0.0
    v = 1 / (1 + r)
    v_t = v
    for t in range(0, len(q)):
        result = result + inforce * (P-S*q[t]) * v_t
        inforce = inforce * (1 - (q[t] + w[t]))
        v_t = v_t * v
    return result
'''

benchmark_vec = '''npv_vec(q, w, P, S, r)'''
benchmark_loop = '''npv_loop(q, w, P, S, r)'''
benchmark_numba = '''npv_numba(q, w, P, S, r)'''

bm_res_vec = timeit.timeit(stmt=benchmark_vec, setup=setup, number=1000000)
print(f"Numpy Vectorized: {bm_res_vec:0.3f} μs")

bm_res_loop = timeit.timeit(stmt=benchmark_loop, setup=setup, number=1000000)
print(f"Python Accumulator: {bm_res_loop:0.3f} μs")

bm_res_numba = timeit.timeit(stmt=benchmark_numba, setup=setup, number=1000000)
print(f"Numba Accumulator: {bm_res_numba:0.3f} μs")
