# pspm_epochs2logical
## Description
pspm_epochs2logical converts a nx2 (onset/offset) missing epoch matrix into a logical index of length datalength The function does not check the integrity of the epoch definition (use pspm_get_timing for some basic checks). This is an internal function with no input checks.

## Format
`index = pspm_epochs2logical(epochs, datalength, sr)`

## Arguments
| Variable | Definition |
|:--|:--|
| epochs | nx2 (onset/offset) missing epoch matrix. |
| datalength | length of the resulting logical index. |
| sr | if epochs are specified in seconds: sample rate if epochs are specified in terms of data samples: 1. |

