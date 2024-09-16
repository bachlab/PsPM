# pspm_bf_lcrf_gm
## Description
pspm_bf_lcrf_gm is the gamma response function for pupil constriction.

Pupil size models were developed with pupil size data recorded in diameter values. Therefore pupil size data analyzed using these models should also be in diameter.

## Format
`[bs, x] = pspm_bf_lcrf_gm(td, n, offset, a, b, A)` or
`[bs, x] = pspm_bf_lcrf_gm([td, n, offset, a, b, A])`

## Arguments
| Variable | Definition |
|:--|:--|
| td | time resolution in second. |
| n | duration of the function in s. Default as 20 s. |
| offset | offset in s. tells the function where to start with the response function. Default as 0.2 s. |
| a | shape of the function. |
| b | scale of the function. |
| A | quantifier or amplitude of the function. |

## References
Korn CW, Bach DR. A solid frame for the window on cognition: Modeling event-related pupil responses. J Vis. 2016;16(3):28. doi: 10.1167/16.3.28.


