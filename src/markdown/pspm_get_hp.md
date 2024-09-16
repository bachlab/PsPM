# pspm_get_hp
## Description
pspm_get_hp is a common function for importing heart period data

## Format
`[sts, data]= pspm_get_hp(import)`

## Arguments
| Variable | Definition |
|:--|:--|
| data | column vector of waveform data with interpolated heart period data in ms. |
| import | import job structure with mandatory fields .data and .sr. |

