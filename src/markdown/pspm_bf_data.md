# pspm_bf_data
## Description
pspm_bf_data provides a generic interface for creating a user-defined response function from a data vector saved in a *.mat file. To use this function, the variables 'datafile' and 'sr' need to be hard-coded. GLM can then be called with the optional argument model.bf = 'pspm_bf_data'.

## Format
`[bf, x] = pspm_bf_data(td)`

## Arguments
| Variable | Definition |
|:--|:--|
| td | Time interval in points for sampling. |

## Outputs
| Variable | Definition |
|:--|:--|
| bf | Created basis function. |

