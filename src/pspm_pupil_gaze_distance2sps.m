function [sts, out] = pspm_pupil_gaze_distance2sps(fn, from, height, width, distance, options)
%   pspm_pupil_gaze_distance2sps takes a file with pixel or length unit gaze data
%   and converts to scanpath speed. Data will automatically be interpolated if NaNs exist
%   Conversion will be attempted for any gaze data present in the provided unit.
%   i.e. if only a left eye's data is provided the speed will only be calculated for that eye.
%   The function may add intermediary conversions, e.g. a conversion from pixel will result in an intermediary mm conversion
%
%   FORMAT:
%       [sts, out] = pspm_pupil_gaze_distance2sps(fn, from, height, width, distance, options)
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
%
%   OUTPUT:
%     sts:               Status determining whether the execution was
%                        successfull (sts == 1) or not (sts == -1)
%     out:               Output struct
%       .channel           Id of the added channels.

global settings;
if isempty(settings), pspm_init; end
sts = -1;
out = [];

% distance to degree conversion
[sts, infos, data] = pspm_load_data(fn,0);

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

  options.interpolate = 1;
  try;
    [ lat, lon, lat_range, lon_range ] = pspm_compute_visual_angle_core(data_x, data_y, width, height, distance, options);
  catch;
    warning('ID:invalid_input', 'Could not convert distance data to degrees');
    return;
  end;
    

  arclen = pspm_convert_visangle2sps_core(lat, lon);
  dist_channel.data = arclen .* sr;
  dist_channel.header.chantype = strcat('sps_', gaze_eye{1});
  dist_channel.header.sr = sr;
  dist_channel.header.units = 'degree';
  
  [sts, outinfo] = pspm_write_channel(fn, dist_channel, options.channel_action);

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
