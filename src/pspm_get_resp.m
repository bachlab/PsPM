function [sts, data] = pspm_get_resp(import)
% ● Description
%   pspm_get_resp is a common function for importing respiration data.
% ● Format
%   [sts, data] = pspm_get_resp(import)
% ● Arguments
%    import: [struct]
%     .data: column vector of waveform data
%       .sr: sample rate
%    .units:
% ● History
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Maintained in 2022 by Teddy Chao (UCL)

% initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
% assign respiratory data
data.data = import.data(:);
% add header
data.header.chantype = 'resp';
data.header.units = import.units;
data.header.sr = import.sr;
% check status
sts = 1;
return
