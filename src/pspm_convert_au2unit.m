function [sts, out] = pspm_convert_au2unit(varargin)
% ● Description
%   pspm_convert_au2unit converts arbitrary unit values to unit values. It
%   works on a PsPM file and is able to replace a channel or add the data as
%   a new channel.
% ● Features
%   Given arbitrary unit values are converted using a recording distance D
%   given in 'unit', a reference distance Dref given in 'reference_unit', a
%   multiplicator A given in 'reference_unit'.
%   Before applying the conversion, the function takes the square root of the
%   input data if the recording method is area. This is performed to always
%   return linear units.
%   Using the given variables, the following calculations are performed:
%   0. Take square root of data if recording is 'area'.
%   1. Let from unit to reference_unit converted recording distance be Dconv.
%   2. x ← A*(Dconv/Dref)*x
%   3. Convert x from ref_unit to unit.
% ● Format
%   [sts, channel_index] = pspm_convert_au2unit(fn, channel, unit, distance, multiplicator,
%                reference_distance, reference_unit, options)
%   [sts, converted_data] = pspm_convert_au2unit(data, unit, distance, record_method,
%                multiplicator, reference_distance, reference_unit, options)
% ● Arguments
%                 fn: filename which contains the channels to be converted
%               data: a one-dimensional vector which contains the data to be
%                     converted
%               channel: Channels which should be converted from area to diameter.
%                     This can be a channel number, any channel type including 
%                     'pupil' (which will select a channel according to the 
%                     precedence order specified in pspm_load_channel), or 'both',
%                     which will work on 'pupil_r' and 'pupil_l'. 
%                     Default is 'both'. 
%               unit: To which unit the data should be converted. possible
%                     values are mm, cm, dm, m, in, inches.
%           distance: distance between camera and eyes in units as specified in
%                     the parameter unit
%      record_method: either 'area' or 'diameter', tells the function what the
%                     format of the recorded data is
%      multiplicator: the multiplicator in the linear conversion.
% reference_distance: distance at which the multiplicator value was obtained,
%                     as specified in the parameter unit.
%                     The values will be proportionally translated to this
%                     distance before applying the conversion function.
%     reference_unit: reference unit with which the multiplicator and
%                     reference_distance values were obtained.
%                     Possible values are mm, cm, dm, m, in, inches
%           options:  a struct of optional settings
%   .channel_action:  ['add'/'replace'] Defines whether the new channel should
%                     be added or the previous outputs of this function should
%                     be replaced. (Default: 'add')
% ● History
%   Introduced in PsPM 3.1
%   Written in 2016 by Tobias Moser (University of Zurich)
%   Updated in 2024 by Dominik R Bach (University of Bonn)

%% initialise
global settings
if isempty(settings)
    pspm_init;
end
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
        elseif nargin < 5
            warning('ID:invalid_input', '''multiplicator'' is required.');
            return;
        elseif nargin < 6
            warning('ID:invalid_input', '''reference_distance'' is required.');
            return;
        elseif nargin < 7
            warning('ID:invalid_input', '''reference_unit'' is required.');
            return;
        else
            unit = varargin{3};
            distance = varargin{4};
            channel = varargin{2};
            if strcmpi(channel, 'both')
                channel = {'pupil_r', 'pupil_l'};
            else
                channel = {channel};
            end
            multiplicator = varargin{5};
            reference_distance = varargin{6};
            reference_unit = varargin{7};
            record_method = '';
            opt_idx = 9;
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
            warning('ID:invalid_input', '''record_method'' is required.');
            return;
        elseif nargin < 5
            warning('ID:invalid_input', '''multiplicator'' is required.');
            return;
        elseif nargin < 6
            warning('ID:invalid_input', '''reference_distance'' is required.');
            return;
        elseif nargin < 7
            warning('ID:invalid_input', '''reference_unit'' is required.');
            return;
        else
            unit = varargin{2};
            distance = varargin{3};
            fn = '';
            channel = -1;
            record_method = varargin{4};
            multiplicator = varargin{5};
            reference_distance = varargin{6};
            reference_unit = varargin{7};
            opt_idx = 9;
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
if ~(strcmpi(record_method, 'area') || strcmpi(record_method, 'diameter'))
    warning('ID:invalid_input', 'record_method must be ''area'' or ''diameter''');
    return;
end
if ~isnumeric(distance)
    warning('ID:invalid_input', 'distance must be a numeric value');
    return;
end
if ~isnumeric(multiplicator)
    warning('ID:invalid_input', 'multiplicator must be a numeric value');
    return;
end
if ~isnumeric(reference_distance)
    warning('ID:invalid_input', 'reference_distance must be a numeric value');
    return;
end
%% check if everything is needed for conversion
if strcmpi(mode, 'data') && strcmpi(record_method, '') && ...
        (~isstruct(options) || ~isfield(options, 'multiplicator'))
    warning('ID:invalid_input', ['If only a numeric data vector ', ...
        'is provided, either ''record_method'' or ', ...
        'options.multiplicator have to be specified.']);
    return;
end
options = pspm_options(options, 'convert_au2unit');
if options.invalid
    return
end
%% check values
if ~isnumeric(data)
    warning('ID:invalid_input', 'data is not numeric.');
    return;
elseif ~isnumeric(distance)
    warning('ID:invalid_input', 'distance is not numeric.');
    return;
end

%% main part
switch mode
    % try to load data
    case 'file'
        [f_sts, alldata.infos, alldata.data] = pspm_load_data(fn);
        if f_sts < 1, return; end
        convert_data = {};
        for i = 1:numel(channel)
            [sts, channeldata] = pspm_load_channel(alldata, channel{i}, 'pupil');
            if sts < 1, return; end
            % recursive call to avoid the formula being stated twice in the same function
            [sts, convert_data.data{i}] = pspm_convert_au2unit(channeldata.data, unit, distance, record_method, ...
                multiplicator, reference_distance, reference_unit, options);
            if sts < 1, return; end
            convert_data{i}.header = channeldata.header;
            convert_data{i}.header.units = unit;
        end
        [f_sts, f_info] = pspm_write_channel(fn, convert_data, options.channel_action);
        if f_sts < 1, return; end
        out = f_info.channel;
     % convert data
    case 'data'
        convert_data = data;
        if strcmpi(record_method, 'area')
            convert_data = sqrt(convert_data);
        end
        [~, distance] = pspm_convert_unit(distance, unit, reference_unit);
        convert_data = multiplicator * (distance / reference_distance) * convert_data;
        %% convert data from reference_unit to unit
        [~, convert_data] = pspm_convert_unit(convert_data, reference_unit, unit);
        out = convert_data;
end
sts = 1;
return
