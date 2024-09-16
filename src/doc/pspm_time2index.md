# pspm_time2index
## Description
pspm_time2index converts time stamps and durations in seconds or markers to a sample index.

## Format
`index = pspm_time2index(time, sr [, data_length, is_duration, events])`

## Arguments
| Variable | Definition |
|:--|:--|
| time | [vector or matrix] time stamps in second. sr: [numeric] sampling rate or frequency. |
| data_length | [integer] the length of data, which the index should not exceed. |
| is_duration | [0/1] whether an index or a duration is required, default as 0. |
| events | vector of timestamps from a marker channel, will be considered if given as input. |

