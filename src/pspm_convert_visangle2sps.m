function [ sts, out ] = pspm_convert_visangle2sps(fn, options)
% ● Description
%   pspm_convert_visangle2sps takes a file with data from eyelink recordings
%   and computes by seconds normalized distances bewteen visual angle data.
%   It saves the result into a new channel with chaneltype 'sps' (Scanpath speed).
%   It is important that pspm_convert_visangle2sps only takes channels
%   which are in visual angle.
% ● Format
%   [sts, out] = pspm_convert_visangle2sps(fn, options)
% ● Arguments
%                 fn: The actual data file containing the eyelink
%                     recording with gaze data
%   ┌────────options: struct with following fields
%   ├─────────.chans: On which subset of the channels the visual
%   │                 angles between the data point should be
%   │                 computed             .
%   │                 If no channels are given then the function
%   │                 computes the scanpath speed of the first
%   │                 found gaze data channels with type 'degree'
%   ├──────────.eyes: [string, accept 'l', 'r', or 'c', default as 'c']
%   │                 Define on which eye the operations
%   │                 should be performed.
%   └.channel_action: ['add'/'replace', default as 'add']
%                     Defines whether the new channels
%                     should be added or the previous outputs of this function
%                     should be replaced.
% ● Outputs
%                sts: Status determining whether the execution was
%                     successfull (sts == 1) or not (sts == -1)
%   ┌────────────out: Output struct
%   └───────.channel: Id of the added channels.

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
%% check missing input
if nargin<1
  warning('ID:invalid_input', 'Nothing to do.'); return
elseif nargin<2
  channels = 0;
end
if isfield(options, 'chans')
  channels = options.chans;
  if ~isnumeric(channels)
    warning('ID:invalid_input', 'Channels must be defined by their id.');
    return
  end
else
  channels = 0;
end
% option.eyes
if ~isfield(options, 'eyes')
  options.eyes = settings.lateral.char.b;
elseif ~any(strcmpi(options.eyes, {settings.lateral.char.l,...
    settings.lateral.char.r,...
    settings.lateral.char.b}))
  warning('ID:invalid_input', ['''options.eyes'' must be either ''l'', ', ...
    '''r'', ''c''.']);
  return
end
% option.channel_action
if ~isfield(options, 'channel_action')
  options.channel_action = 'add';
elseif ~any(strcmpi(options.channel_action, {'add', 'replace'}))
  warning('ID:invalid_input', ['''options.channel_action'' must be either ''add'' or ''replace''.']);
  return
end
% fn
if ~ischar(fn) || ~exist(fn, 'file')
  warning('ID:invalid_input', ['File %s is not char or does not ', ...
    'seem to exist.'], fn); return
end
%% load data to evaluate
[lsts, infos, data] = pspm_load_data(fn, channels);
if lsts ~= 1
  warning('ID:invalid_input', 'Could not load input data correctly.');
  return
end
%% iterate through eyes
n_eyes = numel(infos.source.eyesObserved);
for i=1:n_eyes
  eye = lower(infos.source.eyesObserved(i));
  if contains(options.eyes, eye)
    gaze_x = ['gaze_x_', eye];
    gaze_y = ['gaze_y_', eye];
    gx = find(cellfun(@(x) strcmpi(gaze_x, x.header.chantype) & ...
      strcmpi('degree', x.header.units), data),1);
    gy = find(cellfun(@(x) strcmpi(gaze_y, x.header.chantype) & ...
      strcmpi('degree', x.header.units), data),1);
    if ~isempty(gx) && ~isempty(gy)
      % get channel specific data
      lon = data{gx}.data;
      lat = data{gy}.data;
      try
        arclen = pspm_convert_visangle2sps_core(lat, lon);
      catch
        warning('ID:invalid_input', 'Could not calculate sps from gaze data');
        return
      end
      % create new channel with data holding distances
      dist_channel.data = rad2deg(arclen) .* data{gx}.header.sr;
      dist_channel.header.chantype = strcat('sps_', eye);
      dist_channel.header.sr = data{gx}.header.sr;
      dist_channel.header.units = 'degree';
      [lsts, outinfo] = pspm_write_channel(fn, dist_channel, options.channel_action);
      if lsts ~= 1
        warning('ID:invalid_input', '~Distance channel could not be written');
        return
      end
      out(i) = outinfo;
    else
      if strcmpi(eye,'r'), eye_long='right'; else, eye_long='left'; end
      warning('ID:invalid_input', ['Unable to perform visangle2', ...
        'sps for the ',eye_long,' eye. Cannot find gaze channels with degree ',...
        'unit values. Maybe you need to convert them with ', ...
        'pspm_convert_pixel2unit()']);
    end
  end
end
sts = 1;
end