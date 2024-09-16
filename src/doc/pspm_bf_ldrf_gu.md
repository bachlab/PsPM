# pspm_bf_ldrf_gu
## Description
pspm_bf_ldrf_gu is the Gaussian response function for pupil dilation.

Pupil size models were developed with pupil size data recorded in diameter values. Therefore pupil size data analyzed using these models should also be in diameter.

## Format
`[bs, x] = pspm_bf_ldrf_gu(td, n, offset, p1, p2, p3, p4)` or
`[bs, x] = pspm_bf_ldrf_gu([td, n, offset, p1, p2, p3, p4])`

## Arguments
| Variable | Definition |
|:--|:--|
| td | Time resolution in second. |
| n | Duration of the function in second. Default as 20 s. |
| offset | Offset in s. tells the function where to start with the response function. Default as 0.2 s. |
| p1 | Shape for Gaussian response function, or a, default as 0.27. |
| p2 | Scale for Gaussian response function, or b, default as 2.04. |
| p3 | Parameter for Gaussian response function, or x0, default as 1.48. |
| p4 | Quantifier or amplitude for Gaussian response function, or A, default as 0.004. |

