# IRR solving

The following was benchmarked on 2020 Macbook Air (M1) with all languages using native M1 versions. Times are nanoseconds:

```
┌──────────┬──────────────────┬───────────────────┬─────────┬─────────────┬───────────────┐
│ Language │          Package │          Function │  Median │        Mean │ Relative Mean │
├──────────┼──────────────────┼───────────────────┼─────────┼─────────────┼───────────────┤
│   Python │  numpy_financial │               irr │ missing │  5339167688 │       332824x │
│   Python │           better │ irr_binary_search │ missing │     6167798 │          384x │
│   Python │           better │        irr_newton │ missing │      945813 │           59x │
│    Julia │ ActuaryUtilities │               irr │   16000 │       16042 │            1x │
└──────────┴──────────────────┴───────────────────┴─────────┴─────────────┴───────────────┘
```

Version details:

- Julia 1.8RC3, ActuaryUtilities 3.7
- Python 3.9.12, numpy-financial 1.0.0, better-irr 53aec87d20c17cfb8fda5f7c95aeb47f90a385e0