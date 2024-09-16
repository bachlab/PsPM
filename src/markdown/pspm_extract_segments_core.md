# pspm_extract_segments_core
## Description
pspm_extract_segments_core extracts segments of equal length from a cell array of data

## Format
`[sts, segments, session_index] = pspm_extract_segments_core(data, onsets, segment_length, missing)`

## Arguments
| Variable | Definition |
|:--|:--|
| data | [cell] a cell array of data vectors of arbitrary length. |
| onsets | [cell] a cell array of the same size as 'data', with segment onsets defined in terms of a numerical index of arbitrary length. |
| segment_length | [integer] an integer specificying the length of the data segments (in samples). |
| missing | [cell array] OPTIONAL a logical index of missing values which will be set to NaN in the extracted segments. A cell array of the same size as 'data', with elements of the same size as the elements of 'data'. |

