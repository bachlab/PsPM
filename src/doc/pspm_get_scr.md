# pspm_get_scr
## Description
pspm_get_scr is a common function for importing scr data

## Format
`[sts, data] = pspm_get_scr(import)`

## Arguments
| Variable | Definition |
|:--|:--|
| import | See following fields. |
| import.data | column vector of SCR data. |
| import.sr | sampling rate. |
| import.transfer | transfer parameters, either a struct with fields .Rs, .c, .offset, .recsys, or a file containing variables 'Rs' 'c', 'offset', 'recsys'. |
