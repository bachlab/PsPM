# pspm_get_brainvis
## Description
pspm_get_brainvis imports BrainVision files using FieldTrip fileio functions.

This function has not been tested on sample files. Always check your imported data before using it. 

## Format
`[sts, import, sourceinfo] = pspm_get_brainvis(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | the path of data file to be imported. |
| import | the struct of import settings. |

