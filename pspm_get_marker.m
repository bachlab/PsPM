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

% $Id$
% $Rev$


global settings;
if isempty(settings), pspm_init; end;

% get data
% -------------------------------------------------------------------------
[sts, import] = pspm_get_events(import);
data.data = import.data;

% add marker info
% -------------------------------------------------------------------------
if isfield(import, 'markerinfo')
    data.markerinfo = import.markerinfo;
end;

% add header
% -------------------------------------------------------------------------
data.header.chantype = 'marker';
data.header.units = 'events';
data.header.sr = 1;

return;
