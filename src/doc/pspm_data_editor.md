# pspm_data_editor
## Description
pspm_data_editor MATLAB code for pspm_data_editor.fig

## Format
`[sts, out] = pspm_data_editor(indata, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| indata | a file name. |
| options | See following fields. |
| options.output_file | When this is specified, marked epochs will be saved to a missing epochs file when clicking 'save' or 'apply'. It is also possible to specificy this file from within the interactive data editor. |
| options.epoch_file | When this is specified, epochs will be imported from this file and can be changed further. This file must contain a variable 'epochs' which is an n x 2 matrix of epoch on- and offsets (n: number of epochs). It is also possible to specificy this file from within the interactive data editor. |
| options.overwrite | [logical] (0 or 1) Define whether to overwrite existing output file or not. Default: 0. |
## Outputs
| Variable | Definition |
|:--|:--|
| out | The output depends on the actual output type chosen in the graphical interface. At the moment either the interpolated data or epochs only can be chosen as output of the function. |

