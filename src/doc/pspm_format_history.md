# pspm_format_history
## Description
pspm_format_history returns a table-like formatted string using the contents of the history cell array. This is the structure that exists in infos.history field in PsPM files.

pspm_format_history expects a certain structure in the history fields.

In particular, the history entry should start with the operation performed followed by '::'. Afterwards, all the remaining fields should be separated by '--' delimiter. This structure is used in all PsPM preprocessing functions starting in version 4.2.0. For earlier versions, this function may not produce decent looking tables.

## Format
`[sts, hist_str] = pspm_format_history(history_cell_array)`

## Arguments
| Variable | Definition |
|:--|:--|
| history_cell_array | [cell array of strings] infos.history field in a PsPM file. |

