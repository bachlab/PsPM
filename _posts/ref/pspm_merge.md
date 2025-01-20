# pspm_merge
[Back to index](/PsPM/ref/)

## Description

pspm_merge merges two PsPM datafiles recorded in an overlapping time interval by "stacking" the channels from the two files. It then writes the result into a new file with the same name as the first file, prepended with 'm'. The channels are aligned to file start, or to first marker. If the recordings are not matching exactly, channel data will be expanded by NaNs. 


## Format

`[sts, outfile] = pspm_merge(infile1, infile2, reference, options)`


## Arguments

| Variable | Definition |
|:--|:--|
| infile1 | data file name(s) (char). |
| infile2 | data file name(s) (char). |
| reference | Determines how the two files are aligned. 1. 'marker': Align files with respect to first marker in either file. 2. 'file': Align files with respect to file start. |
| options | See following fields. |
| options.overwrite | overwrite existing file by default [logical] (0 or 1) Default value: determined by pspm_overwrite. |
| options.marker_chan_num | 2-element vector of marker channel numbers to be used as a reference. Ignored if reference is specified as 'file'. If undefined or 0, the first marker channel of either file is used. |

[Back to index](/PsPM/ref/)
