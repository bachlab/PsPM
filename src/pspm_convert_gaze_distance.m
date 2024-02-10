function [sts, channel_index] = pspm_convert_gaze_distance(fn, target, width, height, distance, options)
% ● Description
%   pspm_convert_gaze_distance takes a file with distance unit gaze data
%   and converts to visual angle or to scanpath speed. Display width and
%   height are required to translate the coordinate system to the centre of
%   the display. 
% ● Format
%   [sts, channel_index] = pspm_convert_gaze_distance(fn, target, width, height, distance, options)
% ● Arguments
%                 fn: The actual data file gaze data
%             target: target unit of conversion. degree | sps
%              width: with of the display in mm
%             height: height of the display in mm
%           distance: Subject distance from the screen in mm
%   ┌────────options
%   ├───────.channel: gaze x and y channels to work on. This can be a pair 
%   │                 of channel numbers, any pair of channel types, 'gaze', 
%   │                 which will search gaze_x and gaze_y channel according 
%   │                 to the precedence order specifie d in pspm_load_channel, 
%   │                 or 'both', which will work on 'gaze_x/y_r' and 'gaze_x/y_l'. 
%   │                 Default is 'gaze'. Channels must be in distance units
%   └.channel_action: Channel action for sps data, add / replace existing sps
%                     data (default: add)
% 
% ● Output
%                sts: Status determining whether the execution was
%                     successfull (sts == 1) or not (sts == -1)
%      channel_index: Id of the added or replaced channels.
% ● History
%   Introduced in PsPM 4.3.1
%   Written in 2020 by Sam Maxwell (University College London)

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
if options.invalid
  return
end
% Input argument validation
if ~ismember(target, { 'degree', 'sps' })
  warning('ID:invalid_input:target', 'target conversion must be sps or degree');
  return
end
if ~isnumeric(height)
  warning('ID:invalid_input:height', 'height must be numeric');
  return
end
if ~isnumeric(width)
  warning('ID:invalid_input:width', 'width must be numeric');
  return
end
if ~isnumeric(distance)
  warning('ID:invalid_input:distance', 'distance must be numeric');
  return
end
% parse channel specification
channel = options.channel;
if (iscell(channel) || isnumeric(channel)) && numel(channel) ~= 2
    warning('ID:invalid_input', 'This function operates on pairs of channels; two input channels required.');
    return
elseif isnumeric(channel)
    channel = num2cell(channel);
elseif ischar(channel)
    if strcmpi(channel, 'gaze')
        channel = {'gaze_x', 'gaze_y'};
    elseif strcmpi(channel, 'both')
        channel = {'gaze_x_r', 'gaze_y_r', 'gaze_x_l', 'gaze_y_l'};
    else 
        warning('ID:invalid_input', 'This function operates on pairs of channels; two input channels required.');
        return
    end
else
    warning('ID:invalid_input', 'Channel specification not recognised');
end
        
% load data & check units
[lsts, alldata.infos, alldata.data] = pspm_load_data(fn);
if lsts < 1, return, end
channelunits_list = cellfun(@(x) data.header.units, alldata.data, 'uni', false);
channels_correct_units = find(~contains(channelunits_list, 'degree') & ~contains(channelunits_list, 'pixel'));
gazedata = struct('infos', alldata.infos, 'data', {alldata.data(channels_correct_units)});
data = {};
for i = 1:numel(channel)
    % for numeric channel specification, check if it has the right units 
    if isnumeric(channel{i})
        if ismember(channel{i}, channels_correct_units)
            [lsts, data{i}] = pspm_load_channel(alldata, channel{i}, 'gaze');
        else
            warning(warning('ID:invalid_input', sprintf('Channel %i is has the wrong units.', channel{i}));
            return
        end
    % for channeltype specification, just consider channels in the correct units    
    else    
        [lsts, data{i}] = pspm_load_channel(gazedata, channel{i}, 'gaze');
    end
    if lsts < 1, return, end
    [lsts, data{i}.data] = pspm_convert_unit(data{i}.data, data{i}.header.units, 'mm');
    if lsts < 1, return, end
end

% convert data to visual angle, and if required, sps
for i = 1:(numel(channel)/2)
    data_x = data{(i-1) * 2 + 1}.data;
    data_y = data{(i-1) * 2 + 2}.data;
    [lat, lon, lat_range, lon_range ] = pspm_compute_visual_angle_core(data_x, data_y, width, height, distance, options);
   if numel(lat) == 1 && lat == 0, return; end
    if strcmp(target, 'degree')
        lat_chan.data = lat;
        lat_chan.header.units = 'degree';
        lat_chan.header.range = lat_range;
        lon_chan.data = lon;
        lon_chan.header.units = 'degree';
        lon_chan.header.range = lon_range;
        [sts, out] = pspm_write_channel(fn, { lat_chan, lon_chan }, options.channel_action);
        channel_index((i-1)+(1:2)) = out.channel;
    elseif strcmp(target, 'sps')
        arclen = pspm_convert_visangle2sps_core(lat, lon);
        dist_channel.data = rad2deg(arclen) .* sr;
        dist_channel.header.chantype = strcat('sps_', gaze_eye{1});
        dist_channel.header.sr = sr;
        dist_channel.header.units = 'degree';
        [sts, out] = pspm_write_channel(fn, dist_channel, options.channel_action);
        channel_index(i) = out.channel;
    end
end

