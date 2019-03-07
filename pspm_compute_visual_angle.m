function [sts, out] = pspm_compute_visual_angle(fn,chan,width,height, distance,unit,options)
% pspm_compute_visual_angle computes from gaze data the corresponding
% visual angle (for each data point)

% FORMAT:
%        [sts, out] = pspm_compute_visual_angle(fn,chan,width,height, distance,unit,options)
%
% ARGUMENTS:    fn:             The actual data file containing the eyelink
%                               recording with gaze data
%               chan:           On which subset of channels should the conversion
%                               be done. Supports all values which can be passed
%                               to pspm_load_data(). The will only work on
%                               gaze-channels. Other channels specified will be
%                               ignored.
%               width:          Width of the display window. Unit is 'unit'.
%               height:         Height of the display window. Unit is 'unit'.
%               distance:       distance between eye and screen in length units.
%               unit:           unit in which width, height and distance are given.
%               options:        Options struct
%                  channel_action: 'add', 'replace' new channels.
%                  eyes:           Define on which eye the operations
%                                  should be performed. Possible values
%                                  are: 'left', 'right', 'all'. Default is
%                                  'all'.
% RETURN VALUES sts
%               sts:            Status determining whether the execution was
%                               successfull (sts == 1) or not (sts == -1)
%               out:            Id of the added channels.
%__________________________________________________________________________
% PsPM 4.0
global settings;
if isempty(settings), pspm_init; end;
sts = -1;

% validate input
if nargin < 6
    warning('ID:invalid_input', 'Not enough arguments.');
    return;
elseif ~exist('options','var')
    options = struct();
    options.channel_action = 'add';
end;

% check types of arguments
if ~ischar(fn) || ~exist(fn, 'file')
    warning('ID:invalid_input', ['File %s is not char or does not ', ...
        'seem to exist.'], fn); 
    return;
elseif ~isnumeric(chan)
    warning('ID:invalid_input', 'Channels must be indicated by their ID nummber.');
    return;    
elseif ~isnumeric(width)
    warning('ID:invalid_input', 'Width must be numeric.');
    return;
elseif ~isnumeric(height)
    warning('ID:invalid_input', 'Height must be numeric.');
    return;   
elseif ~isnumeric(distance)
    warning('ID:invalid_input', 'distance is not set or not numeric.');
    return;
elseif ~ischar(unit)
    warning('ID:invalid_input', 'unit should be a char');
    return;
elseif ~isstruct(options)
    warning('ID:invalid_input', 'Options must be a struct.');
    return;
end;

%set more defaults
if ~isfield(options, 'eyes')
    options.eyes = 'all';
end
if ~isfield(options, 'channels')
    options.channels = {'pupil'};
end

% load data to evaluate
[lsts, infos, data] = pspm_load_data(fn,chan);
if lsts ~= 1
    warning('ID:invalid_input', 'Could not load input data correctly.');
    return;
end;

%iterate through eyes
n_eyes = numel(infos.source.eyesObserved);
p=1;
for i=1:n_eyes
    eye = lower(infos.source.eyesObserved(i));
    if strcmpi(options.eyes, 'all') || strcmpi(options.eyes(1), eye)
        gaze_x = ['gaze_x_', eye];
        gaze_y = ['gaze_y_', eye];
        
        % find chars to replace
        str_chans = cellfun(@ischar, options.channels);
        channels = options.channels;
        channels(str_chans) = regexprep(channels(str_chans), ...
            '(pupil|gaze_x|gaze_y|pupil_missing)', ['$0_' eye]);
        % replace strings with numbers
        str_chan_num = channels(str_chans);
        for j=1:numel(str_chan_num)
            str_chan_num(j) = {find(cellfun(@(y) strcmpi(str_chan_num(j),...
                y.header.chantype), data),1)};
        end
        channels(str_chans) = str_chan_num;
        work_chans = cell2mat(channels);
        
        if numel(work_chans) >= 1
            
            % always use first found channel
            
            gx = find(cellfun(@(x) strcmpi(gaze_x, x.header.chantype) & ...
                strcmpi('mm', x.header.units), data),1);
            gy = find(cellfun(@(x) strcmpi(gaze_y, x.header.chantype) & ...
                strcmpi('mm', x.header.units), data),1);
            
            if ~isempty(gx) && ~isempty(gy)
                
                visual_angl_chans{p} = data{gx};
                visual_angl_chans{p+1} = data{gy};
                
                % get channel specific data
                gx_d = data{gx}.data;
                gy_d = data{gy}.data;
                gy_d = data{gy}.header.range(2)-gy_d;
                
                N = numel(gx_d);
                if N~=numel(gy_d)
                    warning('ID:invalid_input', 'length of data in gaze_x and gaze_y is not the same');
                    return;
                end;
                
                % move (0,0) into center of the screen
                gx_d = gx_d - width/2;
                gy_d = gy_d - height/2;
                
                %compute visual angle for gaze_x and gaze_y
                s_x = gx_d; % x axis in spherical coordinates
                s_y = distance * ones(numel(gx_d),1);% y axis in spherical coordinates, actually is the radial from participant to the screen
                s_z = gy_d;  % z axis in spherical coordinates, actually is y axis on the screen
                [azimuth, elevation, r]= cart2sph(s_x,s_y,s_z);% convert cartesian to spherical coordinates in radians, azimuth = longitude, elevation = latitude
                
                lat = rad2deg(elevation);% convert radians into degrees
                lon = rad2deg(azimuth);
                
                % azimuth angle of gaze points
                % longitude (azimuth angle from positive x axis in horizontal plane) of gaze points
                visual_angl_chans{p}.data = lon;
                visual_angl_chans{p}.header.units = 'degree';
                visual_angl_chans{p}.header.range = [min(visual_angl_chans{p}.data),max(visual_angl_chans{p}.data)];
                
                % elevation angle of gaze points,
                % latitude (elevation angle from horizontal plane) of gaze points
                visual_angl_chans{p+1}.data = lat;
                visual_angl_chans{p+1}.header.units = 'degree';
                visual_angl_chans{p+1}.header.range = [min(visual_angl_chans{p}.data),max(visual_angl_chans{p+1}.data)];
                
                p=p+2;
            else
                pfrintf('%s eye does not contain gaze_x and gaze_y data.\n',eye);
                warning('ID:invalid_input','not enough data to compute visual angle for that eye');
            end;
        else 
            warning('ID:invalid_input', ['Unable to perform gaze ', ...
                    'validation. There must be a pupil channel. Eventually ', ...
                    'only gaze channels have been imported.']);
        end;
    end;
end;

[lsts, outinfo] = pspm_write_channel(fn, visual_angl_chans, options.channel_action);
if lsts ~= 1
    warning('ID:invalid_input', 'Could not write converted data.');
    return;
end

sts = 1;
out = outinfo;
end

