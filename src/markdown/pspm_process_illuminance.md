# pspm_process_illuminance
## Description
pspm_process_illuminance transforms an illuminance time series into a convolved pupil response time series, to be used as nuisance file in a GLM. This allows partialling out illuminance contributions to pupil responses evoked by cognitive inputs. Alternatively it allows analysing the illuminance responses as such, by extracting parameter estimates relating to the nuisance regressors from the GLM.

The illuminance file should be a .mat file with a vector variable called Lx. In order to fulfill the requirements of a later nuisance file there must be as many values as there are data values in the pupil channel. Data must be given in lux (lm/m2) to account for the non-linear mapping from illuminance to steady-state pupil size. To transform luminance (cd/m2) to illuminance values, please see 

## Format
`[sts, out] = pspm_process_illuminance(ldata, sr, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| ldata | Illuminance data as (cell of) 1x1 double or filename. |
| sr | Sample rate in Hz of the input illuminance data. |
| options | See following fields. |
| options.fn | [filename] Ff specified ldata{i,j} will be saved to a file with filename options.fn{i,j} into the variable 'R'. |
| options.overwrite | [logical] (0 or 1) Define whether to overwrite existing output files or not. Default value: determined by pspm_overwrite. |
| options.transfer | Params for the transfer function. |
| options.bf | See following fields. |
| options.bf.constriction | [struct with field .fhandle] Options for the constriction response function. Currently allowed values are @pspm_bf_lcrf_gm. |
| options.bf.dilation | [struct with field .fhandle] Options for the dilation response function. Currently allowed values are @pspm_bf_ldrf_gm and @pspm_bf_ldrf_gu. |
| options.bf.duration | Duration of the basis functions in seconds. |
| options.bf.offset | Offset in seconds. |

## Outputs
| Variable | Definition |
|:--|:--|
| sts | status |
| out | has same size as ldata and contains either the processed data (if options.fn is not provided) or the output file name(s). |

## References
Korn CW & Bach DR (2016). A solid frame for the window on cognition: Modelling event-related pupil responses. Journal of Vision, 16:28,1-6.


