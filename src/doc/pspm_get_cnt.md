# pspm_get_cnt
## Description
pspm_get_cnt imports NeuroScan cnt files using FieldTrip functions.

## Format
`[sts, import, sourceinfo] = pspm_get_cnt(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | The data file to be imported. |
| import | See following fields. |
| import.typeno | The number of channel type. |
| import.channel | The channel to be imported, check pspm_import. |
| import.type | The type of channel, check pspm_import. |
| import.sr | The sampling rate of the file. |
| import.data | The data read from the file. |
| import.marker | The type of marker, such as 'continuous'. |
| import.markerinfo | The information of the marker, has two fields, value and name. |
