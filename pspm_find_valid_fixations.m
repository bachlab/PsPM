function [sts, out_file] = pspm_find_valid_fixations(fn, box_degree, ...
    distance, unit, options)
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
%   [sts, out_file] = pspm_find_valid_fixations(fn, box_degree, distance, 
%                                               unit, options)
%
% ARGUMENTS: 
%           fn:                 The actual data file containing the eyelink
%                               recording with gaze data converted to cm.
%           box_degree:         size of boundary box given in degree
%                               visual angles.
%           distance:           distance between eye and screen in length units.
%           unit:               unit in which distance is given.
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
if nargin < 3
    warning('ID:invalid_input', 'Not enough input arguments.'); return;
end

if nargin < 2 || ~exist('options', 'var') 
    options = struct();
end

% fn
if ~ischar(fn) || ~exist(fn, 'file')
    warning('ID:invalid_input', ['File %s is not char or does not ', ...
        'seem to exist.'], fn); return;
end

% load data right away (needed if fixation point should be expanded)
[sts, infos, data] = pspm_load_data(fn);
if sts ~= 1
    warning('ID:invalid_input', ['An error happened, while ', ...
        'opening the file %s.'],fn); return;
end

% check validate_fixations and then the depending mandatory fields  
if ~isfield(options, 'missing')
    options.missing = false;
end

if ~isfield(options, 'resolution')
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
elseif ~isnumeric(box_degree)
    warning('ID:invalid_input', ['box_degree is not set or ', ...
        'is not numeric.']); 
    return;
elseif ~isnumeric(distance)
    warning('ID:invalid_input', 'distance is not set or not numeric.'); 
    return;
elseif ~ischar(unit)
    warning('ID:invalid_input', 'unit should be a char');
    return;
elseif isfield(options, 'fixation_point') && ...
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
elseif isfield(options, 'fixation_point') &&  ...
    ~all(options.fixation_point < options.resolution)
    warning('ID:out_of_range', ['Some fixation points are larger than ', ...
        'the range given. Ensure fixation points are within the given ', ...
        'resolution.']);
    return;
end

% expand fixation_point
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

% box for degree visual angle (for each data point)
box_rad = box_degree * pi / 180;
box_length = 2 * distance * tan( box_rad / 2);

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
data_dev = cell(n_eyes,1);

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
            excl = false(size(data{1}.data,1),1);
            
            gx = find(cellfun(@(x) strcmpi(gaze_x, x.header.chantype) & ...
                ~strcmpi('pixel', x.header.units), data),1);
            gy = find(cellfun(@(x) strcmpi(gaze_y, x.header.chantype) & ...
                ~strcmpi('pixel', x.header.units), data),1);

            if ~isempty(gx) && ~isempty(gy)
                % get channel specific data range
                x_range = data{gx}.header.range;
                y_range = data{gy}.header.range;

                x_unit = data{gx}.header.units;
                y_unit = data{gy}.header.units;

                % normalize recorded data to compare with normalized
                % fixation points and box degree
                gx_d = (data{gx}.data - x_range(1)) / diff(x_range);
                gy_d = (data{gy}.data - y_range(1)) / diff(y_range);

                % also invert y coordinate
                gy_d = 1 - gy_d;

                [~, box_length_x] = pspm_convert_unit(box_length, unit, x_unit);
                [~, box_length_y] = pspm_convert_unit(box_length, unit, y_unit);

                % calculate limits from box_degree with respect to range
                x_lim = (box_length_x - x_range(1)) / diff(x_range);
                y_lim = (box_length_y - y_range(1)) / diff(y_range);

                % find data outside of box_degree
                data_dev{i}(:,1) = abs(gx_d - fix_point(:, 1)) > x_lim;
                data_dev{i}(:,2) = abs(gy_d - fix_point(:, 2)) > y_lim;
                data_dev{i}(:,3) = data_dev{i}(:,1) | data_dev{i}(:,2);
                
                if options.plot_gaze_coords
                    fg = figure;
                    ax = axes('NextPlot', 'add');
                    set(ax, 'Parent', handle(fg));
                    
                    % validation box coordinates
                    x_point = fix_point(1,1);
                    y_point = fix_point(1,2);

                    coord = repmat([x_point y_point], 5, 1) + ...
                        [x_lim y_lim; ...
                        x_lim -y_lim; ...
                        -x_lim -y_lim; ...
                        -x_lim y_lim; ...
                        x_lim y_lim];

                    plot(ax, gx_d, gy_d);
                    % plot gaze coordinates
                    plot(ax, coord(:,1), coord(:,2));
                end
                
                % set fixation breaks
                excl(data_dev{i}(:,3)) = 1;
                
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
