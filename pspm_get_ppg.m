function [sts, data]=pspm_get_ppg(import)
% pspm_get_ppg is a common function for importing PPU data
%
% FORMAT:
%   [sts, data]= pspm_get_ppg(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Tobias Moser (University of Zurich)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

% assign respiratory data
data.data = import.data(:);

% add header
data.header.chantype = 'ppg';
data.header.units = import.units;
data.header.sr = import.sr;

% check status
sts = 1;
