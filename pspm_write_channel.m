function varargout = pspm_write_channel(fn, newdata, channel_action, options)
% ● Description
%   pspm_write_channel adds, replaces and deletes channels in an existing
%   data file. This function is an integration of the former functions
%   pspm_add_channel and pspm_rewrite_channel.
% ● Format
%   [sts, infos] = pspm_write_channel(fn, newdata, channel_action, options)
% ● Arguments
%               fn: data file name
%          newdata: [struct()/empty] is either a new data struct or a cell
%                   array of new data structs.
%   channel_action: accepts 'add'/'replace'/'delete'
%                   'add':  add newdata as a new channel
%                   'replace':  replace channel with given newdata
%                   'delete': remove channel given with options.channel
%    ┌─────options:
%    ├────────.msg: custom history message [char/struct()]
%    ├─────.prefix: custom history message prefix text, but automatically added
%    │              action verb (only prefix defined). The text will be
%    │              <prefix> <action>ed on <date>
%    ├────.channel: specifiy which channel should be 'edited'
%    │              default value is 0
%    └─────.delete: method to look for a channel when options.channel is not an
%                   integer, accepts 'last'/'first'/'all'.
%                   'last':   (default) deletes last occurence of the given
%                             channeltype
%                   'first':  deletes the first occurence
%                   'all':    removes all occurences
% ● Outputs
%              sts:
%    ┌──────.infos: Outputs will be written into the .info struct.
%    │              The structure depends on the passed action and options.
%    └────.channel: contains channel id of added / replaced / deleted
%                   channels.
% ● History
%   Introduced in PsPM 3.0
%   Written in 2015 by Dominik R Bach (University of Zurich)
%                      Samuel Gerster (University of Zurich)
%                      Tobias Moser (University of Zurich)
%   Updated in 2022 by Teddy Chao (UCL)

%% 0 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
outinfos = struct();
switch nargout
  case 1
    varargout{1} = outinfos;
  case 2
    varargout{1} = sts;
    varargout{2} = outinfos;
end
if ~exist('options','var')
  options = struct();
end
options = pspm_options(options, 'write_channel');
if options.invalid
  return
end
%% 1 Check arguments
if nargin < 1
  warning('ID:invalid_input', 'No input. Don''t know what to do.'); return;
elseif ~ischar(fn)
  warning('ID:invalid_input', 'Need file name string as first input.'); return;
elseif nargin < 3 || all(~strcmpi({'add', 'replace', 'delete'}, channel_action))
  warning('ID:unknown_action', 'Action must be defined and ''add'', ''replace'' or ''delete'''); return;
elseif isempty(newdata)
  if ~strcmpi(channel_action, 'delete')
    warning('ID:invalid_input', 'newdata is empty. Got nothing to %s.', channel_action); return;
  elseif options.channel == 0
    warning('ID:invalid_input', 'If options.channel is 0, a newdata structure must be provided'); return;
  end
elseif ~isempty(newdata) && ~isstruct(newdata) && ~iscell(newdata)
  warning('ID:invalid_input', 'newdata must either be a newdata structure or empty'); return;
end
% Determine whether the data has the correct 'orientation' and try to fix it
if isstruct(newdata)
  newdata = {newdata};
end
if ~strcmpi(channel_action, 'delete')
  for i=1:numel(newdata)
    if isfield(newdata{i}, 'data') && isfield(newdata{i}, 'header')
      d = newdata{i}.data;
      if isempty(d) % size of d could be 0-by-1, 0-by-0, 1-by-0
        d = zeros(1,0); % generalise it as 1-by-0
        newdata{i}.data = d;
        % warning('ID:invalid_data_structure', ...
        % 'Passed struct (%i) contains an empty ''.data'' field.', i);
        % return
      else
        [h, w] = size(d); % d is not empty, h and w should be non-zero
        if w ~= 1 && h~= 1
          warning('ID:invalid_data_structure', ...
            'Passed struct (%i) seems to have the wrong format.', i);
          return
        elseif h == 1 && w~= 1
          warning('ID:invalid_data_structure', ...
            'Passed struct (%i) seems to have the wrong orientation. Trying to transpose...', i);
          d = d';
          newdata{i}.data = d;
        end
      end
    else
      warning('ID:invalid_data_strucutre', ...
        'Passed struct (%i) contains no ''.data'' or no ''.header'' field.', i);
      return
    end
  end
end
%% 2 Get data
[nsts, infos, data] = pspm_load_data(fn);
if nsts == -1
  return
end
% importdata = data; % importdata is not used by following steps

%% 3 Find channel according to action
% channels in file
fchannels = [];
if ~strcmpi(channel_action, 'add')
  % Search for channel(s)
  fchannels = cellfun(@(x) x.header.chantype,data,'un',0);
  if ischar(options.channel)
    if strcmpi(options.delete,'all')
      channeli = find(strcmpi(options.channel,fchannels));
    else
      channeli = find(strcmpi(options.channel,fchannels),1,options.delete);
    end
  elseif options.channel == 0
    funits = cellfun(@(x) x.header.units, data,'UniformOutput',0);
    % if the channeltype matches, and unit matches if one is provided
    channeli = cellfun(@(n) match_chan(fchannels, funits, n), newdata, 'UniformOutput', 0);
    channeli = cell2mat(channeli);
  else
    channel = options.channel;
    if any(channel > numel(fchannels))
      warning('ID:invalid_input', 'channel is larger than channel count in file'); return;
    else
      channeli = channel;
    end
  end

  if isempty(channeli)
    if strcmpi(channel_action, 'replace')
      % channel_action replace: no multi channel option possible
      % no channel found to replace
      channel_action = 'add';
    else
      warning('ID:no_matching_channels',...
        'no channel of type ''%s'' found in the file',options.channel);
      return;
    end
  end
end

if strcmpi(channel_action, 'add')
  channeli = numel(data) + (1:numel(newdata));
  channeltypes = cellfun(@(f) f.header.chantype, newdata, 'un', 0);
  fchannels = cell(numel(data) + numel(newdata),1);
  fchannels(channeli,1) = channeltypes;
end

%% 4 Manage message
msg = options.msg;
switch channel_action
  case 'add', v = 'added';
  case 'replace', v = 'replaced';
  case 'delete', v = 'deleted';
end
if isstruct(options.msg) && isfield(options.msg, 'prefix')
  prefix = options.msg.prefix;
else
  prefix = options.prefix;
end
prefix = [prefix ' Output channel ID: #%02d --'];
msg = '';
for i = channeli'
  % translate prefix
  p = sprintf(prefix, i);
  msg = [msg, p, sprintf(' %s on %s', v, date)];
end
msg(end-1:end) = '';

%% 5 Modify data according to action
if strcmpi(channel_action, 'delete')
  data(channeli) = [];
else
  data(channeli,1) = newdata;
end
if isfield(infos, 'history')
  nhist = numel(infos.history);
else
  nhist = 0;
end
infos.history{nhist + 1} = msg;
% add infos to outinfo struct
outinfos.channel = channeli;

%% 6 Save data
outdata.infos = infos;
outdata.data  = data;
outdata.options.overwrite = 1;
nsts = pspm_load_data(fn, outdata);
if nsts == -1
  return
end

%% 7 Sort output
infos = outinfos;
sts = 1;
switch nargout
  case 1
    varargout{1} = infos;
  case 2
    varargout{1} = sts;
    varargout{2} = infos;
end
return

function matches = match_chan(existing_channels, exisiting_units, channel)
if isfield(channel.header, 'units')
  matches = find(...
    strcmpi(channel.header.chantype, existing_channels)...
    & strcmpi(channel.header.units, exisiting_units),1,'last');
else
  matches = find(strcmpi(channel.header.chantype, existing_channels) ,1,'last');
end
