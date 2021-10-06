function [sts, out_channel] = pspm_gaze_pp(fn, options)

% pspm_gaze_pp preprocesses gaze signals
% (C) 2021 Teddy Chao (WCHN, UCL)
%	FORMAT:   [sts, out_channel] = pspm_gaze_pp(fn)
%           [sts, out_channel] = pspm_gaze_pp(fn, options)
%
% fn:       [string] Path to the PsPM file which contains
%           the gaze data.
%	options:
%   Optional:
%     channel:    [numeric/string] Channel ID to be preprocessed.
%                 (Default: 'gaze')
%                 Preprocessing raw eye data:
%                 The best eye is processed when channel is 'gaze_x' or 
%									'gaze_y'.
%                 In order to process a specific eye, use 'gaze_x_l'/
%                 'gaze_x_r' or 'gaze_y_l'/'gaze_y_r'.
%                 Preprocessing previously processed data:
%                 · Gaze channels created from other preprocessing steps
%                   can be further processed by this function. To enable
%                   this, pass one of 'gaze_x_pp_l' or 'gaze_x_pp_r'.
%                   There is no best eye selection in this mode.
%                   Hence, the type of the channel must be given exactly.
%                 · Finally, a channel can be specified by its
%                   index in the given PsPM data structure. It will be
%                   preprocessed as long as it is a valid pupil channel.
%                 · If channel is specified as a string and there are
%                   multiple channels with the exact same type, only the
%                   last one will be processed. This is normally not the
%                   case with raw data channels; however, there may be
%                   multiple preprocessed channels with same type if 'add'
%                   channel_action was previously used. This feature can
%                   be combined with 'add' channel_action to create
%                   preprocessing histories where the result of each step
%                   is stored as a separate channel.

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