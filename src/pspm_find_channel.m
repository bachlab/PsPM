function varargout = pspm_find_channel(headercell, channeltype)
% ● Description
%   pspm_find_channel searches a cell arrays of channel headers and
%   finds the channel that matches the desired type.
% ● Format
%   [sts, channel] = pspm_find_channel(headercell, channeltype) or
%   channel = pspm_find_channel(headercell, channeltype)
% ● Arguments
%   headercell: cell array of names (e.g. from acq import)
%     channeltype: an allowed channel type (char) (or a cell array of possible
%               channel names for operations on non-allowed input channel types)
% ● Outputs
%   the channel number (not physical channel number) that matches namestrings
%   0 if no channel matches namestrings
%   -1 if more than one channel matches namestrings
% ● History
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Updated in 2022 by Teddy Chao

%% 0 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
channel = [];
switch nargout
  case 1
    varargout{1} = channel;
  case 2
    varargout{1} = sts;
    varargout{2} = channel;
end
%% 1 check input
if nargin < 2
  warning('ID:invalid_input', '\Not enough input arguments.\n');
elseif ~iscell(headercell)
  warning('ID:invalid_input', '\nHeader input must be a cell array of char.\n'); return;
end
if ischar(channeltype)
  if ~ismember(channeltype, {settings.channeltypes.type})
    warning('ID:not_allowed_chantype', '\nChannel type %s not allowed.\n', channeltype); return;
  else
    namestrings = settings.import.channames.(channeltype);
  end
elseif iscell(channeltype)
  namestrings = channeltype;
  channeltype = 'special';
else
  warning('ID:invalid_input', '\nChannel type must be a string.\n'); return;
end
%% 2 Loop through channels
channelflag = 0;
for channel = 1:numel(headercell)
  for name = 1:numel(namestrings)
    if ~isempty(strfind(lower(headercell{channel}), namestrings{name}))
      channelflag(channel)=1;
    end
  end
end
%% 3 define output and give warnings
if sum(channelflag) > 1
  channel = -1;
  if ~strcmpi(channeltype, 'special')
    warning('ID:multiple_matching_channels', '\nChannel of type ''%s'' could not be identified from its name - there are two possible channels.\n', ...
      channeltype);
  end
elseif sum(channelflag) == 0
  channel = 0;
  if ~strcmpi(channeltype, 'special')
    warning('ID:no_matching_channels', '\nChannel of type ''%s'' could not be identified from its name - no matching channel was found.\n', ...
      channeltype);
  end
else
  channel = find(channelflag==1);
end
%% 4 Sort output
sts = 1;
switch nargout
  case 1
    varargout{1} = channel;
  case 2
    varargout{1} = sts;
    varargout{2} = channel;
end
return
