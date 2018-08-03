function [sts, out] = pspm_compute_visual_angle(fn,chan,width,height, distance,unit,options)
% PSPM_COMPUTE_VISUAL_ANGLE computes from gaze data the corresponding
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
%               unit:           unit in which distance is given.
%               options:        Options struct
%                  channel_action: 'add', 'replace' new channels.
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
elseif ~isstruct('options')
    options = struct();
elseif ~isfield(options, 'channel_action')
    options.channel_action = 'add';
    
end;

% check types of arguments
if ~ischar(fn) || ~exist(fn, 'file')
    warning('ID:invalid_input', ['File %s is not char or does not ', ...
        'seem to exist.'], fn); return;
elseif ~isnumeric(distance)
    warning('ID:invalid_input', 'distance is not set or not numeric.');
    return;
elseif ~ischar(unit)
    warning('ID:invalid_input', 'unit should be a char');
    return;
end;

% load data to evaluate
[lsts, infos, data] = pspm_load_data(fn,chan);
if lsts ~= 1
    warning('ID:invalid_input', 'Could not load input data correctly.');
    return;
end;

%iterate through eyes
n_eyes = numel(infos.source.eyesObserved);
r =1;
for i=1:n_eyes
    
    eye = lower(infos.source.eyesObserved(i));
    gaze_x = ['gaze_x_', eye];
    gaze_y = ['gaze_y_', eye];
    
    % always use first found channel
    
    gx = find(cellfun(@(x) strcmpi(gaze_x, x.header.chantype) & ...
        strcmpi('mm', x.header.units), data),1);
    gy = find(cellfun(@(x) strcmpi(gaze_y, x.header.chantype) & ...
        strcmpi('mm', x.header.units), data),1);
    
    if ~isempty(gx) && ~isempty(gy)
        
        visual_angl_chans{r} = data{gx};
        visual_angl_chans{r+1} = data{gy};
        
        % get channel specific data
        gx_d = data{gx}.data;
        gy_d = data{gy}.data;
        
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
        
        visual_angl_chans{r}.data = lon;
        visual_angl_chans{r}.header.units = 'degrees';
        visual_angl_chans{r}.range = [0,max(visual_angl_chans{r}.data)];
        
        visual_angl_chans{r+1}.data = lat;
        visual_angl_chans{r+1}.header.units = 'degrees';
        visual_angl_chans{r+1}.range = [0,max(visual_angl_chans{r+1}.data)];
        
        r=r+2;
    else
        pfrintf('%s eye does not contain gaze_x and gaze_y data.\n',eye);
        warning('ID:invalid_input','not enough data to compute visual angle for that eye');
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

