# pspm_prepdata
## Description
pspm_prepdata is a shared PsPM function for twofold butterworth filting and downsampling raw data `on the fly`. This data is usually stored in results files rather than data files.

## Format
`[sts, data, newsr] = pspm_prepdata(varargin)` or
`[sts, data, newsr] = pspm_prepdata(data, filt)` or
`[sts, data, newsr] = pspm_prepdata(data, filt, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| data | a column vector of data. |
| filt | See following fields. |
| filt.sr | current sample rate in Hz. |
| filt.lpfreq | low pass filt frequency or 'none'. |
| filt.lporder | low pass filt order. |
| filt.hporder | high pass filt order. |
| filt.hpfreq | high pass filt frequency or 'none'. |
| filt.direction | filt direction. |
| filt.down | sample rate in Hz after downsampling or 'none'. || options | See following fields. |
| options.fillnan | 0/1 specify whether to fill nan if there is. Default: 1. |
