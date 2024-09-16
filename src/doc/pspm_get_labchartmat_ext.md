# pspm_get_labchartmat_ext
## Description
pspm_get_labchartmat_ext imports exported ADInstruments LabChart files from version 7.2 or higher. These must be exported to matlab using This function supports data files containing one data block only.

This function is partly based on sample files rather than manufacturer's documentation. Always check your imported data before using it. 

## Format
`[sts, import, sourceinfo] = pspm_get_labchartmat_ext(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | datafile. |
| import | import. |

## Outputs
| Variable | Definition |
|:--|:--|
| sts | status. |
| import | the import structure. |
| sourceinfo | the source information structure. |

