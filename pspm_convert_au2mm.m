function [sts, out] = pspm_convert_au2mm(fn, chan, options)
% SCR_CONVERT_AU2MM converts arbitrary unit values to milimeter values. It
% works on a PsPM file and is able to replace a channel or add the data as
% a new channel.
%
% FORMAT: 
%   [sts, out] = pspm_convert_au2mm(fn, chan, options)
%
% ARGUMENTS: 
%           fn:                 filename which contains the channels to be
%                               converted
%           chan:               channel id of the channel to be coverted.
%                               Expected to be numeric. The channel should
%                               contain diameter values recoreded with an
%                               Eyelink system in 'ellipse' mode.
%           options:            a struct of optional settings
%               offset:         the offset for the linear conversion 
%                               mm = offset + multiplicator*(arbitrary units)
%               multiplicator:  the multiplicator in the linear conversion
%               
%               => If multiplicator and offset are not set default values
%               are taken for a screen distance of 0.7 meters.
%
%               channel_action: tell the function whether to replace the
%                               converted channel or add the converted
%                               channel.
%               
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end
sts = -1;
out = struct();

if ~exist('options', 'var')
    options = struct();
elseif ~isstruct(options)
    warning('ID:invalid_input', 'options is not a struct.'); return;
end

if ~isfield(options, 'offset')
    options.offset = 0.07;
end

if ~isfield(options, 'multiplicator')
    options.multiplicator = 1/1325;
end

if ~isfield(options, 'channel_action')
    options.channel_action = 'add';
end
    
if ~ischar(fn)
    warning('ID:invalid_input', 'fn is not a char.'); return;
elseif ~isnumeric(chan)
    warning('ID:invalid_input', 'chan is not numeric.'); return;
elseif ~isnumeric(options.offset)
    warning('ID:invalid_input', 'options.offset is not numeric.'); return;
elseif ~isnumeric(options.multiplicator)
    warning('ID:invalid_input', 'options.multiplicator is not numeric.'); return;
elseif ~any(strcmpi(options.channel_action, {'add', 'replace'}))
    warning('ID:invalid_input', 'options.channel_action must be either ''add'' or ''replace''.'); return;
end

[f_sts, infos, data] = pspm_load_data(fn, chan);

if f_sts == 1
    % check if ellipse mode is used
    if isfield(infos.source, 'elcl_proc') && strcmpi(infos.source.elcl_proc, 'ellipse')
        % actual conversion
        data{1}.data = options.offset + options.multiplicator.*data{1}.data;
        data{1}.header.units = 'mm';
        [f_sts, f_info] = pspm_write_channel(fn, data{1}, options.channel_action);
        sts = f_sts;
        out.chan = f_info.channel;
        out.fn = fn;
    else
        warning('ID:invalid_input', 'Cannot convert since elcl_proc does not seem to be ''ellipse''.');
    end
else
    warning('ID:invalid_input', 'Error while load data.');
end