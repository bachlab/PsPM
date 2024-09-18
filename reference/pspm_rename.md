# pspm_rename
(Back to index)[/reference]
## Description
pspm_ren renames a PsPM datafile and updates the internal structure (the field 'infos') with the new file name. 

## Format
`[sts, newfilename] = pspm_ren(filename, newfilename, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| filename | name of an existing PsPM file. |
| newfilename | new name of the PsPM file. |
| options | See following fields. |
| options.overwrite | [Optional, logical] overwrite existing file by default The default value is determined by pspm_overwrite. |
(Back to index)[/reference]
