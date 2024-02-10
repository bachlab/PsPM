function [sts, channel_index] = pspm_convert_gaze(fn, conversion, options)
% ● Description
%   pspm_convert_gaze converts between any gaze units or scanpath speed. 
%   Display width and height are required for conversion from pixels to relate
%   the screen pixel definition to metric units; and for conversion to 
%   degrees, to translate the coordinate system to the centre of
%   the display.
% ● Format
%   [sts, out_file] = pspm_convert_gaze_distance(fn, from, target, width, height, distance, options)
% ● Arguments
%                 fn: A data file name
%   ┌────────conversion [ struct ] with fields
%   ├──────────.from: Original units to convert from: 'pixel', a metric distance
%   │                 unit, or 'degree'
%   ├────────.target: target unit of conversion: a metric distance unit,
%   │                 'degree' or 'sps'
%   ├─────────.width: with of the display in mm (not required if 'from' is
%   │                 'degree'
%   ├────────.height: height of the display in mm (not required if 'from' is
%   │                 'degree'
%   └──────.distance: Subject distance from the screen in mm (not required
%                     if 'from' is'degree', or if 'target' is metric)
%   ┌────────options
%   ├───────.channel: gaze x and y channels to work on. This can be a pair
%   │                 of channel numbers, any pair of channel types, 'gaze',
%   │                 which will search gaze_x and gaze_y channel according
%   │                 to the precedence order specifie d in pspm_load_channel.
%   │                 Default is 'gaze'.
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
%   Refactored 2024 by Dominik Bach (Uni Bonn)


%% Initialise
global settings
if isempty(settings)
    pspm_init;
end
sts = -1;
% Number of arguments validation
if nargin < 2
    warning('ID:invalid_input','Not enough input arguments.'); return;
elseif nargin < 3
    options = struct();
end
options = pspm_options(options, 'convert_gaze');
if options.invalid
    return
end

% Input argument validation
if ~isfield(conversion, 'from') || ~ismember(conversion.from, {'pixel', 'mm', 'cm', 'm', 'degree'})
    warning('ID:invalid_input:target', 'target conversion must be sps or degree');
    return
elseif ~isfield(conversion, 'target') || ~ismember(conversion.target, { 'mm', 'cm', 'm', 'degree', 'sps' })
    warning('ID:invalid_input:target', 'target conversion must be sps or degree');
    return
end
distance_required = (~strcmpi(conversion.from, 'degree') && ismember(target, {'degree', 'sps'}));
screen_length_required = strcmpi(conversion.from, 'pixel') || distance_required;
if screen_length_required && (~isfield(conversion, 'height') || ~isnumeric(height))
    warning('ID:invalid_input:height', 'height must be numeric');
    return
elseif screen_length_required && (~isfield(conversion, 'width') || ~isnumeric(width))
    warning('ID:invalid_input:width', 'width must be numeric');
    return
elseif distance_required && (~isfield(conversion, 'distance') || ~isnumeric(distance))
    warning('ID:invalid_input:distance', 'distance must be numeric');
    return
end

% bring conversion field names to workspace
names = fieldnames(conversion);
for i=1:length(names)
    eval([names{i} '=conversion.' names{i} ]);
end

if strcmpi(from, 'pixel')
    screen_length = {width, height};
end

% Parse channel specification
channel = options.channel;
if (iscell(channel) || isnumeric(channel)) && numel(channel) ~= 2
    warning('ID:invalid_input', 'This function operates on pairs of channels; two input channels required.');
    return
elseif isnumeric(channel)
    channel = num2cell(channel);
elseif ischar(channel)
    if strcmpi(channel, 'gaze')
        channel = {'gaze_x', 'gaze_y'};
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
channelunits_list = cellfun(@(x) alldata.data.header.units, alldata.data, 'uni', false);
channels_correct_units = find(contains(channelunits_list, from));
gazedata = struct('infos', alldata.infos, 'data', {alldata.data(channels_correct_units)});
channeltypes = {'gaze_x', 'gaze_y'};
data = {};
for i = 1:numel(channel)
    % for numeric channel specification, check if it has the right units
    if isnumeric(channel{i})
        if ismember(channel{i}, channels_correct_units)
            [lsts, data{i}] = pspm_load_channel(alldata, channel{i}, 'gaze');
        else
            warning('ID:invalid_input', 'Channel %i is in units %s, expected was %s.', ...
                channel{i}, alldata.data{channel{i}}.header.units, from);
            return
        end
        % for channeltype specification, just consider channels in the correct units
    else
        [lsts, data{i}] = pspm_load_channel(gazedata, channel{i}, channeltypes{i});
    end
    if lsts < 1, return, end
end

if strcmpi(pspm_find_eye(data{1}.header.chantype), pspm_find_eye(data{2}.header.chantype))
    warning('ID:invalid_input', 'The specified pair of channels seems to come from different eyes. Please check if this is intended.')
    eye = '';
else
    eye = ['_', pspm_find_eye(data{1}.header.chantype)];
end

% convert data to metric units unless already in degree
for i = 1:numel(channel)
    if strcmpi(conversion.from, 'pixel')
        [data{i}.data, data{i}.header.range] = pspm_convert_pixel2unit_core(data{i}.data, data{i}.header.range, screen_length{i});
    elseif ~strcmpi(conversion.from, 'degree')
        [lsts, data{i}.data] = pspm_convert_unit(data{i}.data, data{i}.header.units, 'mm');
        if lsts < 1, return, end
    end
    if ~ismember(target, 'degree', 'sps')
        [lsts, data{i}.data] = pspm_convert_unit(data{i}.data, 'mm', target);
        if lsts < 1, return, end
        data{i}.header.units = target;
    else
        data{i}.header.units = 'mm';
    end
end

% convert data to non-metric target units if requested
if ismember(target, {'degree', 'sps'})
    data_x = data{1}.data;
    data_y = data{2}.data;
    if ~strcmpi(from, 'degree')
        [data_x, data_y, data_x_range, data_y_range] = pspm_convert_visual_angle_core(data_x, data_y, width, height, distance, options);
        if numel(lat) == 1 && lat == 0, return; end
    else
        data_x_range = data{chans(1)}.header.range;
        data_y_range = data{chans(2)}.header.range;
    end
end
if strcmp(target, 'degree')
    outdata = data;
    outdata{1}.data = data_x;
    outdata{1}.header.units = 'degree';
    outdata{1}.header.range = data_x_range;
    outdata{2}.data = data_y;
    outdata{2}.header.units = 'degree';
    outdata{2}.header.range = data_y_range;
elseif strcmp(target, 'sps')
    sr = data{1}.header.sr;
    arclen = pspm_convert_visangle2sps_core(data_x, data_y);
    outdata = {};
    outdata{1}.data = rad2deg(arclen) .* sr;
    outdata{1}.header.chantype = strcat('sps', eye);
    outdata{1}.header.sr = sr;
    outdata{1}.header.units = 'degree';
else
    outdata = data;
end

[sts, out] = pspm_write_channel(fn, outdata, options.channel_action);
channel_index = out.channel;
