# IRR solving

The following was benchmarked on 2020 Macbook Air (M1) with all languages using native M1 versions. Times are nanoseconds:

```
┌──────────┬──────────────────┬───────────────────┬─────────┬─────────────┬───────────────┐
│ Language │          Package │          Function │  Median │        Mean │ Relative Mean │
├──────────┼──────────────────┼───────────────────┼─────────┼─────────────┼───────────────┤
│   Python │  numpy_financial │               irr │ missing │ 918376814.0 │       13350.1 │
│   Python │           better │ irr_binary_search │ missing │   3698785.0 │          53.8 │
│   Python │           better │        irr_newton │ missing │    557129.0 │           8.1 │
│    Julia │ ActuaryUtilities │               irr │ 69625.0 │     68792.0 │           1.0 │
└──────────┴──────────────────┴───────────────────┴─────────┴─────────────┴───────────────┘
```