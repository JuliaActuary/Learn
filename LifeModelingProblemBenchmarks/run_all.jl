run(`julia julia/julia.jl`)

cd("rust/src")
run(`cargo +nightly bench`)

cd("...")