How to run rust benchmarks:

1. Install Rust and add to Path
2. Install Rust nightly: `rustup install nightly` (needed to run test features)
3. Compile and run with bench flag: `cargo +nightly bench`

It will show output that looks like this:

```rust
❯ cargo +nightly bench                                                                                                     (base)

running 2 tests
test bench_xor_1000_ints  ... bench:          22 ns/iter (+/- 0)
test bench_xor_1000_ints2 ... bench:          14 ns/iter (+/- 0)
```

Time reported is the [median](https://stackoverflow.com/questions/48323487/how-do-i-interpret-the-output-of-cargo-bench)
