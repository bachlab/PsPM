function [sts, gaze_x, gaze_y, eye] = pspm_load_gaze (fn, chantype)
% ● Description
%   This function extracts the eye location (r, l, c, global) from chantype
%   and loads the corresponding gaze_x and gaze_y channels.
% ● Format
%   [sts, gaze_x, gaze_y, eye] = pspm_load_gaze (fn, channel)
% ● Arguments
%   *       fn :  [string] / [struct]
%                 Path to a PsPM file, or a struct accepted by pspm_load_data
%   * chantype :  Definition of an eyetracker channel to which the gaze
%                 should correspond, or one of {'r', 'l', 'c', ''}
% ● Outputs
%   *   gaze_x :  struct with fields .data and .header as returned by pspm_load_channel
%   *   gaze_y :  struct with fields .data and .header as returned by pspm_load_channel
%   *      eye :  one of {'r', 'l', 'c', ''}.
% ● History
%   Introduced in PsPM version 6.2
%   Written in 2024 by Dominik Bach (Uni Bonn)

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1; gaze_x = []; gaze_y = [];

% check laterality identifier
if ismember(chantype, {'r', 'l', 'c', ''})
    eye = chantype;
else
    [eyests, eye] = pspm_find_eye(chantype);
    if eyests < 1, return, end
end

if ~strcmpi(eye, '')
    neweye = ['_', eye];
end

[stsx, gaze_x] = pspm_load_channel(fn, ['gaze_x', neweye]);
[stsy, gaze_y] = pspm_load_channel(fn, ['gaze_y', neweye]);

if stsx == 1 && stsy == 1
    sts = 1;
end
