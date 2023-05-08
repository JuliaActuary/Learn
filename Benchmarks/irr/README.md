# IRR solving

The following was benchmarked on 2020 Macbook Air (M1) with all languages using native M2 versions. Times are nanoseconds:

```
┌──────────┬──────────────────┬───────────────────┬─────────┬─────────────┬───────────────┐
│ Language │          Package │          Function │  Median │        Mean │ Relative Mean │
├──────────┼──────────────────┼───────────────────┼─────────┼─────────────┼───────────────┤
│   Python │  numpy_financial │               irr │ missing │   519306422 │       123146x │
│   Python │           better │ irr_binary_search │ missing │     3045229 │          722x │
│   Python │           better │        irr_newton │ missing │      382166 │           91x │
│    Julia │ ActuaryUtilities │               irr │    4185 │        4217 │            1x │
└──────────┴──────────────────┴───────────────────┴─────────┴─────────────┴───────────────┘
```

Version details:

- Julia 1.9RC3, ActuaryUtilities 3.12, FinanceCore 1.1
- Python 3.11.3, numpy-financial 1.0.0, numpy 1.24.3, better-irr 53aec87d20c17cfb8fda5f7c95aeb47f90a385e0