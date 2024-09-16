# pspm_get_acq_python
## Description
pspm_get_acq_python imports Biopac Acknowledge files from any version, using the Python package bioread. Please ensure you have installed has been tested for bioread version 3.0.1 only.

This function is based on sample files, not on proper documentation of the file format. Always check your imported data before using it. 

## Format
`[sts, import, sourceinfo] = pspm_get_acq_python(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | The .acq data file to be imported. |
| import | See following fields. |
| import.channel | The channel to be imported, check pspm_import. |
| import.type | The type of channel, check pspm_import. |
| import.sr | The sampling rate of the acq file. |
| import.data | The data read from the acq file. |
| import.marker | The type of marker, such as 'continuous'. |
