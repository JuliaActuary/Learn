# LifeModelingProblem

Inspired by the discussion in the [ActuarialOpenSource](https://github.com/actuarialopensource) GitHub community discussion, folks started submitted solutions to what Lewis Fogden referred to as the "Life Modeling Problem".

Which wasn't concretely defined, but I think the "Life Modeling Problem" has the following attributes:

- Recursive calcuations
- Computationally intensive
- Parallelizeable (across policies/cells/products)

Folks started submitting versions of a toy problem with the first two characteristics to showcase different approaches and languages.

The following was benchmarked on 2020 Macbook Air (M1) with all software compatible with the new M1 chip:

```
┌────────────────┬─────────────┬──────────────────┬──────────┬───────────┐
│           lang │   algorithm │    function_name │   median │      mean │
│         String │      String │           String │ Float64? │  Float64? │
├────────────────┼─────────────┼──────────────────┼──────────┼───────────┤
│ R (data.table) │  Vectorized │ npv (data.table) │ 770554.0 │ 8.42767e5 │
│              R │  Vectorized │         npv base │   4264.0 │   46617.0 │
│              R │ Accumulator │         npv_loop │   4346.0 │   62275.7 │
│           Rust │ Accumulator │              npv │     24.0 │   missing │
│ Python (NumPy) │  Vectorized │              npv │  missing │   6823.25 │
│         Python │ Accumulator │         npv_loop │  missing │   1486.04 │
│          Julia │  Vectorized │             npv1 │  235.322 │   228.198 │
│          Julia │  Vectorized │             npv2 │  235.758 │   218.391 │
│          Julia │ Accumulator │             npv3 │   14.507 │    14.487 │
│          Julia │ Accumulator │             npv4 │   10.764 │    10.761 │
│          Julia │ Accumulator │             npv5 │    11.49 │    11.469 │
│          Julia │ Accumulator │             npv6 │    9.037 │     9.009 │
│          Julia │ Accumulator │             npv7 │     7.92 │     7.917 │
│          Julia │ Accumulator │             npv8 │    7.372 │     7.375 │
│          Julia │ Accumulator │             npv9 │    6.388 │     6.375 │
└────────────────┴─────────────┴──────────────────┴──────────┴───────────┘
```