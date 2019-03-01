function [sts, out] = pspm_convert_au2unit(varargin)
% pspm_convert_au2unit converts arbitrary unit values to unit values. It
% works on a PsPM file and is able to replace a channel or add the data as
% a new channel.
%
% FORMAT: 
%   [sts, out] = pspm_convert_au2unit(fn, chan, unit, distance, options)
%   [sts, out] = pspm_convert_au2unit(data, unit, distance, record_method, 
%                                     options)
%
% ARGUMENTS: 
%           fn:                 filename which contains the channels to be
%                               converted
%           data:               a one-dimensional vector which contains the
%                               data to be converted
%           chan:               channel id of the channel to be coverted.
%                               Expected to be numeric. The channel should
%                               contain area or diameter unit values.
%           unit:               To which unit the data should be converted.
%                               possible values are mm, cm, dm, m, in, inches
%           distance:           distance between camera and eyes in units as
%                               specified in the parameter unit
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

%               reference_unit:     reference unit with which the multiplicator 
%                                   and reference_distance values were obtained
%                                   and what the output unit is once the model
%                                   has been applied.
%                                   possible values are mm, cm, dm, m, in, 
%                                   inches
%
%               channel_action:     tell the function whether to replace the
%                                   converted channel or add the converted
%                                   channel.
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
            warning('ID:invalid_input','''unit'' is required.');
            return;
        elseif nargin < 4
            warning('ID:invalid_input','''distance'' is required.');
            return;
        else
            unit = varargin{3};
            distance = varargin{4};
            chan = varargin{2};
            record_method = '';
            opt_idx = 5;
        end
        
    elseif isnumeric(varargin{1})
        mode = 'data';
        data = varargin{1};
        if nargin < 2
            warning('ID:invalid_input','''unit'' is required.');
            return;
        elseif nargin < 3
            warning('ID:invalid_input','''distance'' is required.');
            return;
        elseif nargin < 4
            warning('ID:invalid_input',['''record_method'' or ', ...
                '''options.m'' is required.']);
            return;
        else
            unit = varargin{2};
            distance = varargin{3};
            fn = '';
            chan = -1;
            if isstruct(varargin{4})
                opt_idx = 4;
                record_method = '';
            else
                opt_idx = 5;
                record_method = varargin{4};
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
elseif ~isnumeric(chan) && ~ischar(chan)
    warning('ID:invalid_input', 'chan must be numeric or a string.'); 
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

%% try to load data
switch mode
    case 'file'
        [f_sts, infos, data] = pspm_load_data(fn, chan);

        if f_sts ~= 1
            warning('ID:invalid_input', 'Error while load data.');
            return;
        end
        convert_data = data{1}.data;
        % set multiplicator field according to 
        % data units
        conv_field = regexprep(data{1}.header.units, '(.*) units', '$1');
    case 'data'
        convert_data = data;
        conv_field = record_method;
end

%% set conversion values

ref_dist = NaN;
ref_unit = '';
m = NaN;

% load default conversion values
if ~isfield(options, 'multiplicator') || ...
    ~isfield(options, 'reference_distance')

    % load conversion values
    % from file and as backup use hardcoded values
    if exist('pspm_convert.mat', 'file')
        convert = load('pspm_convert.mat');
    else
        % use default values
        convert = struct('au2unit', ...
            struct(...
            'area', struct('multiplicator', 0.12652, ...
                'reference_distance', 700, ...
                'reference_unit', 'mm', ...
                'square_root', 1), ...
            'diameter', struct('multiplicator', 0.00087743, ...
                'reference_distance', 700, ...
                'reference_unit', 'mm', ...
                'square_root', 0)) ...
        );
    end

    if any(strcmp(conv_field, fieldnames(convert.au2unit)))
        % get conversion struct
        conv_struct = subsref(convert.au2unit, struct('type', '.', ...
            'subs', conv_field));

        % set values
        m = conv_struct.multiplicator;
        ref_dist = conv_struct.reference_distance;
        ref_unit = conv_struct.reference_unit;

        if conv_struct.square_root 
            convert_data = sqrt(convert_data);
        end
    else
        warning('ID:invalid_input', 'Cannot load default multiplicator value.');
        return;
    end
end

% set to option if is set and numeric
if isfield(options, 'reference_distance')
    if ~isnumeric(options.reference_distance)
        warning('ID:invalid_input', ...
            'options.reference_distance must be numeric.');
        return;
    else
        ref_dist = options.reference_distance;
    end
end

% set to according option if set and numeric
if isfield(options, 'multiplicator')
    if ~isnumeric(options.multiplicator)
        warning('ID:invalid_input', 'options.multiplicator must be numeric.');
        return;
    else
        m = options.multiplicator;
    end
end

% set to according option if set and char
if isfield(options, 'reference_unit')
    if ~isnumeric(options.reference_unit)
        warning('ID:invalid_input', 'options.reference_unit must be char.');
        return;
    else
        ref_unit = options.reference_unit;
    end
end

% ensure reference settings are set
if isnan(ref_dist) || isnan(m) || isempty(ref_unit)
    warning('ID:invalid_input', ...
        ['Reference settings are incomplete. ', ...
        'Please specify them completely in options, or ensure ', ...
        'pspm_convert.mat is existing.']);
    return;
end


%% convert

% ensure the distance has the same unit as specified in the reference_unit
% therefore ref_dist does not need to be converted as this should already
% be in the reference_unit.
[~, distance] = pspm_convert_unit(distance, unit, ref_unit);

convert_data = m*(convert_data*distance/ref_dist);

% convert data from reference_unit to unit
[~, convert_data] = pspm_convert_unit(convert_data, ref_unit, unit);

%% create output
switch mode
    case 'file'
        data{1}.data = convert_data;
        data{1}.header.units = unit;
        [f_sts, f_info] = pspm_write_channel(fn, data{1},...
            options.channel_action);
        sts = f_sts;
        out.chan = f_info.channel;
        out.fn = fn;
    case 'data'
        out = convert_data;
        sts = 1;
end

