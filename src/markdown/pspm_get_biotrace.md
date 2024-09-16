# pspm_get_biotrace
## Description
pspm_get_biotrace imports text-exported Mindemedia BioTrace files.

## Format
`[sts, import, sourceinfo] = pspm_get_biotrace(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | The data file to be imported. |
| import | See following fields. |
| import.channel | The channel to be imported, check pspm_import. |
| import.type | The type of channel, check pspm_import. |
| import.sr | The sampling rate of the file. |
| import.data | The data read from the file. |
| import.marker | The type of marker, such as 'continuous'. |
