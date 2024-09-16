# pspm_multi_channel
## Description
pspm_multi_channel applies the same pre-processing function to multiple channels in the same data file. This works by calling the pre-processing function multiple times and so does accelerate processing time. It creates the required loop and handles any processing errors.

## Format
`[sts, channel_index] = pspm_multi_channel(function, channels, argument1, argument2, ..., options)`

## Arguments
| Variable | Definition |
|:--|:--|
| fhandle | [char or function handle] Preprocessing function. |
| channels | [char, vector, cell array] Channel specifications: 1. 'gaze' will be expanded to {'gaze_x_r', 'gaze_y_r', 'gaze_x_l', 'gaze_y_l'} 2. Eyetracker channels without lateralisation specification (_r or _l) will be expanded to include both eyes (i.e. 'pupil' will be expanded to {'pupil_r', 'pupil_l'}, which work on the last channel of this type. 3. Any other valid channel identifier of type 'char' will be expanded to all channels of this type in the file. 4. Any numerical vector or cell array will work on the specified channels exactly. |
| argument1 | all input arguments for the pre-processing function. |
| options | must always be specified as the last input argument. |

