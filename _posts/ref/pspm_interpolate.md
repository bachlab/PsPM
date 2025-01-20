# pspm_interpolate
[Back to index](/PsPM/ref/)

## Description

pspm_interpolate interpolates NaN values. It either acts on one selected channel of a PsPM file and writes the result to the same file, or on all channels in the file and writes a new file with the same name as the old file, prepended with 'i'. For internal purposes, the function can also act on data vectors and then gives an interpolated data vector as output.


## Format

`[sts, channel_index] = pspm_interpolate(filename, channel, options)` or
`[sts, newfile] = pspm_interpolate(filename, channel, options)` or
`[sts, outdata] = pspm_interpolate(numeric_array, options)`


## Arguments

| Variable | Definition |
|:--|:--|
| indata | [char/numeric] contains the data to be interpolated. |
| channel | a single channel identifier accepted by pspm_load_channel (numeric or char), or 'all', which will work on all channels. If indata is a file name and channel is 'all' then the result is written to a new file called 'i'+<old filename>. |
| options | See following fields. |
| options.method | Defines the interpolation method, see interp1() for possible interpolation methods. Default is 'linear'. |
| options.extrapolate | [not recommended; 0 or 1] Determine extrapolation for query points out of the data range. Default is no extrapolation. |
| options.overwrite | Defines if existing datafiles should be overwritten. [logical] (0 or 1) Define whether to overwrite existing output files or not. Default value: do not overwrite. Only used if 'channel' is 'all'. |
| options.channel_action | Defines whether the interpolated data should be added or the corresponding channel should be replaced. [optional; accept: 'add', 'replace'; default: 'add'] Only used if 'channel' is not 'all'. |

[Back to index](/PsPM/ref/)
