function [sts, out] = pspm_compute_visual_angle(chan, distance,unit)
% PSPM_COMPUTE_VISUAL_ANGLE computes from gaze data the corresponding
% visual angle (for each data point)

% FORMAT: 
%        [sts, out] = pspm_compute_visual_angle(chan_x,  distance,unit)
%
% ARGUMENTS:    chan:           channel with gaze data 
%               distance:       distance between eye and screen in length units.
%               unit:           unit in which distance is given.
% RETURN VALUES sts
%               sts:            Status determining whether the execution was 
%                               successfull (sts == 1) or not (sts == -1)
%               out:            Output struct: channel containing the
%                               visual angles for each data point. This 
%                               out is a copy of the imput channel with
%                               changed units to 'visual_angle'   
%__________________________________________________________________________
% PsPM 4.0
global settings;
if isempty(settings), pspm_init; end;
sts = -1;

% validate input
if nargin < 4
    warning('ID:invalid_input', 'Not enough arguments.');
    return;
end;

% check types of arguments
if ~isnumeric(distance)
    warning('ID:invalid_input', 'distance is not set or not numeric.'); 
    return;
elseif ~ischar(unit)
    warning('ID:invalid_input', 'unit should be a char');
    return;
end;

% check if chan is of the same unit as distance 
if ~strcmpi(chan.header.units,unit)
    warning('ID:invalid_input', 'unit of channel and unit of distance must be of the same type');
    return;
end;

% compute visual angle for each data point
visual_angl_chan = chan;
visual_angl_chan.data = radtodeg(arcsin(chan.data ./ distance));
visual_angl_chan.header.units = 'degree';
visual_angl_chan.header.range = [0, max(visual_angl_chan.data)];

sts = 1;
out = visual_angl_chan;
end

