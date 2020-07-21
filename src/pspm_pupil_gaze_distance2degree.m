function [sts, out] = pspm_pupil_gaze_distance2degree(fn, from, height, width, distance)
%   pspm_pupil_gaze_distance2degree takes a file with pixel or length unit gaze data
%   and converts to scanpath speed. Data will automatically be interpolated if NaNs exist
%   Conversion will be attempted for any gaze data present in the provided unit.
%   i.e. if only a left eye's data is provided the speed will only be calculated for that eye.
%   The function may add intermediary conversions, e.g. a conversion from pixel will result in an intermediary mm conversion
%
%   FORMAT:
%       [sts, out] = pspm_pupil_gaze_distance2degree(fn, from, height, width, distance, options)
%
%   INPUT:
%       fn:              The actual data file gaze data
%
%       from:            Distance unit to convert from.
%                        pixel, mm, cm, m, inches
%                        (Unit: mm)
%
%       height:          Height of the screen in the units chosen in the 'from' parameter
%
%       width:           Width of the screen in the units chosen in the 'from' parameter
%
%       distance:        Subject distance from the screen in the units chosen in the 'from' parameter
%
%   OUTPUT:
%     sts:               Status determining whether the execution was
%                        successfull (sts == 1) or not (sts == -1)
%     out:               Output struct
%       .channel           Id of the added channels.


% distance to degree conversion
[lsts, infos, data] = pspm_load_data(fn,0);

dataIdx = find(cellfun(@(c) strncmp(c.header.chantype, 'gaze_', numel('gaze_')) & strcmp(c.header.units, from), data));

for d = dataIdx'
  if (strcmp(from, 'pixel'))
    [sts, out] = pspm_convert_pixel2unit(fn, d, 'pixel', width, height, distance, options);
    return;
  elseif (~strcmp(from, 'mm'))
    [sts, out ] = pspm_convert_unit(data{d}.data, from, 'mm');
    if (~sts)
      return;
    end
    temp_channel = data{d};
    temp_channel.data = out;
    temp_channel.header.units = "mm";
    [lsts, outinfo] = pspm_write_channel(fn, { temp_channel }, 'add');
  end

  % write to file with channel action
  options.channel_action = 'replace';
  [sts, out] = pspm_compute_visual_angle(fn, 0, width, height, distance, 'mm', options);
end