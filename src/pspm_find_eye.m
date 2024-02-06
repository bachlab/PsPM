function [sts, eye] = pspm_find_eye(chantype)
% Definition
% pspm_get_eye detects the eye location ('l', 'r', 'c', '') from an 
%  eyetracker channel type
%  FORMAT
%  [sts, eye] = pspm_find_eye(chantype)
% ARGUMENTS
%   Input
%     chantype: the field header.chantype as returned by pspm_load_data 
%   Output
%          eye:  one of {'r', 'l', 'c', ''}
% ● History
%   Introduced in PsPM version 5.1.2
%   Written in 2021 by Dadi Zhao (UCL)

global settings
if isempty(settings)
  pspm_init;
end

sts = -1;
eye = '';

if ~contains(chantype, settings.eyetracker_channels)
    warning('ID:invalid_input', 'This function only allows eyetracker input');
    return
end

for eye_attempt = [settings.lateral.char.l, settings.lateral.char.r, settings.lateral.char.c]
  if strcmpi(chantype(length(chantype)-1:length(chantype)), ['_', eye_attempt])
    eye = eye_attempt;
  end
end

sts = 1;