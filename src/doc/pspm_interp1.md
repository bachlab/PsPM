# pspm_interp1
## Description
pspm_interp1 is a shared PsPM function for interpolating data with NaNs based on the reference of missing epochs and first order interpolation.

## Format
`Y = pspm_interp1(varargin)`

## Arguments
| Variable | Definition |
|:--|:--|
| X | data that contains NaNs to be interpolated. |
| index_missing | index of missing epochs with the same size of X in binary values. 1 if NaNs, 0 if non-NaNs. |
| Y | processed data. |

