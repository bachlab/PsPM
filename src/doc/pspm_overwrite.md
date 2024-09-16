# pspm_overwrite
## Description
pspm_overwrite generalises the overwriting operation pspm_overwrite considers the following situations - whether options.overwrite is defined - whether PsPM is in develop mode - whether the file exist - whether GUI can be used PsPM will always try to overwrite files wherever possible except: 1. if overwrite is defined as not to overwrite 2. if overwrite is not defined a. the file has existed b. users use the GUI to stop overwriting

## Arguments
| Variable | Definition |
|:--|:--|
| fn | the name of the file to possibly overwrite can be a link if necessary. |
| overwrite | a numerical value or a struct option of overwrite if this option is presented can be a value or a struct. If a value, can be 0 (not to overwrite) or 1 (to overwrite) or 2 (ask user). If a struct, check if the field `overwrite` exist. |

## Outputs
| Variable | Definition |
|:--|:--|
| overwrite_final | option of overwriting determined by pspm_overwrite 0: not to overwrite 1: to overwrite. |

