# pspm_get_labchartmat_in
## Description
pspm_get_labchartmat_in imports exported ADInstruments LabChart files from version 7.1 or lower. These must be exported to matlab using the built-in export feature. For the LabChart extension for version 7.2 and higher, see pspm_labchartmat_ext.

This function is partly based on sample files rather than manufacturer's documentation. Always check your imported data before using it. 

## Format
`[sts, import, sourceinfo] = pspm_get_labchartmat_in(datafile, import);`

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

