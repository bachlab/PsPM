---
layout: default
title: Function reference
permalink: /reference/
---


### Data preparation

Data preparation functions create new data files.

[`pspm_trim`](reference/pspm_trim)
   
Cut away unused intervals of data.

[`pspm_split_sessions`](reference/pspm_split_sessions)

Split contiguous data into individual blocks or sessions.

[`pspm_merge`](reference/pspm_merge)

Stack multiple data files recorded simultaneously (e.g. by different equipment).

[`pspm_rename`](reference/pspm_rename)

Rename a PsPM data file and change its internal representation.

### Data preprocessing

Data preprocessing functions create new data channels.

[`pspm_combine_markerchannels`](reference/pspm_combine_markerchannels)

Combine multiple marker channels into one that can be used for a GLM definition.

[`pspm_convert_area2diameter`](reference/pspm_convert_area2diameter)

Convert pupil size from area to diameter.

[`pspm_convert_au2unit`](reference/pspm_convert_au2unit)

Convert pupil size from arbitrary units into metric units.

[`pspm_convert_ecg2hb`](reference/pspm_convert_ecg2hb)

Covert ECG data into heart beat time stamps using a modified Pan & Tompkins algorithm.

[`pspm_convert_ecg2hb_amri`](reference/pspm_convert_ecg2hb_amri)

Covert ECG data into heart beat time stamps using the AMRI algorithm.

[`pspm_convert_gaze`](reference/pspm_convert_gaze)

Convert gaze data between different units.

[`pspm_convert_hb2hp`](reference/pspm_convert_hb2hp)

Convert heart beat time stamps into interpolated heart period time series.

[`pspm_convert_ppg2hb`](reference/pspm_convert_ppg2hb)

Convert pulse oxymetry data into heart beat time stamps.

[`pspm_emg_pp`](reference/pspm_emg_pp)

Preprocess EMG data.

[`pspm_find_sounds`](reference/pspm_find_sounds)

Find sound onsets from sound recordings.

[`pspm_find_valid_fixations`](reference/pspm_find_valid_fixations)

Find valid fixations.

[`pspm_gaze_pp`](reference/pspm_gaze_pp)

Preprocess gaze data.

[`pspm_interpolate`](reference/pspm_interpolate) 

Interpolate missing values. (Creates a new data file if operating on all channels)

[`pspm_pp`](reference/pspm_pp)

Data filtering.

[`pspm_pupil_correct_eyelink`](reference/pspm_pupil_correct_eyelink)

Correct pupil foreshortening correction for data recorded on an Eyelink eyetracker system.

[`pspm_pupil_pp`](reference/pspm_pupil_pp)

Preprocess pupil data.

[`pspm_remove_epochs`](reference/pspm_remove_epochs) 

Remove missing data defined in a missing data epoch file. (Not available in GUI)

[`pspm_resp_pp`](reference/pspm_resp_pp)

Preprocess respiration data.


[`pspm_scr_pp`](reference/pspm_scr_pp)

Preprocess skin conductance data.

### Modelling 

Modelling functions create model files.

[`pspm_dcm`](reference/pspm_dcm)

Non-linear SCR model.

[`pspm_glm`](reference/pspm_glm)

General linear convolution model.

[`pspm_process_illuminance`](reference/pspm_process_illuminance)

Create illuminance regressors for pupil size GLM.

[`pspm_sf`](reference/pspm_sf)

Models for non-specific SCR (aka spontaneous fluctuations).

[`pspm_tam`](reference/pspm_tam) 

Model for trial averaged responses. (Not available in GUI)

[`pspm_export`](reference/pspm_exp)

Export model output.

### Tools
[`pspm_extract_segments`](reference/pspm_extract_segments)

Extract data segments from data file.

[`pspm_get_markerinfo`](reference/pspm_get_markerinfo)

Extract marker information from data file.

---
