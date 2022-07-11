function [sts, out] = pspm_convert_gaze_distance(fn, target, from, width, height, distance, options)
% pspm_convert_gaze_distance takes a file with pixel or length unit gaze data
% and converts to scanpath speed. Data will automatically be interpolated if NaNs exist
% Conversion will be attempted for any gaze data present in the provided unit.
% i.e. if only a left eye's data is provided the speed will only be calculated for that eye.
%
% FORMAT:
%     [sts, out] = pspm_convert_gaze_distance(fn, from, width, height, distance, options)
%
% ARGUMENTS:
%     fn:                 The actual data file gaze data
%
%     target:             target unit of conversion. degree | sps
%
%     from:               Distance unit to convert from.
%                         pixel, mm, cm, m, inches
%
%     width:              Width of the screen in the units chosen in the 'from' parameter
%
%     height:             Height of the screen in the units chosen in the 'from' parameter
%
%     distance:           Subject distance from the screen in the units chosen in the 'from' parameter
%
%     options:
%       chan_action:   Channel action for sps data, add / replace existing sps data
%
% OUTPUT:
%   sts:               Status determining whether the execution was
%                      successfull (sts == 1) or not (sts == -1)
%   out:               Output struct
%     .chan           Id of the added channels.
%__________________________________________________________________________
% PsPM 4.3.1
% (C) 2020 Sam Maxwell (University College London)

% $Id: pspm_convert_gaze_distance.m 1 2020-08-13 12:28:08Z sammaxwellxyz $
% $Rev: 1 $

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

% Number of arguments validation
if nargin < 6
  warning('ID:invalid_input','Not enough input arguments.'); return;
elseif nargin < 7
  options = struct();
end

options = pspm_options(options, 'convert_gaze_distance');



% Input argument validation
if ~ismember(target, { 'degree', 'sps' })
  warning('ID:invalid_input:target', 'target conversion must be sps or degree');
  return;
end;

if ~ismember(from, { 'pixel', 'mm', 'cm', 'inches', 'm' })
  warning('ID:invalid_input:from', 'from unit must be "pixel", "mm", "cm", "inches", "m"');
  return;
end;

if ~isnumeric(height)
  warning('ID:invalid_input:height', 'height must be numeric');
  return;
end;

if ~isnumeric(width)
  warning('ID:invalid_input:width', 'width must be numeric');
  return;
end;

if ~isnumeric(distance)
  warning('ID:invalid_input:distance', 'distance must be numeric');
  return;
end;


% distance to sps conversion
[sts, ~, data] = pspm_load_data(fn,0);

eyes.l = find(cellfun(@(c) ~isempty(regexp(c.header.chantype, 'gaze_[x|y]_l', 'once'))...
  && strcmp(c.header.units, from), data));
eyes.r = find(cellfun(@(c) ~isempty(regexp(c.header.chantype, 'gaze_[x|y]_r', 'once'))...
  && strcmp(c.header.units, from), data));

if (length(eyes.l) < 1 && length(eyes.r) < 1)
  warning('ID:invalid_input', 'no gaze data found with the units provided')
  return;
end

for gaze_eye = fieldnames(eyes)'
  for d = eyes.(gaze_eye{1})'
    sr =  data{d}.header.sr;
    if ~isempty(regexp(data{d}.header.chantype, 'gaze_x_', 'once'))
      lon_chan = data{d};

      if (strcmp(from, 'pixel'));
        data_x = pixel_conversion(data{d}.data, width, data{d}.header.range);
      else;
        [ sts, data_x ] = pspm_convert_unit(data{d}.data, from, 'mm');
      end;

    else
      lat_chan = data{d};

      if (strcmp(from, 'pixel'));
        data_y = pixel_conversion(data{d}.data, height, data{d}.header.range);
      else;
        [ sts, data_y ] = pspm_convert_unit(data{d}.data, from, 'mm');
      end;
    end;
  end

  if strcmp(target, 'sps')
    options.interpolate = 1;
  end

  try;
    [ lat, lon, lat_range, lon_range ] = pspm_compute_visual_angle_core(data_x, data_y, width, height, distance, options);
  catch;
    warning('ID:invalid_input', 'Could not convert distance data to degrees');
    return;
  end;


  if strcmp(target, 'degree')
    lat_chan.data = lat;
    lat_chan.header.units = 'degree';
    lat_chan.header.range = lat_range;

    lon_chan.data = lon;
    lon_chan.header.units = 'degree';
    lon_chan.header.range = lon_chan;

    [sts, out] = pspm_write_channel(fn, { lat_chan, lon_chan }, options.chan_action);
  elseif strcmp(target, 'sps')

    arclen = pspm_convert_visangle2sps_core(lat, lon);
    dist_chan.data = rad2deg(arclen) .* sr;
    dist_chan.header.chantype = strcat('sps_', gaze_eye{1});
    dist_chan.header.sr = sr;
    dist_chan.header.units = 'degree';

    [sts, out] = pspm_write_channel(fn, dist_chan, options.chan_action);
  end

end
end


% CODE SAME AS IN pspm_pixel2unit
function out = pixel_conversion(data, screen_length, interest_range)
length_per_pixel = screen_length ./ (diff(interest_range) + 1);
% baseline data in pixels wrt. the range (i.e. pixels of interest)
pixel_index = data-interest_range(1);
% convert indices into coordinates in the units of interests
out = pixel_index * length_per_pixel;
end
