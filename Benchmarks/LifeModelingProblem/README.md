# LifeModelingProblem

Inspired by the discussion in the [ActuarialOpenSource](https://github.com/actuarialopensource) GitHub community discussion, folks started submitted solutions to what Lewis Fogden referred to as the "Life Modeling Problem".

Which wasn't concretely defined, but I think the "Life Modeling Problem" has the following attributes:

- Recursive calcuations
- Computationally intensive
- Parallelizeable (across policies/cells/products)

Folks started submitting versions of a toy problem with the first two characteristics to showcase different approaches and languages.

The following was benchmarked on 2020 Macbook Air (M1) with all languages using native M1 versions. Times are nanoseconds:

```
┌────────────────┬─────────────┬───────────────┬──────────┬──────────┐
│       Language │   Algorithm │ Function Name │   Median │     Mean │
├────────────────┼─────────────┼───────────────┼──────────┼──────────┤
│ R (data.table) │  Vectorized │           npv │ 770554.0 │ 842767.3 │
│              R │  Vectorized │      npv base │   4264.0 │  46617.0 │
│              R │ Accumulator │      npv_loop │   4346.0 │  62275.7 │
│           Rust │ Accumulator │          npv1 │     22.0 │     22.0 │
│           Rust │ Accumulator │          npv2 │     14.0 │     14.0 │
│ Python (NumPy) │  Vectorized │           npv │  missing │  14437.0 │
│         Python │ Accumulator │      npv_loop │  missing │   2197.0 │
│ Python (Numba) │ Accumulator │     npv_numba │  missing │    388.0 │
│          Julia │  Vectorized │          npv1 │    235.3 │    228.2 │
│          Julia │  Vectorized │          npv2 │    235.8 │    218.4 │
│          Julia │ Accumulator │          npv3 │     14.5 │     14.5 │
│          Julia │ Accumulator │          npv4 │     10.8 │     10.8 │
│          Julia │ Accumulator │          npv5 │     11.5 │     11.5 │
│          Julia │ Accumulator │          npv6 │      9.0 │      9.0 │
│          Julia │ Accumulator │          npv7 │      7.9 │      7.9 │
│          Julia │ Accumulator │          npv8 │      7.4 │      7.4 │
│          Julia │ Accumulator │          npv9 │      6.4 │      6.4 │
└────────────────┴─────────────┴───────────────┴──────────┴──────────┘

```

## Rust

```
❯ rustc --version                                                                                                    (base)
rustc 1.61.0-nightly (f103b2969 2022-03-12)
```

## Python

```
❯ python --version                                                                                                   (base)
Python 3.9.7
```