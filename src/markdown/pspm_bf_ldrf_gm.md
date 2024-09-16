# pspm_bf_ldrf_gm
## Description
pspm_bf_ldrf_gm is the Gamma response function for pupil dilation.

Pupil size models were developed with pupil size data recorded in diameter values. Therefore pupil size data analyzed using these models should also be in diameter.

## Format
`[bs, x] = pspm_bf_ldrf_gm(td, n, offset, a, b, A)` or
`[bs, x] = pspm_bf_ldrf_gm([td, n, offset, a, b, A])`

## Arguments
| Variable | Definition |
|:--|:--|
| td | Time resolution in second. |
| n | Duration of the function in second. Default as 20 s. |
| offset | Offset in s. tells the function where to start with the response function. Default as 0.2 s. |
| a | Shape of the function. |
| b | Scale of the function. |
| A | Quantifier or amplitude of the function. |

