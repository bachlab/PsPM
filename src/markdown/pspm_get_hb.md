# pspm_get_hb
## Description
pspm_get_hb is a common function for importing heart beat data

## Format
`[sts, data]= pspm_get_hb(import)`

## Arguments
| Variable | Definition |
|:--|:--|
| import | See following fields. |
| import.data | heart beat data. |
| import.marker | ('timestamps', 'continuous'). |
| import.sr | (timestamps: timeunits in seconds, continuous: sample rate in 1/seconds) and optional fields. |
| import.flank | ('ascending', 'descending', 'both': optional field for continuous channels; default: both). |
