function [sts, outchannel] = pspm_multi_channel(fhandle, channels, varargin)
% ● Description
%   pspm_multi_channel applies the same pre-processing function to multiple 
%   channels in the same data file. This works by calling the pre-processing 
%   function multiple times and so does accelerate processing time. It 
%   creates the required loop and handles any processing errors.
% ● Format
%   [sts, channel_index] = pspm_multi_channel(function, channels, argument1, argument2, ..., options) 
% ● Arguments
%            fhandle: [char or function handle] Preprocessing function
%           channels: [char, vector, cell array] Channel specification
%                     1. Eyetracker channels without lateralisation
%                     specification (_r or _l) will be expanded to include
%                     both eyes (i.e. 'pupil' will be expanded to 
%                     {'pupil_r', 'pupil_l'}, which work on the last
%                     channel of this type.
%                     2. Any other valid channel identifier of type 'char' 
%                     will work on all channels of this type in the file.
%                     3. Any numerical vector or cell array will work on
%                     the specified channels.
%     argument1, ...: all input arguments for the pre-processing function
%            options: must always be specified as the last input argument
% ● Output
%                sts: Status determining whether the execution was
%                     successful (sts == 1) or not (sts == -1)
%      channel_index: Index of the generated channels. Any unsuccesful 
%                     pre-processing call leads to a NaN index
% ● History
%   Written in 2024 by Dominik R Bach (Uni Bonn)
% 

%% 1 Initialise
global settings;
if isempty(settings)
  pspm_init;
end
sts = -1;
outchannel = NaN;

%% 3 Expand channels
if ischar(channels) && ismember(channels, settings.eyetracker_channels) 
    [sts, eye] = pspm_find_eye(channels);
    if sts < 1, return; end
    if strcmpi(eye, '')
        channels = {[channels, '_r'], [channels, '_l']};
    end
end

if ischar(channels)
    % all pre-processing functions take filename as first argument
    fn = varargin{1};
    [sts, infos, data, filestruct] = pspm_load_data(fn, channels);
    if sts < 1, return; end
    channels = filestruct.posofchannels;
elseif isnumeric(channels)
    channels = num2cell(channels);
elseif ~iscell(channels) 
    warning('ID:invalid_input', 'Channels must be numeric, char or cell.')
    return
end

%% 4 Process channels
options = varargin{end};
varargin(end) = [];
for i_channel = 1:numel(channels)
    options.channel = channels{i};
    [csts(i), outchannel] = feval(fhandle, varargin{:}, options);
    if csts(i) == 1
        channel_index(i) = outchannel;
    else
        channel_index(i) = NaN;
    end
end
sts = 1;