function [sts, data] = scr_get_marker(import)
% SCR_GET_MARKER gets the marker channel for different data types
% FORMAT: [sts, data] = scr_get_marker(import)
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

% $Id: scr_get_marker.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $


global settings;
if isempty(settings), scr_init; end;

% get data
% -------------------------------------------------------------------------
[sts, import] = scr_get_events(import);
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
