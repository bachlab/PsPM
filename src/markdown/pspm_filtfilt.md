# pspm_filtfilt
## Description
pspm_filtfilt. Zero-phase forward and reverse digital filtering

## Format
`[sts, y] = pspm_filtfilt(b,a,x)` or
`y = pspm_filtfilt(b,a,x)`

## Arguments
| Variable | Definition |
|:--|:--|
| b | filter parameters (numerator). |
| a | filter parameters (denominator). |
| x | input data vector (if matrix, filter over columns). |
| y | filtered data. |

## References
[1] Sanjit K. Mitra, Digital Signal Processing, 2nd ed, McGraw-Hill, 2001

[2] Fredrik Gustafsson, Determining the initial states in forward-backward filtering, IEEE Transactions on Signal Processing, pp. 988--992, April 1996, Volume 44, Issue 4


