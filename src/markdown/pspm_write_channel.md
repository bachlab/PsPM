# pspm_write_channel
## Description
pspm_write_channel adds, replaces and deletes channels in an existing data file. This function is an integration of the former functions pspm_add_channel and pspm_rewrite_channel.

## Format
`[sts, infos] = pspm_write_channel(fn, newdata, channel_action, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| fn | data file name. |
| newdata | [struct()/empty] is either a new data struct or a cell array of new data structs. |
| channel_action | accepts 'add'/'replace'/'delete'. 'add': add newdata as a new channel 'replace': replace last channel of the same type, or channel indicated with options.channel with given newdata. If no channel of the same type found, or if the channel given in options.channel is of a different type, then newdata will be added as new channel 'delete': remove channel given with options.channel. |
| options | See following fields. |
| options.msg | custom history message [char/struct()]. |
| options.prefix | custom history message prefix text, but automatically added action verb (only prefix defined). The text will be <prefix> <action> ed on <date>. |
| options.channel | Specify which channel should be 'edited'. Default as 0. |
| options.delete | method to look for a channel when options.channel is not an integer, accepts 'last'/'first'/'all'. 'last': (default) deletes last occurence of the given channeltype 'first': deletes the first occurence 'all': removes all occurences. |
## Outputs
| Variable | Definition |
|:--|:--|
| sts | the status of the function. |
| infos | See following fields. |
| infos.channel | contains channel id of added / replaced / deleted channels. |
