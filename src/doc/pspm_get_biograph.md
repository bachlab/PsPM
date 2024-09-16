# pspm_get_biograph
## Description
pspm_get_biograph imports text-exported BioGraph Infiniti files. Export the data using 'Export data to text format', both 'Export Channel Data' and 'Export Interval Data' are supported; a header is required.

## Format
`[sts, import, sourceinfo] = pspm_get_biograph(datafile, import);`

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
