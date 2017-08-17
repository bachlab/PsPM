function [sts, out] = pspm_convert_au2mm(varargin)
% SCR_CONVERT_AU2MM converts arbitrary unit values to milimeter values. It
% works on a PsPM file and is able to replace a channel or add the data as
% a new channel.
%
% FORMAT: 
%   [sts, out] = pspm_convert_au2mm(fn, chan, options)
%   [sts, out] = pspm_convert_au2mm(data, options)
%
% ARGUMENTS: 
%           fn:                 filename which contains the channels to be
%                               converted
%           data:               a one-dimensional vector which contains the
%                               data to be converted
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


%% load alternating inputs
if nargin < 1 
    warning('ID:invalid_input', 'No arguments given. Don''t know what to do.');
    return;
else
    if ischar(varargin{1})
        fn = varargin{1};
        mode = 'file';
        data  = -1;
        if nargin < 2
            warning('ID:invalid_input', ['Channel to be converted not ', ...
                'given. Don''t know what to do.']);
            return;
        else
            chan = varargin{2};
        end
        
        opt_idx = 3;
    elseif isnumeric(varargin{1})
        mode = 'data';
        data = varargin{1};
        fn = '';
        chan = -1;
        opt_idx = 2;
    end
    
    if nargin >= opt_idx
        options = varargin{opt_idx};
    end
    
end

%% set default values
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
    
%% check values
if ~ischar(fn)
    warning('ID:invalid_input', 'fn is not a char.'); return;
elseif ~isnumeric(data)
    warning('ID:invalid_input', 'data is not numeric.'); return;
elseif ~isnumeric(chan)
    warning('ID:invalid_input', 'chan is not numeric.'); return;
elseif ~isnumeric(options.offset)
    warning('ID:invalid_input', 'options.offset is not numeric.'); return;
elseif ~isnumeric(options.multiplicator)
    warning('ID:invalid_input', 'options.multiplicator is not numeric.'); return;
elseif ~any(strcmpi(options.channel_action, {'add', 'replace'}))
    warning('ID:invalid_input', 'options.channel_action must be either ''add'' or ''replace''.'); return;
end

%% do conversion
switch mode
    case 'file'
        [f_sts, infos, data] = pspm_load_data(fn, chan);
        if f_sts ~= 1
            warning('ID:invalid_input', 'Error while load data.');
            return;
        end
        
        if ~isfield(infos.source, 'elcl_proc') || ~strcmpi(infos.source.elcl_proc, 'ellipse')
            warning('ID:invalid_input', 'Cannot convert since elcl_proc does not seem to be ''ellipse''.');
            return;
        end
        
        d = data{1}.data;
    case 'data'
        d = data;
end


d = options.offset + options.multiplicator*d;

switch mode
    case 'file'
        data{1}.data = d;
        data{1}.header.units = 'mm';
        [f_sts, f_info] = pspm_write_channel(fn, data{1}, options.channel_action);
        sts = f_sts;
        out.chan = f_info.channel;
        out.fn = fn;
    case 'data'
        out = d;
end
