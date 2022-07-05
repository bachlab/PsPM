function [sts, infos] = pspm_write_channel(fn, newdata, chan_action, options)
% pspm_write_channel adds, replaces and deletes channels in an existing
% data file.
%
% This function is an integration of the former functions pspm_add_channel
% and pspm_rewrite_channel.
%
% FORMAT
% [sts, infos] = pspm_write_channel(fn, newdata, channel_action, options)
%
% PARAMETERS
% ┣━ fn             data file name
% ┣━ newdata        [struct()/empty] is either a new data struct or a cell array of
% ┃                 new data structs.
% ┣━ chan_action
% ┃  ┣━ 'add'       add newdata as a new channel
% ┃  ┣━ 'replace'   replace channel with given newdata
% ┃  ┗━ 'delete'    remove channel given with options.chan
% ┗━ options
%    ┣━ .msg        custom history message [char/struct()]
%    ┣━ .prefix     custom history message prefix text, but automatically added
%    ┃              action verb (only prefix defined). The text will be
%    ┃              <prefix> <action>ed on <date>
%    ┣━ .chan    specifiy which channel should be 'edited'
%    ┃              default value is 0
%    ┣━ .delete     method to look for a channel when options.channel is not an integer
%    ┃    ┣━ 'last'  (default) deletes last occurence of the given chantype
%    ┃    ┣━ 'first' deletes the first occurence
%    ┃    ┗━ 'all'   removes all occurences
%    ┃  Outputs will be written into the info struct. The structure depends on
%    ┃  the passed action and options.
%    ┗━ .chan     contains channel id of added / replaced / deleted
%                    channels.
%
% PsPM 3.0
% (C) 2015 Dominik Bach, Samuel Gerster, Tobias Moser (UZH)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
outinfos = struct();

% load options.chan
try options.chan;
catch, options.chan = 0;
end

%% Check arguments
if nargin < 1
  warning('ID:invalid_input', 'No input. Don''t know what to do.'); return;
elseif ~ischar(fn)
  warning('ID:invalid_input', 'Need file name string as first input.'); return;
elseif nargin < 3 || all(~strcmpi({'add', 'replace', 'delete'}, chan_action))
  warning('ID:unknown_action', 'Action must be defined and ''add'', ''replace'' or ''delete'''); return;
elseif ischar(options.chan) && ~any(strcmpi(options.chan,{settings.chantypes.type}))
  warning('ID:invalid_input', 'options.chan is not a valid channel type.'); return;
elseif isnumeric(options.chan) && (any(mod(options.chan,1)) || any(options.chan<0))
  warning('ID:invalid_input', 'options.chan must be a positive integer or a channel type.'); return;
elseif ~isnumeric(options.chan) && ~ischar(options.chan)
  warning('ID:invalid_input', 'options.chan must contain valid channel types or positive integers.'); return;
elseif isempty(newdata)
  if ~strcmpi(chan_action, 'delete')
    warning('ID:invalid_input', 'newdata is empty. Got nothing to %s.', chan_action); return;
  elseif options.chan == 0
    warning('ID:invalid_input', 'If options.chan is 0, a newdata structure must be provided'); return;
  end
elseif ~isempty(newdata) && ~isstruct(newdata) && ~iscell(newdata)
  warning('ID:invalid_input', 'newdata must either be a newdata structure or empty'); return;
end

%% Determine whether the data has the correct 'orientation' and try to fix it

if isstruct(newdata)
  newdata = {newdata};
end

if ~strcmpi(chan_action, 'delete')
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

%% Process other options
try options.msg; catch, options.msg = '';
end
try options.delete; catch, options.delete = 'last';
end

%% Get data
[nsts, infos, data] = pspm_load_data(fn);
if nsts == -1
  return
end
% importdata = data; % importdata is not used by following steps

%% Find channel according to action
% channels in file
fchans = [];
if ~strcmpi(chan_action, 'add')
  % Search for chan(s)
  fchans = cellfun(@(x) x.header.chantype,data,'un',0);
  if ischar(options.chan)
    if strcmpi(options.delete,'all')
      chani = find(strcmpi(options.chan,fchans));
    else
      chani = find(strcmpi(options.chan,fchans),1,options.delete);
    end
  elseif options.chan == 0
    funits = cellfun(@(x) x.header.units, data,'UniformOutput',0);
    % if the chantype matches, and unit matches if one is provided
    chani = cellfun(@(n) match_chan(fchans, funits, n), newdata, 'UniformOutput', 0);
    chani = cell2mat(chani);
  else
    chan = options.chan;
    if any(chan > numel(fchans))
      warning('ID:invalid_input', 'channel is larger than channel count in file'); return;
    else
      chani = chan;
    end
  end

  if isempty(chani)
    if strcmpi(chan_action, 'replace')
      % chan_action replace: no multi channel option possible
      % no channel found to replace
      chan_action = 'add';
    else
      warning('ID:no_matching_chans',...
        'no channel of type ''%s'' found in the file',options.chan);
      return;
    end
  end
end

if strcmpi(chan_action, 'add')
  chani = numel(data) + (1:numel(newdata));
  chantypes = cellfun(@(f) f.header.chantype, newdata, 'un', 0);
  fchans = cell(numel(data) + numel(newdata),1);
  fchans(chani,1) = chantypes;
end

%% Manage message
if ischar(options.msg) && ~isempty(options.msg)
  msg = options.msg;
else
  switch chan_action
    case 'add', v = 'added';
    case 'replace', v = 'replaced';
    case 'delete', v = 'deleted';
  end

  if isstruct(options.msg) && isfield(options.msg, 'prefix')
    prefix = options.msg.prefix;
  else
    prefix = 'Generic undocumented operation :: ';
  end
  prefix = [prefix ' Output channel ID: #%02d --'];

  msg = '';
  for i = chani'
    % translate prefix
    p = sprintf(prefix, i);
    msg = [msg, p, sprintf(' %s on %s', v, date)];
  end
  msg(end-1:end)='';
end

%% Modify data according to action
if strcmpi(chan_action, 'delete')
  data(chani) = [];
else
  data(chani,1) = newdata;
end

if isfield(infos, 'history')
  nhist = numel(infos.history);
else
  nhist = 0;
end
infos.history{nhist + 1} = msg;

% add infos to outinfo struct
outinfos.chan = chani;

%% Save data
outdata.infos = infos;
outdata.data  = data;
outdata.options.overwrite = 1;

nsts = pspm_load_data(fn, outdata);
if nsts == -1
  return
end

infos = outinfos;

sts = 1;

function matches = match_chan(existing_chans, exisiting_units, chan)
if isfield(chan.header, 'units')
  matches = find(...
    strcmpi(chan.header.chantype, existing_chans)...
    & strcmpi(chan.header.units, exisiting_units),1,'last');
else
  matches = find(strcmpi(chan.header.chantype, existing_chans) ,1,'last');
end