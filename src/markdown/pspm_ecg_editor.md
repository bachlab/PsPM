# pspm_ecg_editor
## Description
pspm_ecg_editor allows manual correction of ecg data and creates a hb output. This function can be automatically called during data conversion or separately.

## Format
`[sts, R] = pspm_ecg_editor(pt)` or
`[sts, R] = pspm_ecg_editor(fn, channel, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| pt | A struct() from pspm_convert_ecg2hb detection. |
| fn | A PsPM file containing the ecg channel to be edited. |
| channel | Index of ecg channel in the data file. |
| options | See following fields. |
| options.channel | Channel id of the existing hb channel. |
| options.semi | Defines whether to navigate between potentially wrong hb events only (semi = 1), or between all hb events (semi = 0 => manual mode). |
| options.missing | Epoch file with artefact periods to be considered missing. These will be ignored for faulty heart beat detection. |
| options.limits | [struct with fields .upper, .lower] Upper and lower limits of the interbeat interval to be considered as potentially faulty. |
| options.factor | Deviation by what factor of the standard deviation should lead to inter beat intervals highlighted as potentially faulty (Default: 1). |
## Outputs
| Variable | Definition |
|:--|:--|
| R | r(1,:) ... original r vector r(2,:) ... r vector containing potential faulty labeled qrs compl. r(3,:) ... removed r(4,:) ... added. |

