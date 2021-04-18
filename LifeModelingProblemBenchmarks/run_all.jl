run(`julia julia/julia.jl`) # logs to file

# move to rust directory and bench 
cd("rust/src")
run(`cargo +nightly bench`) # logs to console

# back to home directory
cd("...")

cd("python")