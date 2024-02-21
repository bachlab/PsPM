function [sts, data, pos_of_channels] = pspm_select_channels(data, channel, units)
% ● Definition
%   pspm_select_channels selects one or several channels from a provided
%   data cell array, according to channel type and units
% ● Format
%   [sts, data, pos_of_channels] = pspm_select_channels(data, channel, units)
% ● Arguments
%    data:      a data cell array as loaded by pspm_load_data 
%    channel:   [numeric] / [char]
%               ▶ numeric vector: returns these channels
%               ▶ char:     any permissible channel type, 'events' or
%                           'wave': returns all channels of this type
%   units:      any units definition (e.g., 'mm' or 'V') - can be omitted
% 
% ● History
% Introduced in PsPM 6.2

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
pos_of_channels = [];
if nargin < 2
    warning('ID:invalid_input', 'No channnel specified. Don''t know what to do.\n');
      return
elseif nargin < 3
    units = 'any';
end

%% 2 Check channel
switch class(channel)
  case 'double'
    % in this case channel is specified as a number or a vector, as double
    % the number or the vector can only be a 0 or (a) positive number(s)
    if any(channel < 0)
      warning('ID:invalid_input', 'Negative channel numbers are not allowed.');
      return
    end
  case 'char'
    % in this case channel is specified as a char
    if any(~ismember(channel, [{settings.channeltypes.type}, 'none', 'wave', 'events']))
      warning('ID:invalid_chantype', 'Unknown channel type.');
      return
    end
  otherwise
    warning('ID:invalid_input', 'Unknown channel option.');
    return
end

%% 3 Select channels 
channeltype_list = cellfun(@(x) x.header.chantype, data, 'uni', false);
channelunits_list = cellfun(@(x) x.header.units, data, 'uni', false);
if strcmp(units, 'any')
    units = channelunits_list;
end
if ischar(channel) && contains(channel, 'event')
    pos_of_channels = find(strcmpi(channelunits_list, 'events') & strcmp(channelunits_list, units));
elseif ischar(channel) && strcmpi(channel, 'wave')
    pos_of_channels = find(~strcmpi(channelunits_list, 'events') & strcmp(channelunits_list, units));
elseif ischar(channel) 
    pos_of_channels = find(contains(channeltype_list, channel) & strcmp(channelunits_list, units));
else 
    pos_of_channels = channel;
end

if isempty(pos_of_channels)
  warning('ID:non_existing_chantype',...
      'There are no channels of type ''%s'' in the datafile', channel);
    return
elseif any(pos_of_channels > numel(data))
      warning('ID:invalid_input',...
      'Input channel number(s) are greater than the number of channels in the data');
    return
else
    data = data(pos_of_channels);
end

sts = 1;