# pspm_get_acqmat
## Description
pspm_get_acqmat imports exported Biopac Acknowledge files from version 4.0 or higher. Export into matlab format from within the Acknowledge software. This function has been tested for Acknowledge version 4.2.0 only. 

This function is based on sample files, not on proper documentation of the file format. Always check your imported data before using it.

## Format
`[sts, import, sourceinfo] = pspm_get_acqmat(datafile, import);`

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
