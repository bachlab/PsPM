# pspm_convert_pixel2unit_core
## Description
pspm_convert_pixel2unit_core converts gaze data from pixel to units.

## Format
`[sts, out_data, out_range] = pspm_convert_pixel2unit_core(data, screen_length)`

## Arguments
| Variable | Definition |
|:--|:--|
| data | Original data in pixels. No checks are performed. |
| range | Original range in pixels. |
| screen_length | Screen width for gaze_x data, or screen height for gaze_y data, in mm. |

