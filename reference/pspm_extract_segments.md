# pspm_extract_segments
(Back to index)[/reference]
## Description
pspm_extract_segments extracts data segments of fixed length after defined onsets, groups them by condition, and computes summary statistics (mean, SD, SEM, NaN) for each condition. This is a first-level (subject-level) function. 

The function supports automated extraction from a model file, or manually defining timing definitions and extracting from a PsPM data file. For non-linear models, each trial will be treated as a separate condition unless trial names were specified in the model setup.

The function returns a cell array of struct named 'segments' with c elements, where c is the number of conditions specified. Each element contains the following fields: data, mean, std, sem, trial_nan_percent, and total_nan_percent. 

The output can also be written to a matlab file. 

## Format
`[sts, segments] = pspm_extract_segments('file', data_fn, channel, timing, options)` or
`[sts, segments] = pspm_extract_segments('data', data, sr, timing, options)` or
`[sts, segments] = pspm_extract_segments('model', modelfile, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| mode | Tells the function in which mode get the settings from. Either 'file', 'data', or 'model'. |
| modelfile | Path to the glm or dcm file or a glm/dcm structure. |
| data_fn | Path or cell of paths to data file from which the segments should be extracted. |
| data | Numeric data or a cell array of numeric data. |
| channel | Channel identifier accepted by pspm_load_channel. |
| sr | Sample rate (ignored if options.timeunits == 'samples'). |
| timing | An onsets definition or file, as accepted by pspm_get_timing, or cell array thereof. |
| options | See following fields. |
| options.timeunits | 'seconds' (default), 'samples' or 'markers'. In 'model' mode the value will be ignored and taken from the model file. In case a data vector is passed as input, timeunits must be 'samples' or 'seconds'. |
| options.length | Length of the segments in the specified 'timeunits'. The default value is 10. |
| options.plot | [0/1] Plot mean values (solid) and standard error of the mean (dashed) will be ploted. Default is no plot. |
| options.outputfile | Define filename to store segments. If is equal to '', no file will be written. Default is 0. |
| options.overwrite | Define if already existing files should be overwritten. Default ist 0. |
| options.marker_chan_num | Optional if timeunits are 'markers'. Channel identifier for the marker channel. Default: first marker channel in the file. |
| options.missing | allows to specify missing (e. g. artefact) epochs in the data file. See pspm_get_timing for epoch definition; specify a cell array for multiple input files. This must always be specified in SECONDS. if method is 'model', then this option overides the missing values given in the model Default: no missing values. |
| options.nan_output | ['screen', filename, or 'none'] Output NaN ratios of the trials for each condition. Values can be printed on the screen or written to a matlab file. Default is no NaN output. |
| options.norm | If 1, z-scores the entire data time series (default: 0). |
(Back to index)[/reference]
