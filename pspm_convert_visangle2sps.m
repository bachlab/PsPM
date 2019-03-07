function [ sts, out ] = pspm_convert_visangle2sps(fn, options)
%   pspm_convert_visangle2sp_speed takes a file with data from eyelink recordings
%   and computes by time units normalized distances bewteen visual angle data.
%   It saves the result into a new channel with chaneltype 'sps' (Scanpath speed).
%   It is important that pspm_convert_visangle2sps only takes channels
%   which are in visual angle.

%   FORMAT:
%     [ sts, out ] = pspm_convert_visangle2sp_speed(fn, options)
%   ARGUMENTS:
%              fn:             The actual data file containing the eyelink
%                              recording with gaze data
%              options.
%                  chans:      On which subset of the channels the visual
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
end
if isfield(options, 'chans')
    channels = options.chans;
    if ~isnumeric(channels)
        warning('ID:invalid_input', 'Channels must be defined by their id.');
        return;
    end;
else
    channels = 0;
end

if ~isfield(options, 'eyes')
    options.eyes = 'all';
end;
if ~isfield(options, 'channels')
    options.channels = {'pupil'};
end

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

%iterate through eyes
n_eyes = numel(infos.source.eyesObserved);

for i=1:n_eyes
    eye = lower(infos.source.eyesObserved(i));
    if strcmpi(options.eyes, 'all') || strcmpi(options.eyes(1), eye)
        gaze_x = ['gaze_x_', eye];
        gaze_y = ['gaze_y_', eye];
        
        gx = find(cellfun(@(x) strcmpi(gaze_x, x.header.chantype) & ...
            strcmpi('degree', x.header.units), data),1);
        gy = find(cellfun(@(x) strcmpi(gaze_y, x.header.chantype) & ...
            strcmpi('degree', x.header.units), data),1);
        
        if ~isempty(gx) && ~isempty(gy)
            
            % get channel specific data
            lon = data{gx}.data;
            lat = data{gy}.data;
%             lat = data{gy}.header.range(2)-lat;
            
            % first interpolate longitude to evict NaN-values
            [bsts,outdata]=pspm_interpolate(lon);
            if bsts ~= 1
                warning('ID:invalid_input', 'Could not load interpolate longitude data correctly.');
                return;
            end
            lon = outdata;
            
            % first interpolate latitude to evict NaN-values
            [bsts,outdata]=pspm_interpolate(lat);
            if bsts ~= 1
                warning('ID:invalid_input', 'Could not load interpolate latitude data correctly.');
                return;
            end
            lat = outdata;
            
            %compare if length are the same
            N = numel(lon);
            if N~=numel(lat)
                warning('ID:invalid_input', 'length of data in gaze_x and gaze_y is not the same');
                return;
            end;
            
            %convert lon and lat into radians
            lon = deg2rad(lon);
            lat = deg2rad(lat);
            % compute distances
            arclen = zeros(length(lat),1);
            
            for k = 2:length(lat)
                lon_diff = abs(lon(k-1)-lon(k));
                arclen(k) = atan(sqrt(((cos(lat(k))*sin(lon_diff))^2)+(((cos(lat(k-1))*sin(lat(k)))-(sin(lat(k-1))*cos(lat(k))*cos(lon_diff)))^2))/((sin(lat(k-1))*sin(lat(k)))+(cos(lat(k-1))*cos(lat(k))*cos(lon_diff))));
            end
            % create new channel with data holding distances
            dist_channel.data = rad2deg(arclen);
            dist_channel.header.chantype = 'sps';
            dist_channel.header.sr = data{gx}.header.sr;
            dist_channel.header.units = 'degree';
            
            
            [lsts, outinfo] = pspm_write_channel(fn, dist_channel, 'add');
            
            if lsts ~= 1
                warning('ID:invalid_input', '~Distance channel could not be written');
                return;
            end;
            
            out(i) = outinfo;
            
        else
            warning('ID:invalid_input', ['Unable to perform visangle2', ...
                'sps. Cannot find gaze channels with degree ',...
                'unit values. Maybe you need to convert them with ', ...
                'pspm_convert_pixel2unit()']);
        end;
    end;
end;

sts = 1;
end

