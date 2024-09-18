# pspm_combine_markerchannels
(Back to index)[/reference]
## Description
This function combines several marker channels into one.

Index of original marker channel is converted into marker name and marker value of the new channel.

This allows for example creating GLM timing definitions based on markers distributed across multiple channels.

## Format
`[sts, outchannel] = pspm_combine_markerchannels(datafile, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | data file name(s): char. |
| options | See following fields. |
| options.channel_action | Accepted values: 'add'/'replace' Defines whether the new channel should be added on top of combined marker channels ('add'), or all combined marker channels should be deleted and replaced with the one new channel ('replace'). If the first option is used, then use marker channel indexing in further processing which by default takes the first marker channel as input. |
| options.marker_chan_num | any number of marker channel numbers - if undefined or 0, all marker channels of each file are used. |
(Back to index)[/reference]
