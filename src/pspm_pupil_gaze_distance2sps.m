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



if (nargin < 6)
  options = struct('channel_action', 'add');
end

  
if (~strcmp(from, 'mm'))
  [lsts, infos, data] = pspm_load_data(fn)
  dataIdx = find(cellfun(@(c) strncmp(c.header.chantype, 'gaze_', numel('gaze_')) & strcmp(c.header.units, from), data));
  for d = dataIdx'
    if strcmp(from, 'pixel')
      pixel2unit_options.channel_action = 'replace';
      [ sts ] = pspm_convert_pixel2unit(fn, d, 'mm', width, height, distance, pixel2unit_options);
      if (sts < 1)
        warning('ID:invalid_input', 'Could not convert pixels to mm');
        return;
      end

    else
      [sts, out ] = pspm_convert_unit(data{d}.data, from, 'mm');
      if (sts < 1)
        warning('ID:invalid_input', 'Could not perform temporary conversion to mm');
        return;
      end;


      temp_channel = data;
      temp_channel.data = out;
      temp_channel.header.units = "mm";
      [lsts, outinfo] = pspm_write_channel(fn, temp_channel, 'add');
      if (lsts < 1)
        warning('ID:invalid_input', 'Could not write temporary mm data channels');
        return;
      end;


    end
  end
end

visual_angle_options = options;
% interpolate the distance data before conversion when ultimately targetting sps
visual_angle_options.interpolate = 1;
[sts, out] = pspm_compute_visual_angle(fn, 0, width, height, distance, 'mm', visual_angle_options);

if (sts < 1)
  warning('ID:invalid_input', 'Could not convert distance data to degrees');
  return;
end;

[sts, out] = pspm_convert_visangle2sps(fn, options);