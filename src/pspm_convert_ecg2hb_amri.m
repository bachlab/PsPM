function [sts, out_channel] = pspm_convert_ecg2hb_amri(fn, options)
% ● Description
%   pspm_convert_ecg2hb_amri performs R-peak detection from an ECG signal using the steps
%   decribed in R-peak detection section of [1]. This function uses a modified version of
%   the original amri_eeg_rpeak.m code that can be obtained from [2]. The modified version with a list
%   of changes made is provided with PsPM in the amri_eegfmri directory.
% ● Format
%   [sts, channel_index] = pspm_convert_ecg2hb_amri(fn)
%   [sts, channel_index] = pspm_convert_ecg2hb_amri(fn, options)
% ● Arguments
%   *            fn : [string] Path to the PsPM file which contains the pupil data.
%   ┌───────options
%   ├──────.channel : [optional, numeric/string, default: 'ecg', i.e. last ECG channel in
%   │                 the file]
%   │                 Channel type or channel ID to be preprocessed. Channel can be
%   │                 specified by its index (numeric) in the file, or by channel type
%   │                 (string). If there are multiple channels with this type, only the
%   │                 last one will be processed. If you want to detect R-peaks for
%   │                 several ECG channels in a PsPM file, call this function multiple
%   │                 times with the index of each channel. In this case, set the option
%   │                 'channel_action' to 'add', to store each resulting 'hb' channel
%   │                 separately.
%   ├.signal_to_use : ['ecg'/'teo'/'auto', default as 'auto']
%   │                 Choose which signal will be used as the input to the core R-peak
%   │                 detection steps.
%   │                 (1) If 'ecg', filtered ECG signal will be used.
%   │                 (2) If 'teo', Teager Enery Operator will be applied to the filtered
%   │                     ECG signal before feeding it to R-peak finding part.
%   │                 (3) If 'auto', the option that results in the higher maximal
%   │                     auto-correlation will be used.
%   ├──────.hrrange : [numeric, unit: beats per minute] Minimum and maximum heartbeat
%   │                 rates (BPM) to use in the algorithm. Must be a numeric array of
%   │                 length 2, i.e.[min_bpm max_bpm]. Default as [20 200].
%   ├─.ecg_bandpass : [numeric, unit: Hz] Minimum and maximum frequencies to use during
%   │                 bandpass filter of the raw ECG signal to construct filtered ECG
%   │                 signal. Default as [0.5 40].
%   ├─.teo_bandpass : [numeric, unit: Hz, default as [8 40]]
%   │                 Minimum and maximum frequencies to use during bandpass filter of
%   │                 filtered ECG signal to construct TEO input signal.
%   ├────.teo_order : [numeric, default as 1]
%   │                 Order of the TEO operator. Must be integer. For a discrete time
%   │                 signal x(t) and order k,
%   │                 TEO[x(t); k] is defined as
%   │                 TEO[x(t); k] = x(t)x(t) - x(t-k)x(t+k).
%   ├.min_cross_corr: [numeric, default as 0.5]
%   │                 Minimum cross correlation between a candidate R-peak and the
%   │                 found template such that the candidate is classified as an R-peak.
%   ├.min_relative_amplitude: [numeric, default as 0.4]
%   │                 Minimum relative peak amplitude of a candidate R-peak such that it
%   │                 is classified as an R-peak.
%   └.channel_action: ['add'/'replace'] Defines whether corrected data should be added
%                     or the corresponding preprocessed channel should be replaced.
%                     Note that 'replace' mode does not replace the raw data channel,
%                     but a previously stored heartbeat channel. Default as 'replace'.
% ● Outputs
%   *            sts: status marker showing whether the function works normally.
%   *  channel_index: index of channel containing the processed data
% ● References
%   [1] Liu, Zhongming, et al. "Statistical feature extraction for artifact
%       removal from concurrent fMRI-EEG recordings." Neuroimage 59.3 (2012):
%       2073-2087.
%   [2] http://www.amri.ninds.nih.gov/software.html
% ● History
%   Written in 2019 by Eshref Yozdemir (University of Zurich)
%   Updated in 2022 by Teddy

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
out_channel = [];

%% create default arguments
if nargin < 2
  options = struct();
end
options = pspm_options(options, 'convert_ecg2hb_amri');
if options.invalid
  return
end
%% load
[lsts, data] = pspm_load_channel(fn, options.channel, 'ecg');
if lsts ~= 1; return; end
%% process
addpath(pspm_path('ext','amri_eegfmri'));
ecg.data = data.data;
ecg.srate = data.header.sr;
rpeak_logic_vec = amri_eeg_rpeak(ecg, ...
  'WhatIsY', options.signal_to_use, ...
  'PulseRate', options.hrrange, ...
  'TEOParams', [options.teo_order options.teo_bandpass], ...
  'ECGcutoff', options.ecg_bandpass, ...
  'mincc', options.min_cross_corr, ...
  'minrpa', options.min_relative_amplitude ...
  );
heartbeats{1}.data = find(rpeak_logic_vec) / ecg.srate;
rmpath(pspm_path('ext','amri_eegfmri'));
%% save
heartbeats{1}.header.sr = 1;
heartbeats{1}.header.chantype = 'hb';
heartbeats{1}.header.units = 'events';
o.msg.prefix = 'QRS detection using AMRI algorithm';
[lsts, infos] = pspm_write_channel(fn, heartbeats, options.channel_action);
if lsts ~= 1; return; end
out_channel = infos.channel;
sts = 1;
