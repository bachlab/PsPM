# pspm_rev_glm
## Description
pspm_rev_glm is a tool for reviewing a first level GLM designs. It is meant to be called by pspm_review only.

## Format
`[sts, fig] = pspm_rev_glm(modelfile, plotNr)`

## Arguments
| Variable | Definition |
|:--|:--|
| modelfile | filename and path of modelfile. |
| plotNr | defines which figure shall be plotted (several plots can be defined by a vector) 1 - design matrix, SPM style 2 - design orthogonality, SPM style 3 - predicted & observed 4 - print regressor names 5 - reconstructed responses. |

## Outputs
| Variable | Definition |
|:--|:--|
| sts | status variable indicating whether the function run successfully. |
| fig | returns the figure handles. |

