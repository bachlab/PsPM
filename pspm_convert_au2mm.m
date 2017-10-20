function [sts, out] = pspm_convert_au2mm(varargin)
% SCR_CONVERT_AU2MM converts arbitrary unit values to milimeter values. It
% works on a PsPM file and is able to replace a channel or add the data as
% a new channel.
%
% FORMAT: 
%   [sts, out] = pspm_convert_au2mm(fn, chan, distance, options)
%   [sts, out] = pspm_convert_au2mm(data, distance, record_method, options)
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
%           distance:           distance between camera and eyes in mm
%           record_method:      either 'area' or 'diameter', tells the function
%                               what the format of the recorded data is
%                               only required if data is a numeric vector
%                               unless options.multiplicator is defined.
%           options:            a struct of optional settings
%               multiplicator:  the multiplicator in the linear conversion
%               reference_distance: distance at which the multiplicator value
%                                   was obtained. The values will be 
%                                   proportionally translated to this distance
%                                   before applying the conversion function.
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
        elseif nargin < 3
            warning('ID:invalid_input','''distance'' is required.');
            return;
        else
            distance = varargin{3};
            chan = varargin{2};
            record_method = '';
            opt_idx = 4;
        end
        
    elseif isnumeric(varargin{1})
        mode = 'data';
        data = varargin{1};
        if nargin < 2
            warning('ID:invalid_input','''distance'' is required.');
            return;
        elseif nargin < 3
            warning('ID:invalid_input',['''record_method'' or ', ...
                '''options.m'' is required.']);
            return;
        else
            distance = varargin{2};
            fn = '';
            chan = -1;
            if isstruct(varargin{3})
                opt_idx = 3;
                record_method = '';
            else
                opt_idx = 4;
                record_method = varargin{3};
            end
        end
        
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

% check if everything is needed for conversion
if strcmpi(mode, 'data') && strcmpi(record_method, '') && ...
        (~isstruct(options) || ~isfield(options, 'multiplicator'))
    warning('ID:invalid_input', ['If only a numeric data vector ', ...
        'is provided, either ''record_method'' or ', ...
        'options.multiplicator have to be specified.']); 
    return;
end

if ~isfield(options, 'reference_distance')
    options.reference_distance = 700;
end

if ~isfield(options, 'channel_action')
    options.channel_action = 'add';
end
    
%% check values
if ~ischar(fn)
    warning('ID:invalid_input', 'fn is not a char.'); 
    return;
elseif ~isnumeric(data)
    warning('ID:invalid_input', 'data is not numeric.'); 
    return;
elseif ~isnumeric(distance)
    warning('ID:invalid_input', 'distance is not numeric.'); 
    return;
elseif ~isnumeric(chan)
    warning('ID:invalid_input', 'chan is not numeric.'); 
    return;
elseif ~isempty(record_method) && ...
        ~any(strcmpi(record_method, {'area', 'diameter'}))
    warning('ID:invalid_input', ['''record_method'' should be ''area'' ', ...
        'or ''diameter''']);
    return;
elseif ~any(strcmpi(options.channel_action, {'add', 'replace'}))
    warning('ID:invalid_input', ['options.channel_action must be either ', ...
        '''add'' or ''replace''.']); 
    return;
end

%% do conversion
switch mode
    case 'file'
        [f_sts, infos, data] = pspm_load_data(fn, chan);

        if f_sts ~= 1
            warning('ID:invalid_input', 'Error while load data.');
            return;
        end
        d = data{1}.data;
        
        if ~isfield(infos.source, 'elcl_proc') || ...
                ~strcmpi(infos.source.elcl_proc, 'ellipse')
            warning('ID:invalid_input', ['Cannot convert since ', ...
                'elcl_proc does not seem to be ''ellipse''.']);
            return;
        end

        % use default multiplicator if multiplicator is not set properly
        if ~isfield(options, 'multiplicator') || ...
                ~isnumeric(options.multiplicator)
            switch lower(data{1}.header.units)
                case 'area'
                    m = 0.12652;
                    % remove quadratic term
                    d = sqrt(d);
                case 'diameter'
                    m = 0.00087743;
                otherwise
                    warning('ID:invalid_input', ['Cannot set multiplicator', ...
                        ' because unit of data is invalid.'])
                    return;
            end
        else
            m = options.multiplicator;
        end
        
    case 'data'
        d = data;
        if ~strcmpi(record_method, '')
            switch lower(record_method)
                case 'area'
                    m = 0.11659;
                    % remove quadratic term
                    d = sqrt(d);
                case 'diameter'
                    m = 0.00079482;
                otherwise
                    warning('ID:invalid_input', ['Cannot set multiplicator', ...
                        ' because ''record_method'' is invalid.'])
                    return;
            end
        elseif isfield(options, 'multiplicator') && ...
                isnumeric(options.multiplicator)
            m = options.multiplicator;
        else
            warning('ID:invalid_input', ['Cannot set multiplicator', ...
                ' because ''options.multiplicator'' and ''record_method'' ', ...
                'are invalid.']);
            return;
        end
end


d = m*(d*distance/options.reference_distance);

switch mode
    case 'file'
        data{1}.data = d;
        data{1}.header.units = 'mm';
        [f_sts, f_info] = pspm_write_channel(fn, data{1},...
            options.channel_action);
        sts = f_sts;
        out.chan = f_info.channel;
        out.fn = fn;
    case 'data'
        out = d;
end
