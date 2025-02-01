---
layout: post
title: pspm_convert_ecg2hb
permalink: /ref/pspm_convert_ecg2hb
---
 
[Back to index](/PsPM/ref/)

## Description

pspm_convert_ecg2hb identifies the position of QRS complexes in ECG data and writes them as heart beat channel into the datafile. This function implements the algorithm by Pan & Tompkins (1985) with some adjustments described in the function help under Developer's notes.


## Format

`[sts, channel_index, quality_info] = pspm_convert_ecg2hb(fn, options)`


## Arguments

| Variable | Definition |
|:--|:--|
| fn | data file name. |
| options | See following fields. |
| options.channel | [optional, numeric/string, default: 'ecg', i.e. last ECG channel in the file] Channel type or channel ID to be preprocessed. Channel can be specified by its index (numeric) in the file, or by channel type (string). If there are multiple channels with this type, only the last one will be processed. If you want to detect R-peaks for several ECG channels in a PsPM file, call this function multiple times with the index of each channel. In this case, set the option 'channel_action' to 'add', to store each resulting 'hb' channel separately. |
| options.semi | Activates the semi automatic mode, allowing the handcorrection of all IBIs that fulfill: >/< mean(ibi) +/- 3 * std(ibi) [def. 0]. |
| options.minHR | Minimal HR [def. 20bpm]. |
| options.maxHR | Maximal HR [def. 200bpm]. |
| options.debugmode | [numeric, default as 0] Runs the algorithm in debugmode (additional results in debug variable 'infos.pt_debug') and plots a graph that allows quality checks. |
| options.twthresh | Sets the threshold to perform the twave check. [def. 0.36s]. |
| options.channel_action | ['add'/'replace', default as 'replace'] Defines whether the new channel should be added or the previous outputs of this function should be replaced. |


[Back to index](/PsPM/ref/)
