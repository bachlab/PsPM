function [sts, out] = pspm_compute_visual_angle(fn, channel, width, height, distance, unit, options)
% ● Description
%   pspm_compute_visual_angle computes from gaze data the corresponding
%   visual angle (for each data point). The convention used here is that the
%   origin of coordinate system for gaze data is at the bottom left corner of
%   the screen.
% ● Format
%   [sts, out] = pspm_compute_visual_angle(fn, channel, width, height, distance, unit, options)
% ● Arguments
%                fn:  The actual data file containing the eyelink recording
%                     with gaze data
%           channel:  On which subset of channels should the conversion be done.
%                     Supports all values which can be passed to
%                     pspm_load_data().
%                     The will only work on gaze-channels.
%                     Other channels specified will be ignored.
%             width:  Width of the display window. Unit is 'unit'.
%            height:  Height of the display window. Unit is 'unit'.
%          distance:  distance between eye and screen in length units.
%              unit:  unit in which width, height and distance are given.
% ┌──────── options:
% ├─.channel_action:  [accept: 'add'/'replace', default: 'add']
% │                   Defines whether the new channels should be added or the
% │                   previous outputs of this function should be replaced.
% └───────────.eyes:  [accept: 'left'/'right'/'combined', default: 'combined']
%                     Define on which eye the operations should be performed.
% ● Output
%               sts:  Status determining whether the execution was
%                     successfull (sts == 1) or not (sts == -1)
%               out:  Id of the added channels.
% ● History
%   Introduced in PsPM 4.0

%% 0 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
%% 1 validate input
if nargin < 6
  warning('ID:invalid_input', 'Not enough arguments.');
  return;
elseif ~exist('options','var')
  options = struct();
end
%% 2 check types of arguments
if ~ischar(fn) || ~exist(fn, 'file')
  warning('ID:invalid_input', ['File %s is not char or does not ', ...
    'seem to exist.'], fn);
  return
elseif ~isnumeric(channel)
  warning('ID:invalid_input', 'Channels must be indicated by their ID nummber.');
  return
elseif ~isnumeric(width)
  warning('ID:invalid_input', 'Width must be numeric.');
  return
elseif ~isnumeric(height)
  warning('ID:invalid_input', 'Height must be numeric.');
  return
elseif ~isnumeric(distance)
  warning('ID:invalid_input', 'distance is not set or not numeric.');
  return
elseif ~ischar(unit)
  warning('ID:invalid_input', 'unit should be a char');
  return
elseif ~isstruct(options)
  warning('ID:invalid_input', 'Options must be a struct.');
  return
end
%% 3 load data to evaluate
[lsts, infos, data] = pspm_load_data(fn, channel);
if lsts ~= 1
  warning('ID:invalid_input', 'Could not load input data correctly.');
  return
end
%% 4 set more defaults
options = pspm_options(options, 'compute_visual_angle');
if options.invalid
  return
end
%% 5 iterate through eyes
n_eyes = numel(infos.source.eyesObserved);
p = 1;
for i = 1:n_eyes
  eye = lower(infos.source.eyesObserved(i));
  options_eye_char = convert_eye_full2char(options.eye);
  if contains(options_eye_char, eye)
    gaze_x = ['gaze_x_', eye];
    gaze_y = ['gaze_y_', eye];

    % always use first found channel

    gx = find(cellfun(@(x) strcmpi(gaze_x, x.header.chantype) & ...
      strcmpi('mm', x.header.units), data),1);
    gy = find(cellfun(@(x) strcmpi(gaze_y, x.header.chantype) & ...
      strcmpi('mm', x.header.units), data),1);

    if ~isempty(gx) && ~isempty(gy)

      visual_angl_chans{p} = data{gx};
      visual_angl_chans{p+1} = data{gy};

      try
        [ lat, lon, lat_range, lon_range ] = ...
        pspm_compute_visual_angle_core(data{gx}.data, data{gy}.data, width, height, distance, options);
      catch
        warning('ID:invalid_input', 'Could not convert distance data to degrees');
        return
      end

      % azimuth angle of gaze points
      % longitude (azimuth angle from positive x axis in horizontal plane) of gaze points
      visual_angl_chans{p}.data = lon;
      visual_angl_chans{p}.header.units = 'degree';
      visual_angl_chans{p}.header.range = lon_range;
      %      visual_angl_chans{p}.header.r = r;                % radial coordinates omitted
      %      visual_angl_chans{p}.header.r_range = r_range;    % radial coordinates omitted

      % elevation angle of gaze points,
      % latitude (elevation angle from horizontal plane) of gaze points
      visual_angl_chans{p+1}.data = lat;
      visual_angl_chans{p+1}.header.units = 'degree';
      visual_angl_chans{p+1}.header.range = lat_range;
      %      visual_angl_chans{p+1}.header.r = r;              % radial coordinates omitted
      %      visual_angl_chans{p+1}.header.r_range = r_range;  % radial coordinates omitted
      p = p+2;
    else
      fails{i} = sprintf('There are no channels gaze_x and gaze_y for eyes ''%s''.',eye);
    end
  end
end
if p == 1
  for i = 1:numel(fails)
    disp(fails{i})
  end
  warning('ID:invalid_input','Not enough data to compute visual angle.');
  return
end
%% 6 finish outputs
[lsts, outinfo] = pspm_write_channel(fn, visual_angl_chans, options.channel_action);
if ~lsts
  warning('ID:invalid_input', 'Could not write converted data.');
  return
end
sts = 1;
out = outinfo;
return

function argout = convert_eye_full2char(argin)
argout = argin;
[row,column] = size(argin);
for irow = 1:row
  for icolumn = 1:column
    switch argin(irow, icolumn)
      case settings.lateral.full.c
        argout(irow, icolumn) = settings.lateral.char.c;
      case settings.lateral.full.l
        argout(irow, icolumn) = settings.lateral.char.l;
      case settings.lateral.full.r
        argout(irow, icolumn) = settings.lateral.char.r;
    end
  end
end