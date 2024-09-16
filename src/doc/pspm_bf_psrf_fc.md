# pspm_bf_psrf_fc
## Description
pspm_bf_psrf_fc

## Format
`[bs, x] = pspm_bf_psrf_fc(TD, cs, cs_d, us, us_shift)` or
`[bs, x] = pspm_bf_psrf_fc([TD, cs, cs_d, us, us_shift])`

## Arguments
| Variable | Definition |
|:--|:--|
| td | Time resolution in second. |
| cs | CS-evoked response in the basis set. Acceptable values are 0 and 1. Default as 1. |
| cs_d | Derivative of CS-evoked response in the basis set. Acceptable values are 0 and 1. Default as 0. |
| us | US-evoked response in the basis set. Acceptable values are 0 and 1. Default as 0. |
| us_shift | CS-US SOA in seconds. Ignored if us == 0. Default as 3.5. |

