# pspm_get_txt
## Description
pspm_get_txt imports text files with the following specifications: The file can only contain numbers (i.e. no header lines, such as channel names) and one data column per channel. Data must use the decimal point. Any delimiter can be used; the delimiter is set in the import structure (default: whitespace). At the moment, import of event markers is not supported.

## Format
`[sts, import, sourceinfo] = pspm_get_txt(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | a .txt-file containing numerical data (with any delimiter) and optionally the channel names in the first line. |
| import | See following fields. |
| import.type | A char array corresponding to a valid PsPM data type, see `pspm_init.m` for more details. |
| import.channel | A numeric value representing the column number of the corresponding numerical data. |
| import.delimiter | [optional] A char array corresponding to the delimiter used in the datafile to delimit data columns. To be used it should be specified on the first import cell, e.g.: import{1}.delimiter == ','. Default: white-space (see textscan function). |
| import.header_lines | [optional] A numeric value corresponding to the number of header lines. Which means the data start on line number: "header_lines + 1". To be used it should be specified on the first import cell, e.g.: import{1}.header_lines == 3. Default: 1. |
| import.channel_names_line | [optional] A numeric value corresponding to the line number where the channel names are specified. To be used it should be specified on the first import cell, e.g. import{1}.channel_names_line == 2 Default: 1. |
| import.exclude_columns | [optional] A numeric value corresponding to the number of columns to exclude starting from the left. To be used it should be specified on the first import cell, e.g. import{1}.exclude_columns == 2. Default: 0. |
