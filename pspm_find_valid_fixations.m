function [sts, out_file] = pspm_find_valid_fixations(fn,varargin)
% pspm_find_valid_fixaitons takes a file with data from eyelink recordings
% which has been converted to length units and filters out invalid fixations.
% Gaze values outside of a defined range are set to NaN, which can later
% be interpolated using pspm_interpolate. The function will create a timeseries
% with NaN values during invalid fixations (as defined by the parameters).
%
% With two options it is possible to tell the function whether to add or
% replace the channels and to tell whether the function should create a new
% file or overwrite the file given in fn.
%
% FORMAT:
%   [sts, out_file] = pspm_find_valid_fixations(fn, bitmap, options)
%   [sts, out_file] = pspm_find_valid_fixations(fn, circle_degree, distance,
%                                               unit, options)
%
% ARGUMENTS:
%           fn:                 The actual data file containing the eyelink
%                               recording with gaze data converted to cm.
%           bitmap:             A nxm matrix representing the display
%                               window and holding for each poisition a
%                               one, where a gaze value is taken into
%                               account. If there exists gaze data at a
%                               point with a zero value in the bitmap
%                               the corresponding data is set to NaN.
%           circle_degree:      size of boundary circle given in degree
%                               visual angles.
%           distance:           distance between eye and screen in length units.
%           unit:               unit in which distance is given.
%           
%           options:            Optional values
%               fixation_point:     A nx2 vector containing x and y of the
%                                   fixation point (with resepect to the
%                                   given resolution). n should be
%                                   either 1 or should have the length of
%                                   the actual data. Default is the middle
%                                   of the screen. If resolution is not defined
%                                   the values are given in percent. Therefore
%                                   [0.5 0.5] would correspond to the middle of
%                                   the screen. Default is [0.5 0.5]
%               resolution:         Resolution with which the fixation point
%                                   is defined (Maximum value of the x and y
%                                   coordinates). This can be the resolution
%                                   set in cogent (e.g. [1280 1024]) or the
%                                   width and height of the screen in cm
%                                   (e.g. [50 30]). Default is [1 1].
%               plot_gaze_coords:   Define whether to plot the gaze
%                                   coordinates for visual inspection of
%                                   the validation process. Default is
%                                   false.
%               channel_action:     Define whether to add or replace the
%                                   data. Default is 'add'. Possible values
%                                   are 'add' or 'replace'
%               newfile:            Define new filename to store data to
%                                   it. Default is '' which means that the
%                                   file under fn will be 'replaced'
%               overwrite:          Define whether existing files should be
%                                   overwritten or not. Default is 0.
%               missing:            If missing is enabled (=1), an extra
%                                   channel will be written containing
%                                   information about the validated data.
%                                   Data points equal to 1 describe epochs
%                                   which have been discriminated as
%                                   invalid during validation. Data points
%                                   equal to 0 describe epochs of valid
%                                   data (= no blink & valid fixation).
%                                   Default is disabled (=0)
%               eyes:               Define on which eye the operations
%                                   should be performed. Possible values
%                                   are: 'left', 'right', 'all'. Default is
%                                   'all'.
%               channels:           Choose channels in which the data
%                                   should be set to NaN
%                                   during invalid fixations.
%                                   Default is 'pupil'. A char or numeric
%                                   value or a cell array of char or
%                                   numerics is expected. Channel names
%                                   pupil, gaze_x, gaze_y,
%                                   pupil_missing will be automatically
%                                   expanded to the corresponding eye. E.g.
%                                   pupil becomes pupil_l or pupil_r
%                                   according to the eye which is
%                                   being processed.
%
%
%__________________________________________________________________________
% PsPM 4.0
% (C) 2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end
sts = -1;
out_file = '';

% validate input
if numel(varargin) < 1
    warning('ID:invalid_input', ['Not enough input arguments.', ...
        ' You have to either pass a bitmap or circle_degree, distance and unit',...
        ' to compute the valid fixations']); return;
end

%get imput arguments and check if correct values
if numel(varargin{1}) > 1
    mode = 'bitmap';
    bitmap = varargin{1};
    if ~ismatrix(bitmap) || (~isnumeric(bitmap) && ~islogical(bitmap))
        warning('ID:invalid_input', ['The bitmap must be a matrix and must',...
            ' contain numeric or logical values.']); return;
    end
    if numel(varargin) < 2
        options = struct();
    else
        options = varargin{2};
    end
else
    mode = 'fixation';
    if numel(varargin) < 3
        warning('ID:invalid_input', ['Not enough input arguments.', ...
            ' You have to set circle_degree, distance and unit',...
            ' to compute the valid fixations']); return;
    end
    circle_degree = varargin{1};
    distance = varargin{2};
    unit = varargin{3};
    if numel(varargin) < 4
        options = struct();
    else
        options = varargin{4};
    end
    if ~isnumeric(circle_degree)
        warning('ID:invalid_input', ['circle_degree is not set or ', ...
            'is not numeric.']);
        return;
    elseif ~isnumeric(distance)
        warning('ID:invalid_input', 'distance is not set or not numeric.');
        return;
    elseif ~ischar(unit)
        warning('ID:invalid_input', 'unit should be a char');
        return;
    end
end

% fn
if ~ischar(fn) || ~exist(fn, 'file')
    warning('ID:invalid_input', ['File %s is not char or does not ', ...
        'seem to exist.'], fn); return;
end

% load data right away (needed if fixation point should be expanded)
[msts, infos, data] = pspm_load_data(fn);
if msts ~= 1
    warning('ID:invalid_input', ['An error happened, while ', ...
        'opening the file %s.'],fn); return;
end

% check validate_fixations and then the depending mandatory fields
if ~isfield(options, 'missing')
    options.missing = false;
end

if strcmpi(mode,'fixation')&& ~isfield(options, 'resolution')
    options.resolution = [1 1];
end

if ~isfield(options, 'channels')
    options.channels = 'pupil';
end

if ~isfield(options, 'eyes')
    options.eyes = 'all';
end

if ~isfield(options, 'plot_gaze_coords')
    options.plot_gaze_coords = false;
end

if ~islogical(options.plot_gaze_coords) && ~isnumeric(options.plot_gaze_coords)
    warning('ID:invalid_input', ['Options.plot_gaze_coords must ', ...
        'be logical or numeric.']);
    return;
elseif ~islogical(options.missing) && ~isnumeric(options.missing)
    warning('ID:invalid_input', ['Options.missing is neither logical ', ...
        'nor numeric.']);
    return;
elseif ~any(strcmpi(options.eyes, {'all', 'left', 'right'}))
    warning('ID:invalid_input', ['Options.eyes must be either ''all'', ', ...
        '''left'' or ''right''.']);
    return;
elseif ~iscell(options.channels) && ~ischar(options.channels) && ...
        ~isnumeric(options.channels)
    warning('ID:invalid_input', ['Options.channels should be a char, ', ...
        'numeric or a cell of char or numeric.']);
    return;
elseif iscell(options.channels) && ...
        any(~cellfun(@(x) isnumeric(x) ||any(strcmpi(x, {'gaze_x', 'gaze_y', ...
        'pupil', 'pupil_missing'})), options.channels))
    warning('ID:invalid_input', 'Option.channels contains invalid values.');
    return;
elseif strcmpi(mode,'fixation')&& isfield(options, 'fixation_point') && ...
        (~isnumeric(options.fixation_point) || ...
        size(options.fixation_point,2) ~= 2)
    warning('ID:invalid_input', ['Options.fixation_point is not ', ...
        'numeric, or has the wrong size (should be nx2).']);
    return;
elseif isfield(options, 'resolution') && (~isnumeric(options.resolution) || ...
        ~all(size(options.resolution) == [1 2]))
    warning('ID:invalid_input', ['Options.fixation_point is not ', ...
        'numeric, or has the wrong size (should be 1x2).']);
    return;
elseif strcmpi(mode,'fixation')&& isfield(options, 'fixation_point') &&  ...
        ~all(options.fixation_point < options.resolution)
    warning('ID:out_of_range', ['Some fixation points are larger than ', ...
        'the range given. Ensure fixation points are within the given ', ...
        'resolution.']);
    return;
end

%change distance to 'mm'
if strcmpi(mode,'fixation')
    if ~strcmpi(distance,'mm')
        [nsts,distance] = pspm_convert_unit(distance,unit ,'mm');
        if nsts~=1
            warning('ID:invalid_input', 'Failed to convert distance to mm.');
        end
    end
end

% expand fixation_point
if strcmpi(mode,'fixation')
    if ~isfield(options, 'fixation_point') || isempty(options.fixation_point) ...
            || size(options.fixation_point,1) == 1
        
        % set fixation point default or expand to data size
        % find first wave channel
        ct = cellfun(@(x) x.header.chantype, data, 'UniformOutput', false);
        chan_data = cellfun(@(x) ...
            settings.chantypes(strcmpi({settings.chantypes.type}, x)).data, ...
            ct, 'UniformOutput', false);
        wv = find(strcmpi(chan_data, 'wave'));
        
        % initialize fix_point
        fix_point(:,1) = zeros(numel(data{wv(1)}.data), 1);
        fix_point(:,2) = zeros(numel(data{wv(1)}.data), 1);
        
        if isfield(options, 'fixation_point') && size(options.fixation_point,1) == 1
            % normalize values according to resolution
            fix_point = options.fixation_point ./ options.resolution;
        else
            fix_point(:,:) = 0.5;
        end
    else
        % normalized values
        fix_point = options.fixation_point ./ options.resolution;
    end
else
    [xlim,ylim] = size(bitmap);
    map_x_range = [1,xlim];
    map_y_range = [1,ylim];
end

% calculate radius araund de fixation points
%-----------------------------------------------------

if ~isfield(options, 'channel_action')
    options.channel_action = 'add';
elseif sum(strcmpi(options.channel_action, {'add','replace'})) == 0
    warning('ID:invalid_input', 'Options.channel_action must be either ''add'' or ''replace''.'); return;
end

% overwrite
if ~isfield(options, 'overwrite')
    options.overwrite = 0;
elseif ~isnumeric(options.overwrite) && ~islogical(options.overwrite)
    warning('ID:invalid_input', 'Options.overwrite must be either numeric or logical.'); return;
end

% dont_ask_overwrite
if ~isfield(options, 'dont_ask_overwrite')
    options.dont_ask_overwrite = 0;
elseif ~isnumeric(options.dont_ask_overwrite) && ~islogical(options.dont_ask_overwrite)
    warning('ID:invalid_input', 'Options.dont_ask_overwrite has to be numeric or logical.');
end

% newfile
if ~isfield(options, 'newfile')
    options.newfile = '';
elseif ~ischar(options.newfile)
    warning('ID:invalid_input', 'Options.newfile is not char.'); return;
end

if ~iscell(options.channels)
    options.channels = {options.channels};
end


% iterate through eyes
n_eyes = numel(infos.source.eyesObserved);
new_pu = cell(n_eyes, 1);
new_excl = cell(n_eyes, 1);

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
                ~strcmpi('pixel', x.header.units), data),1);
            gy = find(cellfun(@(x) strcmpi(gaze_y, x.header.chantype) & ...
                ~strcmpi('pixel', x.header.units), data),1);
            
            if ~isempty(gx) && ~isempty(gy)
                % we choose to convert the data in whatevercase to 'mm'
                x_unit = data{gx}.header.units;
                y_unit = data{gy}.header.units;
                
                if ~strcmpi(x_unit,'mm')
                    [nsts,x_data] = pspm_convert_unit(data{gy}.data, x_unit, 'mm');
                    [msts,x_range] = pspm_convert_unit(data{gy}.header.range', x_unit, 'mm');
                    if nsts~=1 || msts~=1
                        warning('ID:invalid_input', 'Failed to convert data.');
                    end
                else
                    x_data = data{gx}.data;
                    x_range = data{gx}.header.range;
                end
                if ~strcmpi(y_unit,'mm')
                    [nsts,y_data] = pspm_convert_unit(data{gy}.data, x_unit, 'mm');
                    [msts,y_range] = pspm_convert_unit(data{gy}.header.range', x_unit, 'mm');
                    if nsts~=1 || msts~=1
                        warning('ID:invalid_input', 'Failed to convert data.');
                    end
                else
                    y_data = data{gy}.data;
                    y_range = data{gy}.header.range;
                end
                % need to invert the y_data because of the different (0,0)
                % point of the eyetracker
                y_data = y_range(2)-y_data;
                
                % distinguish the validation method
                switch mode
                    case 'bitmap'
                        % nr of data points
                        N = numel(x_data);

                        % change bitmap to logical
                        bitmap = logical(bitmap);
                        
                        % normalize recorded data to adjust to right range
                        % of the bitmap
                        x_data = (x_data - x_range(1))/diff(x_range);
                        y_data = (y_data - y_range(1))/diff(y_range);
                        
                        %adapt to bitmap range
                        x_data = map_x_range(1)+ x_data * diff(map_x_range);
                        y_data = map_y_range(1)+ y_data * diff(map_y_range);
                        
                        %round gaze data such that we can use them as
                        %indexed
                        x_data = round(x_data);
                        y_data = round(y_data);
                        
                        %set all gaze values which are out oof the display
                        %window range to NaN
                        x_data(x_data > map_x_range(2) | x_data < map_x_range(1)) = NaN;
                        y_data(y_data > map_y_range(2) | y_data < map_y_range(1)) = NaN;
                        
                        %only take gaze coordinates which both aren't NaNs
                        valid_gaze_idx = find(~isnan(x_data) & ~isnan(y_data));
                        valid_gaze = [x_data(valid_gaze_idx),y_data(valid_gaze_idx)];
                        
                        val= zeros(N,1);
                        for k=1:numel(valid_gaze_idx)
                            val(valid_gaze_idx(k)) = bitmap(valid_gaze(k,1),valid_gaze(k,2));
                        end
                        val = logical(val);
                        excl = ~val;
                        
                        if options.plot_gaze_coords
                            fg = figure;
                            ax = axes('NextPlot', 'add');
                            set(ax, 'Parent', handle(fg));
                            
                            % plot gaze coordinates
                            mi=min(min(x_data),min(y_data));
                            ma=max(max(x_data),max(y_data));
                            axis([mi ma mi ma]);
                            imshow(bitmap);
                            hold on;
                            plot(ax, x_data, y_data);
                            
                        end
                        
                    case 'fixation'
                        % adapt the normalized fixation points to the
                        % korresponding range of the data
                        fix_point_temp(:,1) = x_range(1)+ fix_point(:,1)* diff(x_range);
                        fix_point_temp(:,2) = y_range(1)+ fix_point(:,2)* diff(y_range);
                        
                        % calculate the middlepoint of the display
                        middlepoint= [x_range(1)+ diff(x_range)/2, ...
                                      y_range(1)+ diff(y_range)/2];
                        
                        % caluculate the visual angle of the fixation points
                        % according to the right range
                        
                        dist = middlepoint - fix_point_temp;
                        dist = sqrt(dist(:,1).^2 + dist(:,2).^2);
                        angle_of_fix = 2 * atan(dist/distance);
                        angle_of_fix = rad2deg(angle_of_fix);
                        
                        % find for each fixation point the right radius
                        tot_angle = angle_of_fix + circle_degree;
                        tot_angle = deg2rad(tot_angle);
                        radius = distance * tan(tot_angle/2);
                        radius = radius - dist;
                        
                        % calculate for ech point distance to fixationpoint
                        gaze_data = [x_data,y_data];
                        dist_fix_gaze = fix_point_temp - gaze_data;
                        dist_fix_gaze = (sqrt(dist_fix_gaze(:,1).^2 + dist_fix_gaze(:,2).^2));
                        
                        % compare calculated distance to accepted radius
                        excl = dist_fix_gaze > radius;
                        
                        if options.plot_gaze_coords
                            fg = figure;
                            ax = axes('NextPlot', 'add');
                            set(ax, 'Parent', handle(fg));
                            
                            % validation middlepoint
                            x_point = fix_point_temp(1,1);
                            y_point = fix_point_temp(1,2);
                            
                            %for the circle around the first fixation point
                            th = 0:pi/50:2*pi;
                            x_unit = radius(1) * cos(th) + x_point;
                            y_unit = radius(1) * sin(th) + y_point;
                            
                            % plot gaze coordinates
                            mi=min(min(x_data),min(y_data));
                            ma=max(max(x_data),max(y_data));
                            axis([mi ma mi ma]);
                            plot(ax, x_data, y_data);
                            plot(x_unit, y_unit);
                        end
                end
               
                
                % set excluded periods in pupil data to NaN
                new_pu{i} = {data{work_chans}};
                new_excl{i} = cell(1,numel(new_pu{i}));
                for j=1:numel(new_pu{i})
                    new_pu{i}{j}.data(excl == 1) = NaN;
                    if all(isnan(new_pu{i}{j}.data))
                        warning('ID:invalid_input', ['All values of channel ''%s'' ', ...
                            'completely set to NaN. Please reconsider your parameters.'], ...
                            new_pu{i}{j}.header.chantype);
                    end
                    excl_hdr = struct('chantype', ['pupil_missing_', eye],...
                        'units', '', 'sr', new_pu{i}{j}.header.sr);
                    new_excl{i}{j} = struct('data', double(excl), 'header', excl_hdr);
                end
            else
                warning('ID:invalid_input', ['Unable to perform gaze ', ...
                    'validation. Cannot find gaze channels with length ',...
                    'unit values. Maybe you need to convert them with ', ...
                    'pspm_convert_pixel2unit()']);
            end
        else 
            warning('ID:invalid_input', ['Unable to perform gaze ', ...
                    'validation. There must be a pupil channel. Eventually ', ...
                    'only gaze channels have been imported.']);
        end
    end
end

op = struct();
op.dont_ask_overwrite = options.dont_ask_overwrite;
op.overwrite = options.overwrite;

if ~isempty(options.newfile)
    [pathstr, ~, ~] = fileparts(options.newfile);
    if exist(pathstr, 'dir') || isempty(pathstr)
        out_file = options.newfile;
    else
        warning('ID:invalid_input', 'Path to options.newfile (%s) does not exist.', options.newfile);
    end
else
    out_file = fn;
end

% collect data
if options.missing
    new_chans = [[new_excl{:}], [new_pu{:}]];
else
    new_chans = [new_pu{:}];
end

if numel(new_chans) >= 1
    new_data = data;
    chan_idx = NaN(1,numel(new_chans));
    for i = 1:numel(new_chans)
        if strcmpi(options.channel_action, 'add')
            new_data{end+1} = new_chans{i};
            chan_idx(i) = numel(new_data);
        else
            % look for same chan_type
            chans = cellfun(@(x) strcmpi(new_chans{i}.header.chantype, x.header.chantype), new_data);
            if any(chans)
                % replace the first found channel
                idx = find(chans, 1, 'first');
                new_data{idx}.data = new_chans{i}.data;
                chan_idx(i) = idx;
            else
                new_data{end+1} = new_chans{i};
                chan_idx(i) = numel(new_data);
            end
        end
    end
    
    % update chan stats (similar to pspm_get_eyelink)
    for i = 1:numel(new_data)
        % update nan ratio
        n_inv = sum(isnan(new_data{i}.data));
        n_data = numel(new_data{i}.data);
        infos.source.chan_stats{i}.nan_ratio = n_inv/n_data;
    end
    
    % update best eye
    eye_stat = Inf(1,numel(infos.source.eyesObserved));
    for i = 1:numel(infos.source.eyesObserved)
        e = lower(infos.source.eyesObserved(i));
        e_stat = {infos.source.chan_stats{...
            cellfun(@(x) ~isempty(regexpi(x.header.chantype, ['_' e], 'once')), new_data)}};
        eye_stat(i) = max(cellfun(@(x) x.nan_ratio, e_stat));
    end
    
    [~, min_idx] = min(eye_stat);
    infos.source.best_eye = lower(infos.source.eyesObserved(min_idx));
    
    file_struct.infos = infos;
    file_struct.data = new_data;
    file_struct.options = op;
    
    [sts, ~, ~, ~] = pspm_load_data(out_file, file_struct);
else
    warning('ID:invalid_input', 'Appearently no data was generated.');
end
