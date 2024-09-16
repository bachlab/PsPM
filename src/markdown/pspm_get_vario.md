# pspm_get_vario
## Description
pspm_get_vario imports VarioPort files using the conversion routine getVarioPort.m written and maintained by Christoph Berger at the University of Rostock.

## Format
`[sts, import, sourceinfo] = pspm_get_vario(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | the data file to be imported. |
| import | the import struct of importing settings. |

## Outputs
| Variable | Definition |
|:--|:--|
| import | the import struct with added information. |
| sourceinfo | the struct that includes source information. |

