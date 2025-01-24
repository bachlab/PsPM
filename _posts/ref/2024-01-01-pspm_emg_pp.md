---
layout: post
title: pspm_emg_pp
permalink: /ref/pspm_emg_pp
---


[Back to index](/PsPM/ref/)

## Description

pspm_emg_pp pre-processes startle eyeblink EMG data in 3 steps, which were optimised in reference [1].

(1) Initial filtering: 4th order Butterworth with 50 Hz and 470 Hz cutoff frequencies.

(2) Removing mains noise: adjustable notch filter (default 50 Hz).

(3) Smoothing and rectifying: 4th order Butterworth low-pass filter with a time constant of 3 ms (corresponding to a cutoff of 53.05 Hz).

While the input data must be an EMG channel, the output channel will be of type emg_pp, as required by the startle eyeblink GLM.


## Format

`[sts, channel_index] = pspm_emg_pp(fn, options)`


## Arguments

| Variable | Definition |
|:--|:--|
| fn | [string] Path to the PsPM file which contains the EMG data. |
| options | See following fields. |
| options.mains_freq | [integer] Frequency of mains noise to remove with notch filter (default: 50 Hz). |
| options.channel | [numeric/string] Channel to be preprocessed. Can be a channel ID or a channel name. Default is 'emg' (i.e. last EMG channel). |
| options.channel_action | ['add'/'replace'] Defines whether the new channel should be added or the previous outputs of this function should be replaced. (Default: 'replace'). |

## References

[1] Khemka S, Tzovara A, Gerster S, Quednow BB, Bach DR (2017). Modelling startle eye blink electromyogram to assess fear learning. Psychophysiology, 54, 202-214.



[Back to index](/PsPM/ref/)
