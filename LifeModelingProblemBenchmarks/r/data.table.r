# via Houstonwp
library(data.table)

q <- c(0.001,
       0.002,
       0.003,
       0.003,
       0.004,
       0.004,
       0.005,
       0.007,
       0.009,
       0.011)

w <- c(0.05,
       0.07,
       0.08,
       0.10,
       0.14,
       0.20,
       0.20,
       0.20,
       0.10,
       0.04)

P <- 100
S <- 25000
r <- 0.02

dt <- as.data.table(cbind(q,w))

npv <- function(cf, r, S, P) {
  cf[, inforce := shift(cumprod(1 - q - w), fill = 1)
  ][, lapses := inforce * w
  ][, deaths := inforce * q
  ][, claims := deaths * S
  ][, premiums := inforce * P
  ][, ncf := premiums - claims
  ][, d := (1/(1+r))^(.I)
  ][, sum(ncf*d)]
}

npv(dt,r,S,P)
#> [1] 50.32483

microbenchmark::microbenchmark(npv(dt,r,S,P))