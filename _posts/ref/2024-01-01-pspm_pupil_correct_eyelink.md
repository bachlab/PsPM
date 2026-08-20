---
layout: post
title: pspm_pupil_correct_eyelink
permalink: /ref/pspm_pupil_correct_eyelink
---
 
[Back to index](/PsPM/ref/)

## Description

pspm_pupil_correct_eyelink performs pupil foreshortening error (PFE) correction specifically for data recorded and imported with an SR Research Eyelink eyetracker, following the steps described in reference [1]. 

For details of the exact scaling, see pspm_pupil_correct.

In order to perform PFE, we need both pupil and gaze data. 

Gaze data must be provided in mm. If gaze data is not in mm, it needs to be convert first using pspm_convert_gaze.


## Format

`[sts, channel_index] = pspm_pupil_correct_eyelink(fn, options)`


## Arguments

| Variable | Definition |
|:--|:--|
| fn | Path to a PsPM-imported EyeLink data file. Must be a char. |
| options | See following fields. |
| options.mode | Conversion mode. Must be one of 'auto' or 'manual'. If 'auto', then optimized conversion parameters in Table 3 of the reference will be used. In 'auto' mode, options struct must contain C_z parameter described below. Further, C_z must be one of 495, 525 or 625. The other parameters will be set according to which of these three C_z is equal to. If 'manual', then all of C_x, C_y, C_z, S_x, S_y, S_z fields must be provided according to your recording setup. Note that in order to use 'auto' mode, your camera-screen-eye setup must match exactly one of the three sample setups given in the reference. |
| options.C_z | See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>. |
| options.C_x | [optional] See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>. |
| options.C_y | [optional] See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>. |
| options.S_x | [optional] See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>. |
| options.S_y | [optional] See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>. |
| options.S_z | [optional] See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>. |
| options.channel | [optional][numeric/string] [Default: 'pupil'] Channel ID to be preprocessed. To process a specific eye, use 'pupil_l' or 'pupil_r'. To process the combined left and right eye, use 'pupil_c'. The default identifier 'pupil' will use the first existing option out of the following: (1) L-R-combined pupil; (2) non-lateralised pupil; (3) best eye pupil; (4) any pupil channel. If there are multiple channels of the specified type, only last one will be processed. You can also specify the number of a channel. |
| options.channel_action | [optional] ['add'/'replace'] Defines whether output data should be added or the corresponding preprocessed channel should be replaced. (Default: 'add'). |


## Outputs

| Variable | Definition |
|:--|:--|
| channel_index | index of channel containing the processed data. |


## References

[1] Hayes TR & Petrov AA (2016). Mapping and correcting the influence of gaze position on pupil size measurements. Behavior Research Methods, 48(2), 510–527.



[Back to index](/PsPM/ref/)
