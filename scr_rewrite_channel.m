function [ sts ] = scr_rewrite_channel( fn, channel, newdata, msg, options)
%SCR_REWRITE_CHANNEL replaces or removes a channel in an existing data file
%and updates the infos
% 
% sts = scr_rewrite_channel(fn, channel)
%   Deletes channel
%       fn: data file name
%       channel: [integer/chantype] 
%           If integer(s), deletes channel(s) #'channel' 
%           If chantype, removes last (by default, see options) channel of
%           type chantype (as defined in settings).
% sts = scr_rewrite_channel(fn, channel, newdata)
%   Replace existing channel. If 'channel' is 0, replaces last channel of
%   type newdata.header.chantype.
%       newdata: data structure for the new channel, must contain
%           .data (data vector)
%           .header.sr (sample rate)
%           .header.chantype (as defined in settings)
%           .header.units (data units, or 'events')
% sts = scr_rewrite_channel(fn, channel, data, msg)
% sts = scr_rewrite_channel(fn, channel, [], msg)
%   Additionaly adds a message to the file's history.
%       msg: message for updating file history
% sts = scr_rewrite_channel(fn, ..., options)
%   Allows for additional options
%       options: option structure with following possible fields
%           .delete: ['last';'first';'all'] Can be used to modify the
%               removal process when selecting a channel by chantype.
%               'last' (default) deletes last occurence of this chantype
%               'first' deletes first one
%               'all' removes all.
%               If replacing a channel or deleting by channel number, this
%               option is ignored.
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Samuel Gerster (UZH)

% $Id: scr_rewrite_channel.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

%% Initialise & user output
% -------------------------------------------------------------------------
sts = -1;
global settings;
if isempty(settings), scr_init; end;

%% Check arguments
% -------------------------------------------------------------------------
if nargin < 1
    warning('ID:invalid_input', 'No input. Don''t know what to do.'); return;
elseif ~ischar(fn)
    warning('ID:invalid_input', 'Need file name string as first input.'); return;
elseif nargin < 2
    warning('ID:invalid_input', 'Channel must be defined.'); return;
elseif ischar(channel) && ~any(strcmpi(channel,{settings.chantypes.type}))
    warning('ID:invalid_input', 'Channel is not of a valid channel type.'); return;
elseif isnumeric(channel) && (any(mod(channel,1)) || any(channel<0))
    warning('ID:invalid_input', 'Channel must be 0, a positive integer or a channel type.'); return;
elseif nargin < 3
    if channel == 0
    	warning('ID:invalid_input', 'If channel is 0, a data structure must be provided'); return;
    end
elseif ~isstruct(newdata) 
    if ~isempty(newdata)
       warning('ID:invalid_input', 'newdata must either be a data structure or empty'); return;
    elseif channel == 0
        warning('ID:invalid_input', 'If channel is 0, a data structure must be provided'); return;
    end
end;

%% Channel deletion conditions
% -------------------------------------------------------------------------
if nargin < 3 || isempty(newdata)
    delete_flag = true;
else
    delete_flag = false;
    if isnumeric(channel) && numel(channel)>1
        warning('ID:invalid_input', 'Multiple channels selection only possible while deleting.'); return;
    end
end

%% Process options
% -------------------------------------------------------------------------
try
    if ~any(strcmpi(options.delete,{'all','first','last'}))
        warning('ID:invalid_input', 'Invalid option.delete %s. Set to default',options.delete);
        options.delete = 'last';
    elseif ~delete_flag && strcmpi(options.delete,'all')
        warning('ID:invalid_input', 'Multiple channels selection only possible while deleting.'); return;
    end
catch
    warning('ID:invalid_input', 'Invalid option.delete. Set to default');
    options.delete = 'last';
end

%% Get data
% -------------------------------------------------------------------------
[nsts, infos, data] = scr_load_data(fn);
if nsts == -1, return; end;

%% Search for channel(s)
% -------------------------------------------------------------------------
channels = cellfun(@(x) x.header.chantype,data,'un',0);
if ischar(channel)
    if strcmpi(options.delete,'all')
        channeli = find(strcmpi(channel,channels));
    else
        channeli = find(strcmpi(channel,channels),1,options.delete);
    end
elseif channel == 0
    channeli = find(strcmpi(newdata.header.chantype,channels),1,'last');
else
    channel = channel(:);
    if any(channel > numel(channels))
        warning('ID:invalid_input', 'channel is larer than channel count in file'); return;
    else
        channeli = channel;
    end
end
if isempty(channeli)
    warning('ID:invalid_input', 'no channel of type ''%s'' found in the file',channel); return;
end

%% Manage message
% -------------------------------------------------------------------------
if nargin < 4 || isempty(msg)
    modstr={'replaced','deleted'};
    msg='';
    for i=channeli'
        msg = [msg sprintf('Channel #%02d of type ''%s'' %s on %s\n; ',i,channels{i},modstr{delete_flag+1},date)];
    end
    msg(end-1:end)='';
end

%% Modify data
% -------------------------------------------------------------------------
if delete_flag
    data(channeli) = [];
else
    data{channeli} = newdata;
end
if isfield(infos, 'history')
    nhist = numel(infos.history);
else
    nhist = 0;
end;
infos.history{nhist + 1} = msg;


%% save data
% -------------------------------------------------------------------------
outdata.infos = infos;
outdata.data  = data;
outdata.options.overwrite = 1;

nsts = scr_load_data(fn, outdata);
if nsts == -1, return; end;

sts = 1;
end

