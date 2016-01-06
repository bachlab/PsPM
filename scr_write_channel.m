function [sts, infos] = scr_write_channel(fn, newdata, action, options)
% scr_write_channel adds, replaces and deletes channels in an existing
% data file.
%
% This function is an integration of the former functions scr_add_channel 
% and scr_rewrite_channel. 
%
% [sts, infos] = scr_write_channel(fn, newdata, action, options)
%   fn: data file name
%
%   newdata: [struct()/empty]
%            is either a new data struct or a cell array of new data
%            structs. 
%
%   action: 'add'       add newdata as a new channel
%           'replace'   replace channel with given newdata
%           'delete'    remove channel given with options.channel
%   
%   options: .msg       custom history message [char/struct()]
%               .prefix     custom history message prefix text, but
%                           automatically added action verb (only
%                           prefix defined). The text will be
%                           <prefix> <action>ed on <date>
%
%            .channel   specifiy which channel should be 'edited'
%                       default value is 0
%
%            .delete    ['last';'first;'all'] 
%                       method to look for a channel when
%                       options.channel is not an integer

%                       * 'last' (default) deletes last occurence of the
%                          given chantype
%                       * 'first' deletes the first occurence
%                       * 'all' removes all occurences
% 
%   Outputs will be written into the info struct. The structure depends on
%   the passed action and options.
%       
%           .channel    contains channel id of added / replaced / deleted
%                       channels.
% 
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Dominik Bach, Samuel Gerster, Tobias Moser (UZH)

% $Id$
% $Rev$

%% Initialise & user output
% -------------------------------------------------------------------------
sts = -1;
global settings;
if isempty(settings), scr_init; end;
outinfos = struct();

%% load options.channel
% -------------------------------------------------------------------------
try options.channel; catch, options.channel = 0; end;

%% Check arguments
% -------------------------------------------------------------------------
if nargin < 1
    warning('ID:invalid_input', 'No input. Don''t know what to do.'); return;
elseif ~ischar(fn)
    warning('ID:invalid_input', 'Need file name string as first input.'); return;
elseif nargin < 3 || all(~strcmpi({'add', 'replace', 'delete'}, action))
    warning('ID:unknown_action', 'Action must be defined and ''add'', ''replace'' or ''delete'''); return;
elseif ischar(options.channel) && ~any(strcmpi(options.channel,{settings.chantypes.type}))
    warning('ID:invalid_input', 'options.channel is not a valid channel type.'); return;
elseif isnumeric(options.channel) && (any(mod(options.channel,1)) || any(options.channel<0))
    warning('ID:invalid_input', 'options.channel must be a positive integer or a channel type.'); return;
elseif ~isnumeric(options.channel) && ~ischar(options.channel)
    warning('ID:invalid_input', 'options.channel must contain valid channel types or positive integers.'); return;
elseif isempty(newdata)
    if ~strcmpi(action, 'delete')
        warning('ID:invalid_input', 'newdata is empty. Got nothing to %s.', action); return;
    elseif options.channel == 0
        warning('ID:invalid_input', 'If options.channel is 0, a newdata structure must be provided'); return;
    end;
elseif ~isempty(newdata) && ~isstruct(newdata) && ~iscell(newdata)
       warning('ID:invalid_input', 'newdata must either be a newdata structure or empty'); return;
end;

%% Determine whether the data has the correct 'orientation' and try to fix it
% -------------------------------------------------------------------------

if isstruct(newdata)
    newdata = {newdata};
end;

if ~strcmpi(action, 'delete')    
    for i=1:numel(newdata)
        if isfield(newdata{i}, 'data')
            d = newdata{i}.data;
            [h,w] = size(d);
            if w ~= 1
                if h == 1
                    warning(['Passed struct (%i) seems to have the wrong ',
                        'orientation. Trying to transpose...'], i);
                    d = d';
                    newdata{i}.data = d;
                else
                    warning('ID:invalid_data_structure', ...
                        'Passed struct (%i) seems to have the wrong format.', i);
                    return;
                end;
            end;
        else
            warning('ID:invalid_data_strucutre', ...
                'Passed struct (%i) contains no ''.data'' field.', i);
            return;
        end;
    end;
end;

%% Process other options
% -------------------------------------------------------------------------
try options.msg; catch, options.msg = ''; end;
try options.delete; catch, options.delete = 'last'; end;

%% Get data
% -------------------------------------------------------------------------
[nsts, infos, data] = scr_load_data(fn);
if nsts == -1, return; end;

%% Find channel according to action
% -------------------------------------------------------------------------
% channels in file
fchannels = [];
if ~strcmpi(action, 'add')
    % Search for channel(s)
    fchannels = cellfun(@(x) x.header.chantype,data,'un',0);
    if ischar(options.channel)
        if strcmpi(options.delete,'all')
            channeli = find(strcmpi(options.channel,fchannels));
        else
            channeli = find(strcmpi(options.channel,fchannels),1,options.delete);
        end
    elseif options.channel == 0
        channeli = cellfun(@(x) find(strcmpi(x.header.chantype, fchannels),1,'last'), ... 
            newdata, 'UniformOutput', 0);
        channeli = cell2mat(channeli);
    else
        channel = options.channel;
        if any(channel > numel(fchannels))
            warning('ID:invalid_input', 'channel is larger than channel count in file'); return;
        else
            channeli = channel;
        end;
    end;
    
    if isempty(channeli)
        if strcmpi(action, 'replace')
            % action replace: no multi channel option possible
            % no channel found to replace
            action = 'add';
            warning('ID:no_matching_channels', 'No existing channel found, changing into ''add'' action.');
        else
            warning('ID:no_matching_channels', 'no channel of type ''%s'' found in the file',options.channel); return;
        end;
    end;
end;

if strcmpi(action, 'add')
    channeli = numel(data) + (1:numel(newdata));
    chantypes = cellfun(@(f) f.header.chantype, newdata, 'un', 0);
    fchannels = cell(numel(data) + numel(newdata),1);
    fchannels(channeli,1) = chantypes;
end;

%% Manage message
% -------------------------------------------------------------------------
if ischar(options.msg) && ~isempty(options.msg)
    msg = options.msg;
else
    switch action
        case 'add', v = 'added';
        case 'replace', v = 'replaced';
        case 'delete', v = 'deleted';
    end;
    
    if isstruct(options.msg) && isfield(options.msg, 'prefix')
        prefix = options.msg.prefix;
    else
        prefix = 'Channel #%02d of type ''%s''';   
    end;
    
    msg = '';
    for i=channeli'
        % translate prefix
        p = sprintf(prefix, i, fchannels{i});
        msg = [msg, p, sprintf(' %s on %s\n; ', v, date)];
    end;
    msg(end-1:end)='';
end;

%% Modify data according to action
% -------------------------------------------------------------------------
if strcmpi(action, 'delete')
    data(channeli) = [];
else
    data(channeli,1) = newdata;
end
if isfield(infos, 'history')
    nhist = numel(infos.history);
else
    nhist = 0;
end;
infos.history{nhist + 1} = msg;

%% add infos to outinfo struct
% -------------------------------------------------------------------------
outinfos.channel = channeli;

%% save data
% -------------------------------------------------------------------------
outdata.infos = infos;
outdata.data  = data;
outdata.options.overwrite = 1;

nsts = scr_load_data(fn, outdata);
if nsts == -1, return; end;

infos = outinfos;

sts = 1;
end