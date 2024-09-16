# pspm_get_marker
## Description
pspm_get_marker gets the marker channel for different data types

## Format
`[sts, data] = pspm_get_marker(import)`

## Arguments
| Variable | Definition |
|:--|:--|
| import | See following fields. |
| import.data | mandatory |
| import.marker | mandatory, string accepted values: 'timestamps' or 'continuous'. |
| import.sr | mandatory, double timestamps: timeunits in seconds continuous: sample rate in 1/seconds). |
| import.flank | optional, string, applicable for continuous channels only accepted values: 'ascending', 'descending', 'both' default: 'both'. |
| import.markerinfo | optional, struct, returns marker timestamps in seconds. It has two fields, name and value. |
