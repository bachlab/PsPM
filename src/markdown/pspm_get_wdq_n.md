# pspm_get_wdq_n
## Description
pspm_get_wdq_n imports Dataq/Windaq files (e.g. used by Coulbourn psychophysiology systems). This function does not use the ActiveX control elements provided by Dataq developers. Instead it reads the binary file according to the documentation published by dataq function has been tested with files of the following type: Unpacked, no Hi-Res data, no Multiplexer files. A warning will be produced if the imported data type fits one of the yet untested cases. If this is the case we suggest you try using the import provided by the manufacturer (pspm_get_wdq, requiring Windows and Matlab 32-bit). 

## Format
`[sts, import, sourceinfo] = pspm_get_wdq_n(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | The data file to be imported. |
| import | The importing settings. |

## Outputs
| Variable | Definition |
|:--|:--|
| import | Struct that includes data obtained from wdq files. |
| sourceinfo | Struct that includes source information. |

