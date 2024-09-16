# pspm_find_valid_fixations
## Description
pspm_find_valid_fixations finds deviations from a specified gaze fixation area. The primary usage of this function is to improve analyis of pupil size. Pupil size data will be incorrect when gaze is not in forward direction, due to foreshortening error. This function allows excluding pupil data points with too large foreshortening. To do so, it acts on one (or two) pupil channel(s), together with the associated x/y gaze channels which must have been converted to the correct units (distance units, or pixel units for bitmap fixation).

After finding the invalid fixations from the gaze channels, the corresponding data values in the pupil channel are set to NaN. In this usage of the function, a circle around fixation point defines the valid fixations. Note: an alternative or complement to this strategy is to explicitly correct the pupil foreshortening error, see pspm_pupil_correct and pspm_pupil_correct_eyelink.

An alternative usage of this function is to find fixations on a particular screen area, e.g. to define overt attention. In this usage, a bitmap of valid fixation points can be provided, as an alternative to the circle around fixation point. Since this usage is currently considered secondary, it still requires a valid pupil channel as primary channel, even though unrelated to pupil analysis.

In both usages, valid fixations can be outputted as additional channel.

By default, screen centre is assumed as fixation point. If an explicit fixation point is given, the function assumes that the screen is perpendicular to the vector from the eye to the fixation point (which is approximately correct for large enough screen distance).

## Format
`[sts, channel_index] = pspm_find_valid_fixations(fn, bitmap, options)` or
`[sts, channel_index] = pspm_find_valid_fixations(fn, circle_degree, distance, unit, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| fn | The actual data file containing the eyelink recording with gaze data converted to cm. |
| bitmap | A nxm matrix representing the display window and holding for each poisition a one, where a gaze value is valid. If there exists gaze data at a point with a zero value in the bitmap the corresponding data is set to NaN. IMPORTANT: the bitmap has to be defined in terms of the eyetracker coordinate system, i.e. bitmap(1,1) must correpond to the origin of the eyetracker coordinate system, and must be of the same size as the display. |
| circle_degree | Size of boundary circle given in degree visual angles. |
| distance | Distance between eye and screen in length units. |
| unit | Unit in which distance is given. |
| options | See following fields. |
| options.fixation_point | A nx2 vector containing x and y of the fixation point (with respect to the given resolution, and in the eyetracker coordinate system). n should equal either 1 (constant fixation point) or the length of the actual data. If resolution is not defined the values are given in percent. Therefore [0.5 0.5] would correspond to the middle of the screen. Default is [0.5 0.5]. Only taken into account if there is no bitmap. |
| options.resolution | Resolution with which the fixation point is defined (Maximum value of the x and y coordinates). This can be the screen resolution in pixels (e.g. [1280 1024]) or the width and height of the screen in cm (e.g. [50 30]). Default is [1 1]. Only taken into account if there is no bitmap. |
| options.plot_gaze_coords | Define whether to plot the gaze coordinates for visual inspection of the validation process. Default is false. |
| options.channel_action | Define whether to add or replace the data. Default is 'add'. Possible values are 'add' or 'replace'. |
| options.add_invalid | [0/1] If this option is enabled, an extra channel will be written containing information about the valid samples. Data points equal to 1 correspond to invalid fixation. Default is not to add this channel. |
| options.channel | Choose channels in which the data should be set to NaN during invalid fixations. This can be a channel number, any channel type including 'pupil' (which will select a channel according to the precedence order specified in pspm_load_channel), or 'both', which will work on 'pupil_r' and 'pupil_l' and then update channel statistics and best eye. The selected channel must be an eyetracker channel, and the file must contain the corresponding gaze channel(s) in the correct units: distance units for mode "fixation" and distance or pixel units for mode "bitmap". Default is 'pupil'. |
## References
[1] Korn CW & Bach DR (2016). A solid frame for the window on cognition: Modelling event-related pupil responses. Journal of Vision, 16:28,1-6.


