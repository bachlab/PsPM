function [sts, out] = pspm_convert_gaze_coords(fn, options)
% Allows to transfer the pupil data from pixel to different centimeter.
%
% Usage:
%   [sts, outdata] = pspm_convert_gaze_coords(indata, options)
%       
% Arguments:
%
%   fn:                         Filename to convert..
%   options:                    Options struct
%       width:                  Width in centimeter of the display window.
%                               Default is 15 cm.
%       height:                 Height in centimeter of the display window.
%                               Default is 15 cm.
%       channel_action:         'add', 'replace' new channels.
%       
% Return values:
%
%   sts:                        Status determining whether the execution was 
%                               successfull (sts == 1) or not (sts == -1)
%   out:                        Output struct
%       .channel                Id of the added channels.
%__________________________________________________________________________
% PsPM 4.0
% (C) 2016 Tobias Moser (University of Zurich)

% $Id: pspm_find_valid_fixations.m 512 2017-12-15 13:13:08Z tmoser $
% $Rev: 512 $
global settings;
if isempty(settings), pspm_init; end
sts = -1;

% try to set default values
if ~exist('options', 'var')
    options = struct();
end

if ~isfield(options, 'width') 
    options.width = 15;
end

if ~isfield(options, 'height') 
    options.height = 15;
end

if ~isfield(options, 'channel_action') 
    options.channel_action = 'add';
end


% do value checks
if ~isstruct(options) 
    warning('ID:invalid_input', 'Options must be a struct.');
    return;
elseif ~isnumeric(options.width)
    warning('ID:invalid_input', 'Options.width must be numeric');
    return;
elseif ~isnumeric(options.height)
    warning('ID:invalid_input', 'Options.height must be numeric');
    return;
end

% load data to convert
[lsts, ~, data] = pspm_load_data(fn);
if lsts ~= 1 
    warning('ID:invalid_input', 'Could not load input data correctly.');
    return;
end

% find pupil channels
pup_idx = cellfun(@(x) ~isempty(...
    regexp(x.header.chantype, 'gaze_[x|y]_[r|l]', 'once')), data);

gaze_chans = data(pup_idx);
n_chans = numel(gaze_chans);

% do conversion
for c = 1:n_chans
    chan = gaze_chans{c};
    if strcmpi(chan.header.units, 'pixel')

        % pick conversion factor according to channel type x / y coord
        if ~isempty(regexp(chan.header.chantype, 'gaze_x_'))
            fact = options.width;
        else
            fact = options.height;
        end

        % convert according to range
        chan.data = (chan.data-chan.header.range(1)) ...
            / diff(chan.header.range) * fact;

        % convert range
        chan.header.range = (chan.header.range-chan.header.range(1)) ...
            ./ diff(chan.header.range) * fact;

        chan.header.units = 'cm';
    else
        warning('ID:invalid_input', ['Not converting (%s) because ', ...
            'input data is not in pixel.'], chan.header.chantype);
    end

    % replace data 
    gaze_chans{c} = chan;
end

[lsts, outinfo] = pspm_write_channel(fn, gaze_chans, options.channel_action);
if lsts ~= 1
    warning('ID:invalid_input', 'Could not write converted data.');
    return;
end

sts = 1;
out = outinfo;

end
