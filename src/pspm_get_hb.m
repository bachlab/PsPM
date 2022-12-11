function [sts, data]=pspm_get_hb(import)
% ● Description
%   pspm_get_hb is a common function for importing heart beat data
% ● Format
%   [sts, data]= pspm_get_hb(import)
% ● Arguments
%   import: import job structure with mandatory fields
%     .data
%   .marker ('timestamps', 'continuous')
%       .sr (timestamps: timeunits in seconds, continuous: sample rate in 1/seconds)
%                  and optional fields
%                  .flank ('ascending', 'descending', 'both': optional field for
%                   continuous channels; default: both)
% ● History
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

% get data
% -------------------------------------------------------------------------
[bsts, import] = pspm_get_events(import);
if bsts~=1
  warning('ID:invalid_input', 'Call of pspm_get_events failed.'); return;
end
data.data = import.data;

% add header
% -------------------------------------------------------------------------
data.header.channeltype = 'hb';
data.header.units = 'events';
data.header.sr = 1;
sts = 1;
end
