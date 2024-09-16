# pspm_get_wdq
## Description
pspm_get_wdq imports Dataq/Windaq files (e.g. used by Coulbourn psychophysiology systems). This function uses the conversion routine ReadDataq.m provided by Dataq developers and contained in the PsPM distribution. ActiveX control elements provided in the file activex.exe provided by Dataq must be installed, too. The ActiveX plugin only runs under 32 bit Matlab on Windows.

## Format
`[sts, import, sourceinfo] = pspm_get_wdq(datafile, import);`

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

