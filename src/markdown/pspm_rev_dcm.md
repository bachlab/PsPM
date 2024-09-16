# pspm_rev_dcm
## Description
pspm_rev_dcm displays DCM results post hoc. It is meant to be called by pspm_review only.

## Format
`pspm_rev_dcm(dcm, job, sn, trl)`

## Arguments
| Variable | Definition |
|:--|:--|
| dcm | dcm struct or modelfile. |
| job | [char], accepts 'inv', 'sf', 'sum', 'scrf', or 'names'. 'inv' show inversion results, input argument session & trial number 'sf' same for SF, input argument episode number 'sum' show trial-by-trial summary, input argument session number, optional argument figure name (saves the figure) (can also be called as ...(dcm, 'sum', figname) for on-the-fly display and saving of figure) 'scrf' show peripheral skin conductance response function as used for trial-by-trial estimation of sympathetic input 'names' show trial and condition names in command window. |
| sn | session. |
| trl | trial. |

