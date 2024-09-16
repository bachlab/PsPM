# pspm_multi2index
## Description
pspm_multi2index converts a multi onsets structure from pspm_get_timing to a cell array of numerical indices. This function is used by pspm_glm and pspm_extract_segments.

## Format
`[onsets, durations] = pspm_multi2index('samples', multi, sr_ratio, session_duration)` or
`[onsets, durations] = pspm_multi2index('seconds', multi, sr, session_duration)` or
`[onsets, durations] = pspm_multi2index('markers', multi, sr, session_duration, events)`

## Arguments
| Variable | Definition |
|:--|:--|
| multi | multi structure from pspm_get_timing sr: sampling rate, or vector of sampling rates with the same number of elements as multi. |
| sr_ratio | If data was downsampled wrt onset definition, ratio of new_sr/old_sr; or vector of sampling rate ratios. Otherwise, should be 1. |
| session_duration | vector of session duration (number of elements in data vector). |
| events | cell array of event definitions (in seconds). |

