function [ sts, out ] = pspm_convert_gaze2distance(fn, options)
%   pspm_convert_gaze2distance takes a file with data from eyelink recordings
%   and computes by time units normalized distances bewteen gaze data.
%   It saves the result into a new channel with chaneltype 'sp_s' (Scanpath speed).

%   FORMAT:
%     [ sts, out ] = pspm_convert_gaze2distance(fn, options)
%   ARGUMENTS:
%              fn:             The actual data file containing the eyelink
%                              recording with gaze data
%              options.
%                              The user can specify which of the channels
%                  chan_x_id   should be evaluated. In order one has to set
%                  chan_y_id   the channel ids for the corresponding
%                              channels. Those are set in chan_x and
%                              chan_y. If no values are given, ...
%                  eyes:       Define on which eye the operations
%                              should be performed. Possible values
%                              are: 'left', 'right', 'all'. Default is
%                               'all'.
%
%   OUTPUT:
%   sts:                        Status determining whether the execution was
%                               successfull (sts == 1) or not (sts == -1)
%   out:                        Output struct
%       .channel                Id of the added channels.
%_____________________________________________________________

global settings;
if isempty(settings), pspm_init; end;
sts = -1;

% fn
if ~ischar(fn) || ~exist(fn, 'file')
    warning('ID:invalid_input', ['File %s is not char or does not ', ...
        'seem to exist.'], fn); return;
end;

%ceck if options are set
if exist('options', 'var')
    if isfield(options, 'chan_x_id') && isfield(options, 'chan_y_id')
        channels(1) = chan_x_id;
        channels(2) = chan_y_id;
    else
        warning('ID:invalid_input', 'You must choose two channels or none');
        return;
    end;
    
    if ~isfield(options, 'eyes')
        options.eyes = 'all';
    end;
else
    channels = 0;
    options = struct('eyes','all');
end;

    
if ~any(strcmpi(options.eyes, {'all', 'left', 'right'}))
    warning('ID:invalid_input', ['Options.eyes must be either ''all'', ', ...
        '''left'' or ''right''.']);
    return;
end;

% load data to evaluate
[lsts, infos, data] = pspm_load_data(fn, channels);
if lsts ~= 1
    warning('ID:invalid_input', 'Could not load input data correctly.');
    return;
end;

%iterate through eyes
n_eyes = numel(infos.source.eyesObserved);

for i=1:n_eyes
    eye = lower(infos.source.eyesObserved(i));
    if strcmpi(options.eyes, 'all') || strcmpi(options.eyes(1), eye)
        gaze_x = ['gaze_x_', eye];
        gaze_y = ['gaze_y_', eye];

        % always use first found channel
        
        gx = find(cellfun(@(x) strcmpi(gaze_x, x.header.chantype) & ...
            ~strcmpi('pixel', x.header.units), data),1);
        gy = find(cellfun(@(x) strcmpi(gaze_y, x.header.chantype) & ...
            ~strcmpi('pixel', x.header.units), data),1);
        
        if ~isempty(gx) && ~isempty(gy)
            
            % get channel specific data unit
            x_unit = data{gx}.header.units;
            y_unit = data{gy}.header.units;
            
            % get channel specific data
            gx_d = data{gx}.data;
            gy_d = data{gy}.data;
            
            % compare if units and length of data in the channels are
            % the same
            if ~strcmpi(x_unit,y_unit)
                [lsts,converted] = pspm_convert_unit(gy_d,y_unit,x_unit);
                if lsts ~= 1
                    warning('ID:invalid_input', 'Could not convert channel data correctly.');
                    return;
                end;
            else
                converted = gy_d;
            end;
            
            N = numel(gx_d);
            if N~=numel(converted)
                warning('ID:invalid_input', 'length of data in gaze_x and gaze_y is not the same');
                return;
            end;
            
            % compute distances
            start_point_x = gx_d(1:(N-1));
            end_point_x = gx_d(2:N);
            start_point_y = converted(1:(N-1));
            end_point_y = converted(2:N);
            
            x_diff = end_point_x - start_point_x;
            y_diff = end_point_y - start_point_y;
            
            data_dist = sqrt(x_diff.^2 + y_diff.^2);
            
            % create new channel with data holding distances
            dist_channel.header.chantype = 'sp_speed';
            dist_channel.header.sr = data{gx}.header.sr;
            dist_channel.header.units = x_unit;
            dist_channel.data = data_dist;
            
            [lsts, outinfo] = pspm_write_channel(fn, dist_channel, 'add');
            
            if lsts ~= 1
                warning('ID:invalid_input', '~Distance channel could not be written');
                return;
            end;
            
            out(i) = outinfo;
            
        else
            warning('ID:invalid_input', ['Unable to perform gaze2', ...
                'distances. Cannot find gaze channels with length ',...
                'unit values. Maybe you need to convert them with ', ...
                'pspm_convert_pixel2unit()']);
        end;
    end;
end;

sts = 1;
end

