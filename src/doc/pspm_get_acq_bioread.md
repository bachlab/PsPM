# pspm_get_acq_bioread
## Description
pspm_get_acq_bioread imports bioread-converted Biopac Acknowledge files from any Acknowledge version. This function is tested for conversion You can also use pspm_get_acq_python if you have installed this package on the same computer on which you run PsPM.

This function is based on sample files, not on proper documentation of the file format. Always check your imported data before using it. 

## Format
`[sts, import, sourceinfo] = pspm_get_acq_bioread(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | the path of the BIOPAC/AcqKnowledge file to be imported. |
| import | See following fields. |
| import.sr | sampling rate. |
| import.data | The data read from the acq file. |
| import.units | the unit of data. |
| import.marker | The type of marker, such as 'continuous'. |
