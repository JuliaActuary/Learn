# European Call Option Pricing (Black Scholes formula)

[Wikipedia link](https://en.wikipedia.org/wiki/Black%E2%80%93Scholes_model#Black%E2%80%93Scholes_formula)

The following was benchmarked on 2020 Macbook Air (M1) with all languages using native M1 versions. Times are nanoseconds:

```
┌──────────┬─────────┬─────────────┬───────────────┐
│ Language │  Median │        Mean │ Relative Mean │
├──────────┼─────────┼─────────────┼───────────────┤
│   Python │ missing │    817000.0 │       19926.0 │
│        R │  3649.0 │      3855.2 │          92.7 │
│    Julia │    41.0 │        41.6 │           1.0 │
└──────────┴─────────┴─────────────┴───────────────┘
```