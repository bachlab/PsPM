# pspm_get_acq
## Description
pspm_get_acq imports Biopac Acknowledge files from version 3.9.0 or lower. This function uses the conversion routine acqread.m version 2.0 (2007-08-21) by Sebastien Authier and Vincent Finnerty at the University of Montreal which supports all files created with Windows/PC versions of AcqKnowledge (3.9.0 or below), BSL (3.7.0 or below), and BSL PRO (3.7.0 or below).

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
