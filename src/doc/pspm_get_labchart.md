# pspm_get_labchart
## Description
pspm_get_labchart imports ADInstruments LabChart *.adicht files. This function uses an external library that requires Windows as OS. See pspm_labchartmat_in and pspm_labchart_mat_ex for import of matlab files that were exported either using the built-in function or the online conversion tool.

## Format
`[sts, import, sourceinfo] = pspm_get_labchart(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | The data file to be imported. |
| import | Importing settings. |

