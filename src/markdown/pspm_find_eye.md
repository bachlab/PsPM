# pspm_find_eye
## Format
`[sts, eye, new_chantype] = pspm_find_eye(chantype)`

## Arguments
| Variable | Definition |
|:--|:--|
| chantype | the field header.chantype as returned by pspm_load_data. |

## Outputs
| Variable | Definition |
|:--|:--|
| eye | one of {'r', 'l', 'c', ''}. |
| new_chantype | chantype with eye marker removed. |

