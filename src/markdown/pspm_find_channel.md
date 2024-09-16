# pspm_find_channel
## Description
pspm_find_channel searches a cell arrays of channel headers and finds the channel that matches the desired type.

## Format
`channel = pspm_find_channel(headercell, channeltype)`

## Arguments
| Variable | Definition |
|:--|:--|
| headercell | cell array of names (e.g. from acq import). |
| channeltype | an allowed channel type (char) (or a cell array of possible channel names for operations on non-allowed input channel types). |

## Outputs
| Variable | Definition |
|:--|:--|
| channel | the channel number (not physical channel number) that matches namestrings. 0 if no channel matches namestrings -1 if more than one channel matches namestrings. |

