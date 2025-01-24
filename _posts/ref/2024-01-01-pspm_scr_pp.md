---
layout: post
title: pspm_scr_pp
permalink: /ref/pspm_scr_pp
---


[Back to index](/PsPM/ref/)

## Description

pspm_scr_pp implements a simple skin conductance response (SCR) quality check according to the following steps: (1) Microsiemens values must be within range (0.05 to 60). 

(2) Absolute slope of value change must be less than 10 microsiemens per second. 

(3) Clipping detection: value stays constant at a floor or ceiling.

(4) Detect and remove data islands neighboured by artefacts.

If a missing epochs filename is specified, the detected epochs will be written to a missing epochs file to be used for GLM (recommended). Otherwise, the function will create a channel in the original data file in which the respective data are changed to NaN (either adding this channel or replacing the original one).


## Format

`[sts, channel_index] = pspm_scr_pp(data, options)` or
`[sts, missing_epochs_file] = pspm_scr_pp(data, options)`


## Arguments

| Variable | Definition |
|:--|:--|
| datafile | a file name. |
| options | See following fields. |
| options.channel | [optional, numeric/string, default: 'scr', i.e. last SCR channel in the file] Channel type or channel ID to be preprocessed. Channel can be specified by its index (numeric) in the file, or by channel type (string). If there are multiple channels with this type, only the last one will be processed. If you want to preprocess several SCR in a PsPM file, call this function multiple times with the index of each channel. In this case, set the option 'channel_action' to 'add', to store each resulting 'scr' channel separately. |
| options.min | [Optional] Minimum value in microsiemens (default: 0.05). |
| options.max | [Optional] Maximum value in microsiemens (default: 60). |
| options.slope | [Optional] Maximum slope in microsiemens per sec (default: 10). |
| options.missing_epochs_filename | [Optional] If a missing epochs file name is specified, then the missing epochs will be saved to this file. In this case, data in the original datafile will remain unchanged; otherwise a channel will be written to the same file. |
| options.deflection_threshold | [Optional] Define an threshold in original data units for a slope to pass to be considered in the filter. This is useful, for example, with oscillatory wave data due to limited A/D bandwidth. The slope may be steep due to a jump between voltages but we likely do not want to consider this to be filtered. A value of 0.1 would filter oscillatory behaviour with threshold less than 0.1v but not greater. Default: 0.1. |
| options.data_island_threshold | [Optional] A float in seconds to determine the maximum length of data between NaN epochs. Islands of data shorter than this threshold will be removed. Default: 0 s - no effect on filter. |
| options.expand_epochs | [Optional] A float in seconds to determine by how much data on the flanks of artefact epochs will be removed. Default: 0.5 s. |
| options.clipping_step_size | [Optional] A numerical value specifying the step size in moving average algorithm for detecting clipping. Default: 10. |
| options.clipping_window_size | [Optional] A numerical value specifying the window size in moving average algorithm for detecting clipping. Default: 100. |
| options.clipping_threshold | [Optional] A float between 0 and 1 specifying the proportion of local maximum in a step. Default: 0.1. |
| options.baseline_jump | [Optional] A numerical value to determine how many times of data jumpping will be considered for detecting baseline alteration. For example, when .baseline is set to be 2, if the maximum value of the window is more than 2 times than the 5% percentile of the values in the window, such periods will be considered as baseline alteration. Default: 1.5. |
| options.include_baseline | [Optional] A bool value to determine if detected baseline alteration will be included in the calculated clippings. Default: 0 (not to include baseline alteration in clippings). |
| options.overwrite | [logical] (0 or 1) [Optional] Define whether to overwrite existing missing epochs files or not (default). Will only be used if options.missing_epochs_filename is specified. |
| options.channel_action | [Optional] Accepted values: 'add'/'replace' Defines whether the new channel should be added or the previous outputs of this function should be replaced. Default: 'add'. Will not be used if options.missing_epochs_filename is specified. |

## Outputs

| Variable | Definition |
|:--|:--|
| channel_index | index of channel containing the processed data. |
| missing_epochs_file | file that contains the missing epochs. |


## References

[1] Kleckner IR et al. (2018). "Simple, Transparent, and Flexible  Automated Quality Assessment Procedures for Ambulatory Electrodermal  Activity Data. IEEE Transactions on Biomedical Engineering, 65 (7),  1460-1467.



[Back to index](/PsPM/ref/)
