# pspm_select_channels
## Description
pspm_select_channels selects one or several channels from a provided data cell array, according to channel type and units.

## Format
`[sts, data, pos_of_channels] = pspm_select_channels(data, channel, units)`

## Arguments
| Variable | Definition |
|:--|:--|
| data | A data cell array as loaded by pspm_load_data. |
| channel | [numeric/char] If specified as a numeric vector, the function returns these channels. If specified as a char, (1) any permissible channel type will return the respective channels, unless the channel type is in category; (2) eyetracker channel specification including 'gaze' will return channels with names that start with the specified char; (3) 'events' or 'wave': returns all channels of this type. |
| units | Any units definition (e.g., 'mm' or 'V') - can be omitted. |

