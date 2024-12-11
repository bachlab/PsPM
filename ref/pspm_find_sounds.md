# pspm_find_sounds
[Back to index](/PsPM/ref/)

## Description

pspm_find_sounds finds (and if requested analyzes) sound events in a PsPM data file. This function can be used to precisely define the onset of startle sounds for GLM-based analysis of startle eye blink data. The detected events are written into a marker channel. 

A sound is detected as event if it is longer than 10 ms, and events are recognized as distinct if they are at least 50 ms appart. Various options allow customizing the algorithm to specific experimental settings. In particular, events can be constrained to be in the vicinity of event markers, and/or a desired number of events can be specified. 


## Format

`[sts, channel_index, info] = pspm_find_sounds(fn, options)`


## Arguments

| Variable | Definition |
|:--|:--|
| fn | path and filename of the pspm file holding the sound. |
| options | See following fields. |
| options.channel | [optional, numeric/string, default: 'snd', i.e. last sound channel in the file] Channel type or channel ID to be preprocessed. Channel can be specified by its index (numeric) in the file, or by channel type (string). If there are multiple channels with this type, only the last one will be processed. If you want to preprocess several sound in a PsPM file, call this function multiple times with the index of each channel. In this case, set the option 'channel_action' to 'add', to store each resulting channel separately. |
| options.channel_action | ['add'/'replace'] sound events are written as marker channel to the specified pspm file. Onset times then correspond to marker events and duration is written to markerinfo. The values 'add' or 'replace' state whether existing marker channels should be replaced (last found marker channel will be overwritten) or whether the new channel should be added at the end of the data file. Default is 'add'. |
| options.diagnostics | [0 (default) or 1] Computes the delay between marker and detected sound, displays the mean delay and standard deviation. |
| options.maxdelay | [number] Upper limit (in seconds) of the window in which pspm_find_sounds will accept sounds as relating to a marker. Default as 3 s. |
| options.mindelay | [number] Lower limit (in seconds) of the window in which pspm_find_sounds will accept sounds as relating to a marker. Default is 0 s. |
| options.plot | [0(default) or 1] Display a histogramm of the delays found and a plot with the detected sound, the trigger and the onset of the sound events. These are color coded for delay, from green (smallest delay) to red (longest). Forces the 'diagnostics' option to true. |
| options.channel_output | ['all'/'corrected'; 'corrected' requires enabled diagnostics, but does not force it (the option will otherwise not work).] Defines whether all sound events or only sound events which were related to an existing marker should be written into the output marker channel. Default is all sound events. |
| options.resample | [integer] Spline interpolates the sound by the factor specified. (1 for no interpolation, by default). Caution must be used when using this option. It should only be used when following conditions are met: (1) All frequencies are well below the Nyquist frequency; (2) The signal is sinusoidal or composed of multiple sin waves all respecting condition 1. Resampling will restore more or less the original signal and lead to more accurate timings. |
| options.roi | [vector of 2 floats] Region of interest for discovering sounds. Especially useful if pairing events with markers. Only sounds included inbetween the 2 timestamps will be considered. |
| options.threshold | [0...1] percent of the max of the power in the signal that will be accepted as a sound event. Default is 0.1. |
| options.marker_chan_num | [integer] number of a channel holding markers. By default first 'marker' channel. |
| options.expectedSoundCount | [integer] Checks for correct number of detected sounds. If too few are found, lowers threshold until at least specified count is reached. Threshold is lowered by .01 until 0.05 is reached for a max of 95 iterations. This is a EXPERIMENTAL variable, use with caution!. |

[Back to index](/PsPM/ref/)
