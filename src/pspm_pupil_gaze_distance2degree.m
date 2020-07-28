function [sts, out] = pspm_pupil_gaze_distance2degree(fn, from, height, width, distance, options)
%   pspm_pupil_gaze_distance2degree takes a file with pixel or length unit gaze data
%   and converts to scanpath speed. Data will automatically be interpolated if NaNs exist
%   Conversion will be attempted for any gaze data present in the provided unit.
%   i.e. if only a left eye's data is provided the speed will only be calculated for that eye.
%
%   FORMAT:
%       [sts, out] = pspm_pupil_gaze_distance2degree(fn, from, height, width, distance, options)
%
%   INPUT:
%       fn:                 The actual data file gaze data
%
%       from:               Distance unit to convert from.
%                           pixel, mm, cm, m, inches
%
%       height:             Height of the screen in the units chosen in the 'from' parameter
%
%       width:              Width of the screen in the units chosen in the 'from' parameter
%
%       distance:           Subject distance from the screen in the units chosen in the 'from' parameter
% 
%       options:
%         channel_action:   Channel action for sps data, add / replace existing sps data
%                           Default: add
%                           IMPORTANT: Replace will overwrite gaze data in any unit,
%                           so a pixel gaze_x_l channel will be overwritten by a degree gaze_x_l channel.
%
%         interpolate:      Boolean, interpolate the distance data before converting to degrees.
%                           Default: true
%
%   OUTPUT:
%     sts:               Status determining whether the execution was
%                        successfull (sts == 1) or not (sts == -1)
%     out:               Output struct
%       .channel           Id of the added channels.

% Number of arguments validation
if nargin < 5;
  warning('ID:invalid_input','Not enough input arguments.'); return;
elseif nargin < 6;
  options = struct();
end

% Options defaults
if ~isfield(options, 'interpolate');
  options.interpolate = 1;
end

if ~isfield(options, 'channel_action');
  options.channel_action = 'add';
end

% Input argument validation

if ~ismember(from, { 'pixel', 'mm', 'cm', 'inches', 'm' })
  warning('ID:invalid_input', 'from unit must be "pixel", "mm", "cm", "inches", "m"');
  return;
end;

if ~isnumeric(height)
  warning('ID:invalid_input', 'height must be numeric');
  return;
end;

if ~isnumeric(width)
  warning('ID:invalid_input', 'width must be numeric');
  return;
end;

if ~isnumeric(distance)
  warning('ID:invalid_input', 'distance must be numeric');
  return;
end;


sts = -1;
out = [];






% distance to degree conversion
[lsts, infos, data] = pspm_load_data(fn,0);

lIdx = find(cellfun(@(c) ~isempty(regexp(c.header.chantype, 'gaze_[x|y]_l', 'once'))...
   && strcmp(c.header.units, from), data));
rIdx = find(cellfun(@(c) ~isempty(regexp(c.header.chantype, 'gaze_[x|y]_r', 'once'))...
   && strcmp(c.header.units, from), data));

if (length(lIdx) < 1 && length(rIdx) < 1)
  warning('ID:invalid_input', 'no gaze data found with the units provided')
  return;
end


for gaze_eye = [ lIdx, rIdx ]
  for d = gaze_eye'
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

  try;
    [ lat, lon, lat_range, lon_range ] = pspm_compute_visual_angle_core(data_x, data_y, width, height, distance, options);
  catch;
    warning('ID:invalid_input', 'Could not convert distance data to degrees');
    return;
  end;
    
  lat_chan.data = lat;
  lat_chan.header.units = 'degree';
  lat_chan.header.range = lat_range;

  lon_chan.data = lon;
  lon_chan.header.units = 'degree';
  lon_chan.header.range = lon_chan;

  [sts, out] = pspm_write_channel(fn, { lat_chan, lon_chan }, options.channel_action);
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
