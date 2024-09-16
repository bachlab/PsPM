# pspm_get_events
## Description
pspm_get_events processes events for different event channel types

## Format
`[sts, data] = pspm_get_events(import)`

## Arguments
| Variable | Definition |
|:--|:--|
| import | See following fields. |
| import.data | mandatory |
| import.marker | mandatory, accepts 'timestamps' and 'continuous'. |
| import.sr | timestamps: timeunits in seconds, continuous: sample rate in 1/seconds). |
| import.flank | optional for continuous channels; default: both; accepts 'ascending', 'descending', 'both', 'all'. |
| import.denoise | for continuous marker channels: only retains markers of duration longer than the value given here (in seconds). |
