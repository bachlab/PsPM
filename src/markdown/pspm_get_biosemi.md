# pspm_get_biosemi
## Description
pspm_get_biosemi imports BioSemi bdf files using fieldtrip fileio functions

## Format
`[sts, import, sourceinfo] = pspm_get_biosemi(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | The BioSemi bdf data file to be imported. |
| import | See following fields. |
| import.typeno | The number of channel type. |
| import.channel | The channel to be imported, check pspm_import. |
| import.type | The type of channel, check pspm_import. |
| import.sr | The sampling rate of the file. |
| import.data | The data read from the file. |
| import.marker | The type of marker, such as 'continuous'. |
| import.markerinfo | The information of the marker, has two fields, value and name. |
