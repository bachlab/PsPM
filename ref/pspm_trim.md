# pspm_trim
[Back to index](/PsPM/ref/)

## Description

pspm_trim cuts a PsPM dataset in time, to the limits set with the parameters 'from' and 'to'. The purpose is to remove data that is unrelated to an experiment, which can be rich in artefacts that have an impact on pre-processing (e.g. filtering) and modelling. 

Trimming limits can be defined in terms of file start, first/last marker, or any marker. The resulting data are written to a new file with the original name prepended with a 't' (for 'trim'). In addition, pspm_trim can modify an associated (missing) epochs file to the same limits.


## Format

`[sts, newdatafile, newepochfile] = pspm_trim (datafile, from, to, reference, options)`


## Arguments

| Variable | Definition |
|:--|:--|
| datafile | [char] Name of the file to be trimmed, or a struct accepted by pspm_load_data. |
| from | [numeric or 'none'] Trim point in seconds after chosen reference (negative values for trimming before chosen reference). |
| to | [numeric or 'none'] Trim point in seconds after chosen reference (negative values for trimming before chosen reference). |
| reference | The reference for trimming can be set in 4 different ways: 1. 'file': from and to are set in seconds with respect to start of datafile. 2. 'marker': from and to are defined in seconds with respect to the first and last marker. 3. A 2-element numerical vector: from and to are defined in seconds with respect to the two markers with numbers defined here. 4. Marker names/values [2-element cell_array containing either two marker values (numeric or char) or two marker names (char)]: from and to are defined in seconds with respect to the two markers with names or values defined here. These names or values must be unique. |
| options | See following fields. |
| options.overwrite | [logical] (0 or 1) Define whether to overwrite existing output files or not. Default value: determined by pspm_overwrite. |
| options.marker_chan_num | marker channel number. if undefined or 0, first marker channel is used. |
| options.missing | Optional name of an epoch file, e.g. containing a missing epochs definition in s. This is then split accordingly. |
| options.drop_offset_markers | if 'from' and 'to' are defined with respect to markers, you might be interested in the data that within extend beyond these markers but not in any additional markers which are within this interval. Set this option to 1 to drop markers which lie in the offset. this is for event channels only. Default is 0. |

## Outputs

| Variable | Definition |
|:--|:--|
| sts | status variable indicating whether function run successfully. |
| newdatafile | a filename for the updated file (or a struct with fields .data and .infos if data file is a struct). |
| newepochfile | missing epoch filename for the individual sessions (empty if options.missing not specified). |


[Back to index](/PsPM/ref/)
