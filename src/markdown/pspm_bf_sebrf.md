# pspm_bf_sebrf
## Description
pspm_bf_sebrf constructs the startle eyeblink response function consisting of gamma probability functions. Basis functions will be orthogonalized using spm_orth by default.

## Format
`[bf, x] = pspm_bf_sebrf(td, d, g)` or
`[bf, x] = pspm_bf_sebrf([td, d, g])`

## Arguments
| Variable | Definition |
|:--|:--|
| td | Time resolution in s. |
| d | Whether first derivative should be included (1) or not (0). Default as 0. |
| g | Whether gaussian to model the tail should be included (1) or not (0). Default as 0. |

