# pspm_get_mat
## Description
pspm_get_mat imports Matlab files with the following specification: The file must contain a variable called data that is either a cell array of column vectors, or a time points x channels matrix. The import of event markers is supported. Marker channels are assumed to be continuous if the input data is a matrix or if the input data is a cell and the given sample rate is larger than 1 Hz. A sample rate has to in the import structure in both cases.

## Format
`[sts, import, sourceinfo] = pspm_get_mat(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | a .mat file that contains a variable 'data' that is either [1] a cell array of channel data vectors; [2] a datapoints x channel matrix. |

