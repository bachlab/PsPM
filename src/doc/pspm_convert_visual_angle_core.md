# pspm_convert_visual_angle_core
## Description
pspm_convert_visual_angle_core computes from gaze data the corresponding visual angle (for each data point). The convention used here is that the origin of coordinate system for gaze data is at the bottom left corner of the screen.

## Format
`[lon, lat, lon_range, lat_range] = pspm_convert_visual_angle_core(x_data, y_data, width, height, distance)`

## Arguments
| Variable | Definition |
|:--|:--|
| x_data | X axis data. |
| y_data | y axis data. |
| width | screen width in same units as data. |
| height | screen height in same units as data. |
| distance | screen distance in same units as data. |

