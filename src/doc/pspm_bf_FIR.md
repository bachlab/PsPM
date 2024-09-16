# pspm_bf_FIR
## Description
pspm_bf_FIR provides a pre-defined finite impulse response (FIR) model for skin conductance responses with n (default 30) post-stimulus timebins of 1 second each.

## Format
`[FIR, x] = pspm_bf_FIR(TD, N, D)` or
`[FIR, x] = pspm_bf_FIR([TD, N, D])`

## Arguments
| Variable | Definition |
|:--|:--|
| TD | sampling interval in seconds. |
| N | number of timepoints. Default as 30 s. |
| D | duration of bin in seconds. Default as 1 s. |

