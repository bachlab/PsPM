# pspm_sf_auc
## Description
pspm_sf_auc returns the integral/area under the curve of an SCR time series

## Format
`[sts, auc] = pspm_sf_auc(scr, sr, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| scr | the SCR time series. |
| sr | sampling rate. |
| options | the options struct. |

## Outputs
| Variable | Definition |
|:--|:--|
| auc | The calculated area under the curve. |

## References
[1] Bach DR, Friston KJ, Dolan RJ (2010). Analytic measures for the quantification of arousal from spontanaeous skin conductance fluctuations. International Journal of Psychophysiology, 76, 52-55.


