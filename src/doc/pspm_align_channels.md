# pspm_align_channels
## Description
pspm_align_channels is an import functions that checks recording length for all channels of a data file and aligns them.

If a duration argument is stated, all channels will be aligned to this duration.

## Format
`[sts, data, duration] = pspm_align_channels(data, induration)`

## Arguments
| Variable | Definition |
|:--|:--|
| data | [struct] the input data to be processed, in PsPM data format. |
| induration | [double] the duration of the input data. |

