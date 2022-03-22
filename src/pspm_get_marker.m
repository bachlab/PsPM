function [sts, data] = pspm_get_marker(import)
% pspm_get_marker gets the marker channel for different data types
% FORMAT: [sts, data] = pspm_get_marker(import)
%               import: import job structure with mandatory fields
%                  .data
%                  .marker ('timestamps', 'continuous')
%                  .sr (timestamps: timeunits in seconds, continuous: sample rate in 1/seconds)
%                  and optional fields
%                  .flank ('ascending', 'descending', 'both': optional field for
%                   continuous channels; default: both)
%                  .markerinfo: .name and .value for more information on markers
%           returns marker timestamps in seconds
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

global settings;
if isempty(settings), pspm_init; end;
sts =-1;

% get data
% -------------------------------------------------------------------------
[bsts, import] = pspm_get_events(import);
if bsts~=1
    warning('ID:invalid_input','Call of pspm_get_events failed');
    return;
end
data.data = import.data;
% add flank info
if isfield(import, 'flank')
    data.flank = import.flank;
end
if isfield(import, 'markerinfo')
    data.markerinfo = import.markerinfo;
end;

% add header
% -------------------------------------------------------------------------
data.header.chantype = 'marker';
data.header.units = 'events';
data.header.sr = 1;
sts = 1;
return;
