# pspm_gaze_pp
[Back to index](/PsPM/ref/)

## Description

pspm_gaze_pp combines left/right gaze x and gaze y channels at the same time and will add two combined gaze channels, for the x and y coordinate.


## Format

`[sts, channel_index] = pspm_gaze_pp(fn)` or
`[sts, channel_index] = pspm_gaze_pp(fn, options)`


## Arguments

| Variable | Definition |
|:--|:--|
| fn | [string] Path to the PsPM file which contains the gaze data. |
| options | See following fields. |
| options.channel | gaze_x_r/gaze_x_l/gaze_y_r/gaze_y_l channels to work on. This can be a 4-element vector of channel numbers, or 'gaze', which will use the last channel of the types specified above. Default is 'gaze'. |
| options.channel_action | 'replace' existing gaze_x_c and gaze_y_c channels, or 'add' new ones (default). |

[Back to index](/PsPM/ref/)
