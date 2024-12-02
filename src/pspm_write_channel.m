function [sts, infos] = pspm_write_channel(fn, newdata, channel_action, options)
% ● Description
%   pspm_write_channel adds, replaces and deletes channels in an existing
%   data file. This function is an integration of the former functions
%   pspm_add_channel and pspm_rewrite_channel.
% ● Format
%   [sts, infos] = pspm_write_channel(fn, newdata, channel_action, options)
% ● Arguments
%   *          fn : data file name
%   *     newdata : [struct()/empty] is either a new data struct or a cell
%                    array of new data structs.
%   * channel_action : accepts 'add'/'replace'/'delete'.
%                   'add':  add newdata as a new channel
%                   'replace':  replace last channel of the same type, or
%                   channel indicated with options.channel with given
%                   newdata. If no channel of the same type found, or if
%                   the channel given in options.channel is of a different
%                   type, then newdata will be added as new channel
%                   'delete': remove channel given with options.channel
%   ┌──────options
%   ├────────.msg : custom history message [char/struct()]
%   ├─────.prefix : custom history message prefix text, but automatically added action
%   │               verb (only prefix defined). The text will be <prefix> <action>
%   │               ed on <date>
%   ├────.channel : Specify which channel should be 'edited'. Default as 0.
%   │
%   └─────.delete : method to look for a channel when options.channel is not an integer,
%                    accepts 'last'/'first'/'all'.
%                    'last':   (default) deletes last occurence of the given channeltype
%                    'first':  deletes the first occurence
%                    'all':    removes all occurences
% ● Outputs
%   *         sts : the status of the function
%   ┌───────infos
%   └────.channel : contains channel id of added / replaced / deleted channels.
% ● History
%   Introduced in PsPM 3.0
%   Written in 2015 by Dominik R Bach (University of Zurich)
%                      Samuel Gerster (University of Zurich)
%                      Tobias Moser (University of Zurich)
%   Updated in 2022 by Teddy

%% 0 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
infos = struct();

if nargin < 4
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
elseif isstruct(newdata)
  newdata = {newdata};
end

if ~strcmpi(channel_action, 'delete')
 [nsts, newdata] = pspm_check_data(newdata);
 if nsts < 1, return; end
end

%% 2 Get data
[nsts, infos, data] = pspm_load_data(fn);
if nsts == -1
  return
end

%% 3 Find channel according to action
% channels in file
if ~strcmpi(channel_action, 'add')
    % Search for matching channel(s) with pspm_select_channels
    if ischar(options.channel)
        warning off
        % this is a routine check whether channel of given type exists; no
        % warning needed if not
        [sts, ~, pos_of_channels] = pspm_select_channels(data, options.channel);
        warning on
        if sts < 1
            % if no channel of the given type exists
            channeli = 0;
        elseif strcmpi(options.delete,'all')
            channeli = pos_of_channels;
        elseif strcmpi(options.delete, 'first')
            channeli = pos_of_channels(1);
        else
            channeli = pos_of_channels(end);
        end
    elseif all(options.channel == 0)
        % for each cell of newdata, find the matching channel to replace
        for iChannel = 1:numel(newdata)
            warning off
            [sts, ~, pos_of_channels] = pspm_select_channels(data, ...
                newdata{iChannel}.header.chantype, newdata{iChannel}.header.units);
            warning on
            if sts < 1
                channeli(iChannel) = 0;
            else
                channeli(iChannel) = pos_of_channels(end);
            end
        end
        % delete double occurrences
        [~, firsts] = unique(channeli);
        channeli(setdiff(1:numel(channeli), firsts)) = 0;
    else
        if any(options.channel > numel(data))
            warning('ID:invalid_input', 'channel is larger than channel count in file'); return;
        end
        % for each cell of newdata, find whether the chosen channel matches
        if strcmp(channel_action, 'replace')
            for iChannel = 1:numel(newdata)
                warning off
                sts = pspm_select_channels( ...
                    data(options.channel(iChannel)), ...
                    newdata{iChannel}.header.chantype, ...
                    newdata{iChannel}.header.units);
                warning on
                if sts < 1
                    channeli(iChannel) = 0;
                else
                    channeli(iChannel) = options.channel(iChannel);
                end
            end
        else
            channeli = options.channel;
        end
    end
    if sum(channeli) == 0
        if strcmpi(channel_action, 'replace')
            % channel_action replace: no channel found to replace
            channel_action = 'add';
        else
            warning('ID:no_matching_channels',...
                'no channel of type ''%s'' found in the file', options.channel);
            return;
        end
    end
end

if strcmpi(channel_action, 'add')
  channeli = numel(data) + (1:numel(newdata));
elseif strcmpi(channel_action, 'replace')
  indx = find(channeli == 0);
  if ~isempty(indx)
     channeli(indx) = numel(data) + (1:numel(indx));
  end
end

%% 4 Manage message (inaccurate if simultaneous replacing and adding occurs)
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
return


