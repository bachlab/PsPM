---
layout: post
title: pspm_convert_gaze
permalink: /ref/pspm_convert_gaze
---


[Back to index](/PsPM/ref/)

## Description

pspm_convert_gaze converts between any gaze units or scanpath speed.

Display width and height are required for conversion from pixels to relate the screen pixel definition to metric units; and for conversion to degrees, to translate the coordinate system to the centre of the display.


## Format

`[sts, channel_index] = pspm_convert_gaze(fn, conversion, options)`


## Arguments

| Variable | Definition |
|:--|:--|
| fn | A data file name. |
| conversion | See following fields. |
| conversion.from | Original units of the source channel pair to convert from: 'pixel', a metric distance unit, or 'degree'. If in doubt, use the function 'pspm_display' to inspect the channels. |
| conversion.target | Target unit of conversion: a metric distance unit, 'degree' or 'sps'. |
| conversion.screen_width | Width of the display in mm (not required if 'from' is 'degree', or if both source and target are metric). |
| conversion.screen_height | Height of the display in mm (not required if 'from' is 'degree', or if both source and target are metric). |
| conversion.screen_distance | Eye distance from the screen in mm (not required if 'from' is 'degree', or if 'target' is metric). |
| options | See following fields. |
| options.channel | gaze x and y channels to work on. This can be a pair of channel numbers, any pair of channel types, 'gaze', which will search gaze_x and gaze_y channel according to the precedence order specified in pspm_load_channel. Default is 'gaze'. |
| options.channel_action | Channel action for sps data, add / replace existing sps data (default: add). |

[Back to index](/PsPM/ref/)
