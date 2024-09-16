# pspm_export
## Description
pspm_export exports first level statistics from one or several first-level models for further statistical analysis on the group level. 

The output is organised as a matrix with rows for observations (first-level models) and columns for statistics (must be the same for all models). The output can be written to screen or to a text file. 

## Format
`pspm_exp(modelfile, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| modelfile | [string/cell_array] a filename, or cell array of filenames. |
| options | See following fields. |
| options.target | [optional, string, default as 'screen'] 'screen' (default), or a name of an output text file. |
| options.statstype | [optional, string, accepts 'param'/'cond'/'recon'] By default, all parameter estimates are exported. The following options are available: 1. 'param': export all parameter estimates (default) 2. 'cond': For GLMs: automatically detects number of basis functions and exports only the first one (e.g. without derivatives). For non-linear models: average estimate, based on unique trial names. 3. 'recon': For GLMs only: reconstructs estimated response from all basis functions and exports the peak amplitude of the estimated response. |
| options.delim | [optional, default is tab('\t')] delimiter for output file. |
| options.exclude_missing | [optional, default as 0] Exclude parameters from conditions with too many NaN values. This option can only be used for GLM files when exclude_missing was set during model setup. Otherwise this argument is ignored. |
