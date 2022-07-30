function chan = pspm_find_channel(headercell, chantype)
% pspm_find_channel searches a cell arrays of channel headers and
% finds the channel that matches the desired type.
%
% FORMAT:  chan = pspm_find_channel(headercell, chantype)
%          headercell: cell array of names (e.g. from acq import)
%          chantype: an allowed channel type (char) (or a cell array of
%                    possible channel names for operations on non-allowed
%                    input channel types)
%
% RETURNS:
% the channel number (not physical channel number) that matches namestrings
% 0 if no channel matches namestrings
% -1 if more than one channel matches namestrings
% ● Version
%   PsPM 3.0
% ● Written By
%   (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

% check input
% -------------------------------------------------------------------------
if nargin < 2
  warning('ID:invalid_input', '\Not enough input arguments.\n');
elseif ~iscell(headercell)
  warning('ID:invalid_input', '\nHeader input must be a cell array of char.\n'); return;
end;

if ischar(chantype)
  if ~ismember(chantype, {settings.chantypes.type})
    warning('ID:not_allowed_channeltype', '\nChannel type %s not allowed.\n', chantype); return;
  else
    namestrings = settings.import.channames.(chantype);
  end;
elseif iscell(chantype)
  namestrings = chantype;
  chantype = 'special';
else
  warning('ID:invalid_input', '\nChannel type must be a string.\n'); return;
end;

% loop through channels
% -------------------------------------------------------------------------
chanflag=0;
for chan=1:numel(headercell)
  for name=1:numel(namestrings)
    if ~isempty(strfind(lower(headercell{chan}), namestrings{name}))
      chanflag(chan)=1;
    end;
  end;
end;

% define output and give warnings
% -------------------------------------------------------------------------
if sum(chanflag) > 1
  chan = -1;
  if ~strcmpi(chantype, 'special')
    warning('ID:multiple_matching_channels', '\nChannel of type ''%s'' could not be identified from its name - there are two possible channels.\n', ...
      chantype);
  end;
elseif sum(chanflag) == 0
  chan = 0;
  if ~strcmpi(chantype, 'special')
    warning('ID:no_matching_channels', '\nChannel of type ''%s'' could not be identified from its name - no matching channel was found.\n', ...
      chantype);
  end;
else
  chan=find(chanflag==1);
end;