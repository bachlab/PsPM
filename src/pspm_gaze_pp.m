function [sts, out_channel] = pspm_gaze_pp(fn, options)

% DESCRIPTION
% pspm_gaze_pp preprocesses gaze signals
%
% FORMAT
% [sts, out_channel] = pspm_gaze_pp(fn)
% [sts, out_channel] = pspm_gaze_pp(fn, options)
%
% VARIABLES
% fn		[string] Path to the PsPM file which contains the gaze data.
% options
% 	channel	[numeric/string, optional] Channel ID to be preprocessed, default: 'gaze'.
%
% (C) 2021 Teddy Chao (WCHN, UCL)

%% 1 Initialise
global settings;
if isempty(settings)
  pspm_init;
end
sts = -1;

%% 2 Create default arguments
if nargin == 1
	options = struct();
end
if ~isfield(options, 'channel')
	options.channel = 'gaze';
end
if ~isfield(options, 'channel_action')
	options.channel_action = 'add';
end
if ~isfield(options, 'channel_combine')
	options.channel_combine = 'none';
end
if ~isfield(options, 'plot_data')
	options.plot_data = false;
end
