function [sts, data] = pspm_get_gaze_y_l(import)
% ● Description
%   pspm_get_gaze_y_l is a common function for importing eyelink data
%   (gaze_y_l data)
% ● Format
%   [sts, data]= pspm_get_gaze_y_l(import)
% ● Arguments
%   ┌import
%   ├─.data : column vector of left gaze y data
%   └───.sr : sample rate
% ● History
%   Introduced in PsPM 3.1
%   Written in 2015 by Tobias Moser (University of Zurich)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
% assign respiratory data
data.data = import.data(:);
% add header
data.header.chantype = 'gaze_y_l';
data.header.units = import.units;
data.header.sr = import.sr;
data.header.range = import.range;
% check status
sts = 1;
return
