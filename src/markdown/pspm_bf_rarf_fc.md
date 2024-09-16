# pspm_bf_rarf_fc
## Description
pspm_bf_rarf_fc is a basis function.

## Format
`[bs, x] = pspm_bf_rarf_fc(td, bf_type)` or
`[bs, x] = pspm_bf_rarf_fc([td, bf_type])`

## Arguments
| Variable | Definition |
|:--|:--|
| td | The time the response function should have. |
| bf_type | Which type of response function should be generated. Can be either 1 or 2. If 1, first type response function is generated, (default) = gamma_early + gamma_late. If 2, second type response function is generated, (default) = gamma_early + gamma_early'. |

