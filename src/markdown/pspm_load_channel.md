# pspm_load_channel
## Format
`[sts, data_struct, infos, pos_of_channel, chantype_correct] = pspm_load_channel(fn, channel, channeltype)`

## Arguments
| Variable | Definition |
|:--|:--|
| fn | See following fields. |
| fn.infos | The information of the channel. |
| fn.data | The data of the channel. || channel | [numeric] / [char] / [struct] ▶ numeric: returns this channel (or the first of a vector) ▶ char 'marker' returns the first maker channel (see settings for permissible channel types) any other channel type (e.g. 'scr') returns the last channel of the respective type (see settings for permissible channel types) 'pupil', 'sps', 'gaze_x', 'gaze_y', 'blink', 'saccade', 'pupil_missing' (eyetracker channels) goes through the following precedence order, selects the first category that is found in the data, and returns the last channel of this category 1. Combined channels (e.g., 'pupil_c') 2. Non-lateralised channels (e.g., 'pupil') 3. Best eye pupil channels 4. Any pupil channels ▶ struct: with two fields as following (1) .channel: as defined for the 'char' option above; (2) .units: units of the channel. |
| channeltype | [char] optional; any channel type as permitted per pspm_init, 'wave', or 'events': checks whether retrieved data channel is of the specified type and gives a warning if not. |

## Outputs
| Variable | Definition |
|:--|:--|
| sts | [logical] 1 as default, -1 if unsuccessful. |
| data_struct | a struct with fields .data and .header, corresponding to a single cell of a data cell array returned by pspm_load_data. |
| infos | file infos as returned from pspm_load_data. |
| pos_of_channel | index of the returned channel. |

