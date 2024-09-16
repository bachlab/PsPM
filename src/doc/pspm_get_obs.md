# pspm_get_obs
## Description
pspm_get_obs imports text-exported Noldus Observer XT compatible files. 

The function is only assured to work with the output files of the system Vsrrp98.

This function is based on sample files, not on proper documentation of the file format. Always check your imported data before using it. 

## Format
`[sts, import, sourceinfo] = pspm_get_obs(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | datafile to be imported. |
| import | import settings. |

## Outputs
| Variable | Definition |
|:--|:--|
| sts | status. |
| import | the updated import structure. |
| sourceinfo | the source information structure. |

