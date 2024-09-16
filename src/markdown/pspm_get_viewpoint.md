# pspm_get_viewpoint
## Description
pspm_get_viewpoint imports Arrington Research ViewPoint EyeTracker files.

## Format
`[sts, import, sourceinfo] = pspm_get_viewpoint(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | Path to a ViewPoint EyeTracker data stored in ASCII format. |
| import | See following fields. |
| import.type | Type of the channel. Must be one of pupil_l, pupil_r, gaze_x_l, gaze_y_l, gaze_x_r, gaze_y_r, blink_l, blink_r, saccade_l, saccade_r, marker, custom. Right eye corresponds to eye A in ViewPoint; left eye corresponds to eye B. However, when there is only one eye in the data and in user input, they are matched. If the given channel type does not exist in the given datafile, it will be filled with NaNs and a warning will be emitted. The pupil diameter values returned by get_viewpoint are normalized ratio values reported by Viewpoint Eyetracker software. This is the ratio of the horizontal pupil diameter to the eyecamera window width. The gaze values returned are in the given target_unit. (x, y) = (0, 0) coordinate represents the top left corner of the whole stimulus window. x coordinates grow towards right and y coordinates grow towards bottom. The gaze coordinates can be negative or larger than screen size. These correspond to gaze positions outside the screen. Specified custom channels must correspond to some form of pupil/gaze channels. In addition, when the channel type is custom, no postprocessing/conversion is performed by pspm_get_viewponit and the channel is returned directly as it is in the given datafile. Blinks and saccades are read and can be imported if they are included in the given datafile as asynchronous messages. This corresponds to `Include Events in File` option in ViewPoint EyeTracker software. For a given eye, pupil and gaze values corresponding to blinks/saccades for that eye are set to NaN. |
| import.channel | [optional] If .type is custom, the index of the channel to import must be specified using this option. This value must be the channel index of the desired channel in the raw data columns. |
| import.target_unit | [optional] the unit to which the gaze data should be converted. This option has no effect for pupil diameter channel since that is always returned as ratio. (Default: mm). |
## Outputs
| Variable | Definition |
|:--|:--|
| import | See following fields. |
| import.data | Data channel corresponding to the input channel type or custom channel id. |
| import.units | Units of the channel. |
| import.sr | Sampling rate. |
| import.chan_id | Channel index of the imported channel in the raw data columns. |
