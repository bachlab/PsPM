function [sts, data_struct] = pspm_load_channel(fn, channel, channeltype)
% ● Definition
%   pspm_load_channel loads a single data channel and provides integrated 
%   channel checking logic
% ● Format
%   [sts, data_struct] = pspm_load_channel(fn, channel, channeltype)
% ● Arguments
%    fn:   [char] filename 
%    channel:   [numeric] / [char]
%               ▶ numeric: returns this channel (or the first of a vector)
%               ▶ char
%                 'marker'  returns the first maker channel 
%                           (see settings for permissible channel types)
%                 any other channel type (e.g. 'scr')
%                           returns the last channel of the respective type
%                           (see settings for permissible channel types)                         
%                 'pupil', 'sps', 'gaze_x', 'gaze_y', 'blink', 'saccade',
%                 'pupil_missing' (eyetracker channels)
%                           goes through the following precedence order, 
%                           selects the first category that is found in the
%                           data, and returns the last channel of this
%                           category
%                           1.  Combined channels (e.g., 'pupil_c')
%                           2.  Non-lateralised channels (e.g., 'pupil')
%                           3.  Best eye pupil channels
%                           4.  Any pupil channels
% ● History
% Written in 2019 by Eshref Yozdemir (University of Zurich)
% Introduced in PsPM 6.1.2

% no checking of file and channel type as this is done downstream in 
% pspm_load_data

global settings;
if isempty(settings)
  pspm_init;
end

eyetracker_channels = {'pupil', 'sps', 'gaze_x', 'gaze_y', 'blink', ...
    'saccade', 'pupil_missing'};

sts = -1; data_struct = struct();
[sts, infos, data] = pspm_load_data(fn, channel);
if sts < 1, return; end

% precedence order for eyetracker channels
if ~isnumeric(channel) && ismember(channel, eyetracker_channels)
    channeltype_list = cellfun(@(x) x.header.chantype, data, 'uni', false);
    combined_channels = find(contains(channeltype_list, ['_' settings.lateral.char.c]));
    global_channels = find(strcmp(channeltype_list, channel));
    if isfield(infos.source, 'best_eye')
        best_channels = find(contains(channeltype_list, ['_' infos.source.best_eye]));
    else
        best_channels = [];
    end
    if ~isempty(combined_channels)
        data = data(combined_channels);
    elseif ~isempty(global_channels)
        data = data(global_channels);
    elseif ~isempty(best_channels)
        data = data(best_channels);
     % else data is left unchanged
    end
end
       
% if more than one channel exists, select first/last channel and give message 
if numel(data) == 0
    warning('ID:invalid_input', 'No data of type %s contained in file %s.\n', ...
        channel, fn);
elseif numel(data) == 1
    data_struct = data{1};
elseif ischar(channel)
    if strcmp(channel, 'marker')
        data_struct = data{1};
        keyword = 'first';
    else
        data_struct = data{end};
        keyword = 'last';
    end
    fprintf('More than one channel of type ''%s'' exists. The %s one will be used.\n', ...
        channel, keyword)
else
    data_struct = data{1};
    fprintf('More than one channel provided. The first one will be used.\n', ...
        channel, keyword)
end

% if channeltype is given and channel is numeric, check if channel is of
% correct type
if isnumeric(channel) && nargin > 2 && ~strcmpi(data_struct.header.chantype, channeltype)
    warning('ID:channeltype', ... 
        'Channel type ''%s'' was expected. Channel %i is of type ''%s''.\n', ...
        channeltype, channel, data_struct.header.chantype);
end


% functions to check
% - compute visual angle (first channel?)
% - convert functions (all should allow multiple channels)

% functions changed
% - pspm_dcm
% - pspm_emg_pp
% - pspm_extract_segments
% - pspm_find_sounds
% - pspm_glm
% - pspm_tam

% functions checked
% - 
