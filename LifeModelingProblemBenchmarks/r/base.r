# via Houstonwp
q <- c(0.001,0.002,0.003,0.003,0.004,0.004,0.005,0.007,0.009,0.011)
w <- c(0.05,0.07,0.08,0.10,0.14,0.20,0.20,0.20,0.10,0.04)
P <- 100
S <- 25000
r <- 0.02

base_r_npv <- function(q,w,P,S,r) {
  inforce <- c(1,head(cumprod(1-q-w), -1))
  ncf <- inforce * P - inforce * q * S
  d <- (1/(1+r)) ^ seq_along(ncf)
  sum(ncf * d)
}

base_r_npv(q,w,P,S,r)
#> [1] 50.32483
microbenchmark::microbenchmark(base_r_npv(q,w,P,S,r))

npv_loop <- function(q,w,P,S,r) {
        inforce = 1.0
        result = 0.0
        v = 1 / (1 + r)
        v_t = v
    for (t in 1:length(q)) {
        result <- result + inforce * (P-S*q[t-1]) * v_t
        inforce <- inforce * (1 - (q[t-1] + w[t-1]))
        v_t = v_t * v
    }
    result
}
microbenchmark::microbenchmark(npv_loop(q,w,P,S,r))