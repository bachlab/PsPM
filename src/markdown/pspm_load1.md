# pspm_load1
## Format
`[sts, data, mdltype] = pspm_load1(fn, action, savedata, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| fn | filename, or model structure. |
| action | (default 'none'): 'none': check whether file is valid at all 'stats': retrieve stats struct with fields .stats and .names 'cond': for GLM - retrieve stats struct using only first regressor/basis function for each condition for models with 2D stats structure - retrieve mean parameter values per condition, based on unique trial names 'recon': (for GLM) retrieve stats struct using reconstructed responses (which are at the same time written into the glm struct as glm.recon) 'con': retrieve full con structure 'all': retrieve the full first level structure 'savecon': add contrasts to file, use an additional input argument data that contains the contrasts 'save': check and save first levle model, use an additional input argument data that contains the model struct. |
| savedata | for 'save' option - a struct containing the model as only field for 'savecon' option - contains the con structure. |
| options | See following fields. |
| options.zscored | zscore data - substract the mean and divide by the standard deviation. |
| options.overwrite | [for 'save'] [logical] (0 or 1) Define whether to overwrite existing output files or not. Default value: determined by pspm_overwrite. |
