# pspm_get_smi
## Description
pspm_get_smi imports SensoMotoric Instruments iView X EyeTracker files.

## Format
`[sts, import, sourceinfo] = pspm_get_smi(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | String or cell array of strings. The size of the cell array can be 1 or 2. If datafile is string, it must be the path to the sample file containing eye measuremnts. The file must be stored in ASCII format. If datafile is a cell array, the first element must be the path to the sample file defined above. The optional second string in the cell array can be the event file containing blink/saccade events. The file must be stored in ASCII format. |
| import | See following fields. |
| import.type | Type of the channel. Must be one of pupil_l, pupil_r, gaze_x_l, gaze_y_l, gaze_x_r, gaze_y_r, blink_l, blink_r, saccade_l, saccade_r, marker, custom. If the given channel type does not exist in the given datafile, it will be filled with NaNs and a warning will be emitted. Specified custom channels must correspond to some form of pupil/gaze channels. In addition, when the channel type is custom, no postprocessing/conversion is performed by pspm_get_smi and the channel is returned directly as it is in the given datafile. The gaze values returned are in the given target_unit. (x, y) = (0, 0) coordinate represents the top left corner of the calibration area. x coordinates grow towards right and y coordinates grow towards bottom. The gaze coordinates can be negative or larger than calibration area axis length. These correspond to gaze positions outside the calibration area. Since there are multiple ways to specify pupil size in SMI files, pspm_get_smi selects the channel according to the following precendence order (earlier items have precedence): 1. Mapped Diameter (mm) 2. Dia X (mm) 3. Dia (mm2) 4. Dia X (pixel) 5. Dia (pixel2) If a pixel/pixel2 channels is chosen, it is NOT converted to a mm/mm2 channel. It is returned as it is. In mm2/pixel2 case, the pupil is assumed to be a circle. Therefore, diameter d from area a is calculated as 2*sqrt(a/pi). |
| import.channel | [optional] If .type is custom, the index of the channel to import must be specified using this option. |
| import.stimulus_resolution | [optional] An array of length 2 storing the screen resolution of the whole stimulus window in pixels. This resolution is required in order to perform pixel to mm conversions. If not given, no manual conversion is performed by get_smi and all the values are returned as they are in the datafile. |
| import.target_unit | [optional] the unit to which the gaze data should be converted. Used only if stimulus_resolution is specified. (Default: mm) [Each import structure will get the following output fields]. |
| import.data | [optional] Data channel corresponding to the input channel type or custom channel id. |
| import.units | [optional] Units of the channel. |
| import.sr | [optional] Sampling rate. |
| import.chan_id | [optional] Channel index of the imported channel in the raw data columns. |
