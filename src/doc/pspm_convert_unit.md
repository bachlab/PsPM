# pspm_convert_unit
## Description
pspm_convert_unit is a function to convert between different units currently only length units are possible.

## Format
`[sts, converted] = pspm_convert_unit(data, from, to)`

## Arguments
| Variable | Definition |
|:--|:--|
| data | The data which should be converted. Must be a numeric array of any shape. |
| from | Unit of the input vector. Valid units are currently mm, cm, dm, m, km, in, inches. |
| to | Unit of the output vector. Valid units are currently mm, cm, dm, m, km, in, inches. |

