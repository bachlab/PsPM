---
layout: post
title: pspm_glm
permalink: /ref/pspm_glm
---
 
[Back to index](/PsPM/ref/)

## Description

pspm_glm specifies a within-subject general linear convolution model (GLM) of predicted signals and calculates amplitude estimates for these responses.

GLMs can be used for analysing evoked responses that follow an event with (approximately) fixed latency. This is similar to standard analysis of fMRI data. 

The user specifies events for different conditions. These are used to estimate the mean response amplitude per condition. These mean amplitudes can later be expored for statistical analysis, using pspm_export.


## Format

`[sts, glm] = pspm_glm(model, options)`


## Arguments

| Variable | Definition |
|:--|:--|
| model | See following fields. |
| model.modelfile | a file name for the model output. |
| model.datafile | a file name (single session) OR a cell array of file names. |
| model.timing | a multiple condition file name (single session) OR a cell array of multiple condition file names OR a struct (single session) with fields .names, .onsets, and (optional) .durations and .pmod OR a cell array of struct OR a struct with fields 'markervalues' and 'names' (when model.timeunits is set to be 'markervalues') OR a cell array of struct. |
| model.timeunits | one of 'seconds', 'samples', 'markers', 'markervalues'. |
| model.modelspec | [optional] 'scr' (default); specify the model to be used. See pspm_init, defaults.glm() which modelspecs are possible with glm. |
| model.modality | [optional] specify the data modality to be processed. When model.modality is set to be sps, the model.channel should be set among sps_l, sps_r, or defaultly sps. By default, this is determined automatically from "modelspec". |
| model.bf | [optional] basis function/basis set; modality specific default with subfields .fhandle (function handle or string) and .args (arguments, first argument sampling interval will be added by pspm_glm). The optional subfield .shiftbf = n indicates that the onset of the basis function precedes event onsets by n seconds (default: 0: used for interpolated data channels). |
| model.channel | [optional] channel number or channel type. if a channel type is specified the LAST channel matching the given type will be used. The rationale for this is that, in general channels later in the channel list are preprocessed/filtered versions of raw channels. SPECIAL: if 'pupil' is specified the function uses the last pupil channel returned by <a href="matlab:help pspm_load_data">pspm_load_data</a>. pspm_load_data loads 'pupil' channels according to a specific precedence order described in its documentation. In a nutshell, it prefers preprocessed channels and channels from the best eye to other pupil channels. SPECIAL: for the modality 'sps', the model.channel accepts only 'sps_l', 'sps_r', or 'sps'. DEFAULT: last channel of the specified modality (for PSR this is 'pupil'). |
| model.norm | [optional] normalise data; default 0. |
| model.filter | [optional] filter settings; modality specific default. |
| model.missing | [optional] allows to specify missing (e. g. artefact) epochs in the data file. See pspm_get_timing for epoch definition; specify a cell array for multiple input files. This must always be specified in SECONDS. Default: no missing values. |
| model.nuisance | [optional] Allows to specify nuisance regressors. Must be a file name; the file is either a .txt file containing the regressors in columns, or a .mat file containing the regressors in a matrix variable called R. There must be as many values for each column of R as there are data values. SCRalyze will call these regressors R1, R2, ... |
| model.latency | [optional] Specify whether latency should be 'fixed' (default) or 'free'. In 'free' models an additional dictionary matching algorithm will try to estimate the best latency. Latencies will then be added at the end of the output. In 'free' models the field model.window is MANDATORY and single basis functions are allowed only. |
| model.window | Only required if model.latency equals 'free' and ignored otherwise. A scalar or 2-element vector in seconds that specifies over which time window (relative to the event onsets specified in model.timing) the model should be evaluated. Positive values mean that the response function is shifted to later time points, negative values that it is shifted to earlier time points. |
| model.centering | [optional] If set to 0 the function would not perform the mean centering of the convolved X data. For example, to invert SPS model, set centering to 0. Default: 1. |
| options | See following fields. |
| options.overwrite | [optional] logical, 0 or 1. Define whether to overwrite existing output files or not. Default value: determined by pspm_overwrite. |
| options.marker_chan_num | [optional] marker channel number; default first marker channel. |
| options.exclude_missing | [optional] marks trials during which NaN percentage exceeds a cutoff value. Requires two subfields: 'segment_length' (in s after onset) and 'cutoff' (in % NaN per segment). Results are written into model structure as fields .stats_missing and .stats_exclude but not used further. |


## Outputs

| Variable | Definition |
|:--|:--|
| glm | a structure 'glm' which is also written to file. |


## References

* Skin conductance response analysis

[1] GLM for SCR: Bach DR, Flandin G, Friston KJ, Dolan RJ (2009). Time-series analysis for rapid event-related skin conductance responses. Journal of Neuroscience Methods, 184, 224-234.

[2] Canonical skin conductance response function, and GLM assumptions: Bach DR, Flandin G, Friston KJ, Dolan RJ (2010). Modelling event-related skin conductance responses. International Journal of Psychophysiology, 75, 349-356.

[3] Validating GLM assumptions with intraneural recordings: Gerster S, Namer B, Elam M, Bach DR (2018). Testing a linear time invariant model for skin conductance responses by intraneural recording and stimulation. Psychophysiology, 55, e12986.

[4] Fine-tuning of SCR CLM: Bach DR, Friston KJ, Dolan RJ (2013). An improved algorithm for model-based analysis of evoked skin conductance responses. Biological Psychology, 94, 490-497.

[5] SCR GLM validation and comparison with Ledalab: Bach DR (2014). A head-to-head comparison of SCRalyze and Ledalab, two model-based methods for skin conductance analysis. Biological Psychology, 103, 63-88.

* Pupil size analysis

[6] GLM for fear-conditioned pupil dilation: Korn CK, Staib M, Tzovara A, Castegnetti G, Bach DR (2017). A pupil size response model to assess fear learning. Psychophysiology, 54, 330-343.

* Heart rate/period analysis

[7] GLM for evoked heart period responses: Paulus PC, Castegnetti G, & Bach DR (2016). Modeling event-related heart period responses. Psychophysiology, 53, 837-846.

[8] GLM for fear-conditioned bradycardia: Castegnetti G, Tzovara A, Staib M, Paulus PC, Hofer N, & Bach DR (2016). Modelling fear-conditioned bradycardia in humans. Psychophysiology, 53, 930-939.

[9] GLM for reward-conditioned bradycardia: Xia Y, Liu H, Kälin OK, Gerster S, Bach DR (under review). Measuring human Pavlovian appetitive conditioning and memory retention.

* Respiration analysis

[10] GLM for evoked respiratory responses: Bach DR, Gerster S, Tzovara A, Castegnetti G (2016). A linear model for event-related respiration responses. Journal of Neuroscience Methods, 270, 174-155.

[11] GLM for fear-conditioned respiration amplitude responses: Castegnetti G, Tzovara A, Staib M, Gerster S, Bach DR (2017). Assessing fear learning via conditioned respiratory amplitude responses. Psychophysiology, 54, 215-223.

* Startle eye-blink analysis

[12] GLM for startle eye-blink responses: Khemka S, Tzovara A, Gerster S, Quednow B and Bach DR (2017) Modeling Startle Eyeblink Electromyogram to Assess Fear Learning. Psychophysiology

* Eye gaze analysis

[13] GLM for saccadic scanpath speed: Xia Y, Melinščak F, Bach DR (2020). Saccadic scanpath length: an index for human threat conditioning. Behavior Research Methods, 53, 1426-1439.



[Back to index](/PsPM/ref/)

