# pspm_load_gaze
## Description
This function extracts the eye location (r, l, c, global) from chantype and loads the corresponding gaze_x and gaze_y channels.

## Format
`[sts, gaze_x, gaze_y, eye] = pspm_load_gaze (fn, channel)`

## Arguments
| Variable | Definition |
|:--|:--|
| fn | [string] / [struct] Path to a PsPM file, or a struct accepted by pspm_load_data. |
| chantype | Definition of an eyetracker channel to which the gaze should correspond, or one of {'r', 'l', 'c', ''}. |

## Outputs
| Variable | Definition |
|:--|:--|
| gaze_x | struct with fields .data and .header as returned by pspm_load_channel. |
| gaze_y | struct with fields .data and .header as returned by pspm_load_channel. |
| eye | one of {'r', 'l', 'c', ''}. |

