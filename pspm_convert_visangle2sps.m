function [ sts, out ] = pspm_convert_visangle2sps(fn, options)
%   pspm_convert_visangle2sp_speed takes a file with data from eyelink recordings
%   and computes by time units normalized distances bewteen visual angle data.
%   It saves the result into a new channel with chaneltype 'sp_s' (Scanpath speed).
%   It is important that pspm_convert_visangle2sp_speed only takes channels
%   which are in visual angle.

%   FORMAT:
%     [ sts, out ] = pspm_convert_visangle2sp_speed(fn, options)
%   ARGUMENTS:
%              fn:             The actual data file containing the eyelink
%                              recording with gaze data
%              options.
%                  chans:       On which subset of the channels the visual
%                              angles between the data point should be
%                              computed             .
%                              If no channels are given then the function
%                              computes the scanpath speed of the first
%                              found gaze data channels with type 'degree'
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

% check missing input --
if nargin<1
    warning('ID:invalid_input', 'Nothing to do.'); return;
elseif nargin<2
    channels = 0;
    options = struct('eyes','all');
elseif isfield(options, 'chans')
    channels = option.chans;
    if ~isnumeric(channels)
        warning('ID:invalid_input', 'Channels must be defined by their id.');
        return;
    elseif ~isfield(options, 'eyes')
        options.eyes = 'all';
    end;
else
    warning('ID:invalid_input', 'You must choose two channels or none');
    return;
end;

% fn
if ~ischar(fn) || ~exist(fn, 'file')
    warning('ID:invalid_input', ['File %s is not char or does not ', ...
        'seem to exist.'], fn); return;
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
% first interpolate NaN-values
options_temp = struct('overwirte',1,'replace_channels',1);
[bsts,outdata]=pspm_interpolate(data,options_temp);
if bsts ~= 1
    warning('ID:invalid_input', 'Could not load interpolate data correctly.');
    return;
end
data = outdata;

%iterate through eyes
n_eyes = numel(infos.source.eyesObserved);

for i=1:n_eyes
    eye = lower(infos.source.eyesObserved(i));
    if strcmpi(options.eyes, 'all') || strcmpi(options.eyes(1), eye)
        gaze_x = ['gaze_x_', eye];
        gaze_y = ['gaze_y_', eye];
        
        % always use first found channel
        
        gx = find(cellfun(@(x) strcmpi(gaze_x, x.header.chantype) & ...
            strcmpi('degree', x.header.units), data),1);
        gy = find(cellfun(@(x) strcmpi(gaze_y, x.header.chantype) & ...
            strcmpi('degree', x.header.units), data),1);
        
        if ~isempty(gx) && ~isempty(gy)
            
            % get channel specific data
            lon = data{gx}.data;
            lat = data{gy}.data;
            
            
            %compare if length are the same
            N = numel(lon);
            if N~=numel(lat)
                warning('ID:invalid_input', 'length of data in gaze_x and gaze_y is not the same');
                return;
            end;
            
            % compute distances
            arclen = zeros(length(lat),1);
   
            for k = 2:length(lat)
                lat_diff = abs(lat(k-1)-lat(k));
                lon_diff = abs(lon(k-1)-lon(k));
                a = (sin(lat_diff/2))^2 + cos(lat(k-1))* cos(lat(k))*(sin(lon_diff/2))^2;
                arclen(i) = 2 * atan2(sqrt(a),sqrt(1 - a));
            end
            % create new channel with data holding distances
            dist_channel.header.chantype = 'sps';
            dist_channel.header.sr = data{gx}.header.sr;
            dist_channel.header.units = 'degree';
            dist_channel.data = arclen;
            
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

