---
layout: post
title: pspm_resp_pp
permalink: /ref/pspm_resp_pp
---
 
[Back to index](/PsPM/ref/)

## Description

pspm_resp_pp preprocesses raw respiration traces. The function detects respiration cycles for bellows and cushion systems and creates respiration time stamps (rs), computes respiration period (rp), amplitude (ra) and respiratory flow rate (rfr), assigns these measures to the start of each cycle and linearly interpolates these. The output data type can be restricted in options; otherwise all four outputs are created.


## Format

`[sts, channel_index] = pspm_resp_pp(fn, sr, options)`


## Arguments

| Variable | Definition |
|:--|:--|
| fn | data file name. |
| sr | sample rate for new interpolated channel. This will be ignored if the chosen output is only respiration time stamps. |
| options | See following fields. |
| options.channel | [optional, numeric/string, default: 'resp', i.e. last respiration channel in the file] Channel type or channel ID to be preprocessed. Channel can be specified by its index (numeric) in the file, or by channel type (string). If there are multiple channels with this type, only the last one will be processed. If you want to preprocess several respiration in a PsPM file, call this function multiple times with the index of each channel. In this case, set the option 'channel_action' to 'add', to store each resulting channel separately. |
| options.systemtype | ['bellows'(default) /'cushion'] Bellows system (increased air flow upon inspiration) or cushion system (increased air pressure upon inspiration). |
| options.datatype | a cell array with any of 'rp', 'ra', 'rfr', 'rs', 'all' (default). |
| options.plot | [0/1] Create a respiratory cycle detection plot. |
| options.channel_action | ['add'(default) /'replace'] Defines whether the new channels should be added or the corresponding channel should be replaced. |


## References

[1] Bach DR, Gerster S, Tzovara A, Castegnetti G (2016). A linear model for event-related respiration responses. Journal of Neuroscience Methods, 270, 174-155.



[Back to index](/PsPM/ref/)
