function [sts, out_channel] = pspm_ecg2hb_amri(fn, options)
% ● Description
%   pspm_ecg2hb_amri performs R-peak detection from an ECG signal using the steps
%   decribed in R-peak detection section of [1]. This function uses a modified
%   version of the amri_eeg_rpeak.m code that can be obtained from [2]. Modified
%   version with a list of changes made is shipped with PsPM under amri_eegfmri
%   directory.
%   Once the R-peaks are computed, according to the option 'channel_action',
%   it will either replace an existing heartbeat channel or add it as a new
%   channel to the provided file.
% ● Format
%   [sts, out_channel] = pspm_ecg2hb_amri(fn)
%   [sts, out_channel] = pspm_ecg2hb_amri(fn, options)
% ● Arguments
%                 fn: [string] Path to the PsPM file which contains the pupil
%                     data.
%   ┌─────── options
%   ├───────.channel: [optional, numeric/string, default as 'ecg']
%   │                 Channel ID to be preprocessed.
%   │                 Channel can be specified by its index in the given PsPM
%   │                 data structure. 
%   │                 It will be preprocessed as long as it is a valid ECG
%   │                 channel.
%   │                 If there are multiple channels with 'ecg' type, only
%   │                 the last one will be processed. If you want to detect
%   │                 r-peaks for all ECG channels in a PsPM file separately,
%   │                 call this function multiple times with the index of
%   │                 each channel.  Further, use 'add' mode to store each
%   │                 resulting 'heartbeat' channel separately.
%   ├─ signal_to_use: ['ecg'/'teo'/'auto', default as 'auto'] 
%   │                 Choose which signal will be used as the input to the core
%   │                 R-peak detection steps. When 'ecg', filtered ECG signal
%   │                 will be used. 
%   │                 When 'teo',
%   │                 Teager Enery Operator will be applied to the filtered
%   │                 ECG signal before feeding it to R-peak finding part.
%   │                 When 'auto'
%   │                 the option that results in the higher maximal 
%   │                 autocorrelation will be used.
%   ├─────── hrrange: [numeric] Minimum and maximum heartbeat rates (BPM)
%   │                 to use in the algorithm. Must be a numeric array of
%   │                 length 2, i.e. [min_bpm max_bpm].
%   │                 (Default: [20 200])
%   │                 (Unit: beats per minute)
%   ├── ecg_bandpass: [numeric] Minimum and maximum frequencies to use
%   │                 during bandpass filter of the raw ECG signal to
%   │                 construct filtered ECG signal.
%   │                 (Default: [0.5 40])
%   │                 (Unit: Hz)
%   ├── teo_bandpass: [numeric, unit: Hz, default as [8 40]]
%   │                 Minimum and maximum frequencies to use
%   │                 during bandpass filter of filtered ECG signal to
%   │                 construct TEO input signal.
%   ├──── teo_order:  [numeric, default as 1]
%   │                 Order of the TEO operator. Must be integer.
%   │                 For a discrete time signal x(t) and order k,
%   │                 TEO[x(t); k] is defined as
%   │                 TEO[x(t); k] = x(t)x(t) - x(t-k)x(t+k).
%   ├ min_cross_corr: [numeric, default as 0.5]
%   │                 Minimum cross correlation between a candidate
%   │                 R-peak and the found template such that the candidate is
%   │                 classified as an R-peak.
%   ├ min_relative_amplitude:
%   │                 [numeric, default as 0.4]
%   │                 Minimum relative peak amplitude of a candidate
%   │                 R-peak such that it is classified as an R-peak.
%   ├ channel_action: ['add'/'replace'] Defines whether corrected data
%   │                 should be added or the corresponding preprocessed
%   │                 channel should be replaced. Note that 'replace' mode
%   │                 does not replace the raw data channel, but a previously
%   │                 stored heartbeat channel.
%   │                 (Default: 'replace')
%   └─── out_channel: Channel ID of the preprocessed output. Output will
%                     be written to a 'heartbeat' channel to the given PsPM
%                     file. .data field contains the timestamps of heartbeats
%                     in seconds.
% ● References
%   [1] Liu, Zhongming, et al. "Statistical feature extraction for artifact
%       removal from concurrent fMRI-EEG recordings." Neuroimage 59.3 (2012):
%       2073-2087.
%   [2] http://www.amri.ninds.nih.gov/software.html
% ● Contributed by
%   (C) 2019 Eshref Yozdemir (University of Zurich)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
%% create default arguments
if nargin < 2
  options = struct();
end
if ~isfield(options, 'channel')
  options.channel = 'ecg';
end
if ~isfield(options, 'channel_action')
  options.channel_action = 'replace';
end
if ~isfield(options, 'signal_to_use')
  options.signal_to_use = 'auto';
end
if ~isfield(options, 'hrrange')
  options.hrrange = [20 200];
end
if ~isfield(options, 'ecg_bandpass')
  options.ecg_bandpass = [0.5 40];
end
if ~isfield(options, 'teo_bandpass')
  options.teo_bandpass = [8 40];
end
if ~isfield(options, 'teo_order')
  options.teo_order = 1;
end
if ~isfield(options, 'min_cross_corr')
  options.min_cross_corr = 0.5;
end
if ~isfield(options, 'min_relative_amplitude')
  options.min_relative_amplitude = 0.4;
end
%% input checks
if ~ismember(options.channel_action, {'add', 'replace'})
  warning('ID:invalid_input', 'Option channel_action must be either ''add'' or ''replace''');
  return;
end
if ~ismember(options.signal_to_use, {'ecg', 'teo', 'auto'})
  warning('ID:invalid_input', 'Option signal_to_use must be one of ''ecg'',''teo'' or ''auto''');
  return;
end
if ~isnumeric(options.hrrange) || any(options.hrrange <= 0)
  warning('ID:invalid_input', 'Option hrrange must contain positive numbers');
  return;
end
if ~isnumeric(options.ecg_bandpass) || any(options.ecg_bandpass <= 0)
  warning('ID:invalid_input', 'Option ecg_bandpass must contain positive numbers');
  return;
end
if ~isnumeric(options.teo_bandpass) || any(options.teo_bandpass <= 0)
  warning('ID:invalid_input', 'Option teo_bandpass must contain positive numbers');
  return;
end
if ~isnumeric(options.teo_order) || options.teo_order <= 0 || mod(options.teo_order, 1) ~= 0
  warning('ID:invalid_input', 'Option teo_order must be a positive integer');
  return;
end
if ~isnumeric(options.min_cross_corr)
  warning('ID:invalid_input', 'Option min_cross_corr must be numeric');
  return;
end
if ~isnumeric(options.min_relative_amplitude)
  warning('ID:invalid_input', 'Option min_relative_amplitude must be numeric');
  return;
end
%% load
addpath(pspm_path('backroom'));
[lsts, data] = pspm_load_single_chan(fn, options.channel, 'last', 'ecg');
if lsts ~= 1; return; end;
rmpath(pspm_path('backroom'));
%% process
addpath(pspm_path('ext','amri_eegfmri'));
ecg.data = data{1}.data;
ecg.srate = data{1}.header.sr;
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
if lsts ~= 1; return; end;
out_channel = infos.channel;
sts = 1;
end