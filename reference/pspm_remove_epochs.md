# pspm_remove_epochs
(Back to index)[/reference]
## Description
pspm_remove_epochs sets epochs of data, as defined by an epoch file, to NaN. 

## Format
`[sts, channel_index] = pspm_remove_epochs(datafile, channel, epochfile, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | a filename or a cell of filenames. |
| channel | defines which channels should be affected by epoch removal. This can be a numerical vector or channel identifier accepted by pspm_load_data. |
| epochfile | a filename which defines the epoch to be set to NaN. The epochs must be in seconds. This parameter is passed to pspm_get_timing(). |
| timeunits | timeunits of the epochfile. |
| options | See following fields. |
| options.channel_action | ['add'/'replace'] Defines whether new channels should be added or corresponding channels should be replaced. The default value is 'add'. |
(Back to index)[/reference]
