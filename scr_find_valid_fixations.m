function [sts, out_file] = scr_find_valid_fixations(fn, options)
% scr_find_valid_fixaitons takes a file with data from eyelink recordings
% and filters out invalid fixations. It either only interpolates pupil size
% during blinks or additionally interpolates the pupil size when the
% fixation is within a given range. It then returns the data for which the
% fixation is valid.
%
% With two options it is possible to tell the function whether to add or
% replace the channels and to tell whether the function should create a new
% file or overwrite the file given in fn.
%
% FORMAT: 
%   [sts, out_file] = scr_find_valid_fixations(fn, options)
%
% ARGUMENTS: 
%           fn:                 The actual data file containing the eyelink
%                               recording.
%           options:            Optional values
%               validate_fixations: tells the function whether to validate
%                                   fixations within a range or just to
%                                   interpolate the pupil data
%               box_degree:         size of boundary box given in degree
%                                   visual angles.
%               distance:           distance between eye and screen in mm.
%               screen_settings:    Struct with the severeal settings of
%                                   the used screen.
%                   aspect_actual:  Actual aspect ratio of the screen.
%                   aspect_used:    Used aspect ratio of the screen. If not
%                                   set will function assumes aspect_used 
%                                   equals aspect_actual.
%                   display_size:   The size of the display in inches.
%               fixation_point:     A nx2 vector containing x and y of the
%                                   fixation point (in pixel). n should be 
%                                   either 1 or should have the length of
%                                   the actual data. Default is the middle
%                                   of the screen.
%               channel_action:     Define whether to add oder replace the
%                                   data. Default is 'add'. Possible values
%                                   are 'add' or 'replace'
%               newfile:            Define new filename to store data to
%                                   it. Default is '' which means that the
%                                   file under fn will be 'replaced'
%               overwrite:          Define whether existing files should be
%                                   overwritten or not. Default is 0.
%               interpolate:        If interpolation is enabled (=1), NaN
%                                   values in pupil channels will be
%                                   interpolated. Otherwise if disabled 
%                                   (=0, default) the NaN values will
%                                   remain and interpolation and defining
%                                   as missing is left over to eventual
%                                   processing with scr_glm.
%               missing:            If missing is enabled (=1), an extra
%                                   channel will be written containing
%                                   information about the validated data.
%                                   Data points equal to 1 describe epochs
%                                   which have been discriminated as 
%                                   invalid during validation. Data points
%                                   equal to 0 describe epochs of valid
%                                   data (= no blink & valid fixation).
%                                   Default is disabled (=0)
%               
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
sts = -1;
out_file = '';

% validate input
if nargin < 2 || ~exist('options', 'var') 
    options = struct();
end;

% fn
if ~ischar(fn) || ~exist(fn, 'file')
    warning('ID:invalid_input', 'File %s is not char or does not seem to exist.', fn); return;
end;

% load data right away (needed if fixation point should be expanded)
[sts, infos, data] = scr_load_data(fn);
if sts ~= 1
    warning('ID:invalid_input', 'An error happened, while opening the file %s.',fn); return;
end;

% check validate_fixations and then the depending mandatory fields
if ~isfield(options, 'interpolate')
    options.interpolate = false;
end;
    
if ~isfield(options, 'missing')
    options.missing = false;
end;
    
if ~isfield(options, 'validate_fixations')
    options.validate_fixations = false;
end;

if ~islogical(options.interpolate) && ~isnumeric(options.interpolate)
    warning('ID:invalid_input', 'Options.interpolate is neither logical nor numeric.'); return;
elseif ~islogical(options.missing) && ~isnumeric(options.missing)
    warning('ID:invalid_input', 'Options.missing is neither logical nor numeric.'); return;
elseif ~islogical(options.validate_fixations) && ~isnumeric(options.validate_fixations)
    warning('ID:invalid_input', 'Options.validate_fixations is neither logical nor numeric.'); return;
elseif options.validate_fixations
    % if we land here validate_fixations fits the expected format and is
    % true. so lets check if all mandatory fields are set and then set the
    % corresponding visual parameters.
    if ~isfield(options, 'box_degree') || ~isnumeric(options.box_degree)
        warning('ID:invalid_input', 'Options.box_degree is not set or is not numeric.'); return;
    elseif ~isfield(options, 'distance') || ~isnumeric(options.distance)
        warning('ID:invalid_input', 'Options.distance is not set or not numeric.'); return;
    elseif ~isfield(options, 'screen_settings') || ~isstruct(options.screen_settings)
        warning('ID:invalid_input', 'Options.screen_settings is not set or not struct.'); return;
    elseif ~isfield(options.screen_settings, 'aspect_actual') || ...
            ~isnumeric(options.screen_settings.aspect_actual) || ...
            any(size(options.screen_settings.aspect_actual) ~= [1 2])
        warning('ID:invalid_input', ['Options.screen_settings.aspect_actual is not set, ', ...
            'is not numeric or has the wrong size (should be 1x2).']); return;
    elseif ~isfield(options.screen_settings, 'aspect_used')
            options.screen_settings.aspect_used = options.screen_settings.aspect_actual;
    elseif ~isnumeric(options.screen_settings.aspect_used) ...
            || any(size(options.screen_settings.aspect_used) ~= [1 2])
        warning('ID:invalid_input', ['Options.screen_settings.aspect_used ', ...
            'is not numeric or has the wrong size (should be 1x2).']); return;
    elseif ~isfield(options.screen_settings, 'display_size') ...
            || ~isnumeric(options.screen_settings.display_size)
        warning('ID:invalid_input', ['Options.screen_settings.display_size is not set or is ', ...
            'not numeric.']); return;
    elseif isfield(options, 'fixation_point') && (~isnumeric(options.fixation_point) || ...
            size(options.fixation_point,2) ~= 2)
        warning('ID:invalid_input', ['Options.fixation_point is not ', ...
            'numeric, or has the wrong size (should be nx2).']); return;        
    end;
    
    % Visual inputs for specifying boundaries
    vis.box_degree      = options.box_degree;        % boundary of box in degree visual angles; has to be chosen by experimenter
    vis.distance_mm     = options.distance;      % eye-to-screen distance in mm
    vis.screen_inch     = options.screen_settings.display_size;
    vis.screen_aspect_actual = options.screen_settings.aspect_actual;   % this is the ACTUAL aspect ratio of the screen
    vis.screen_aspect_used = options.screen_settings.aspect_used;    % this is the USED   aspect ratio of the screen
    
    vis.screen_x        = infos.source.gaze_coords.xmax;     % resolution of eye-tracker: should latter be read from file
    vis.screen_y        = infos.source.gaze_coords.ymax;     % resolution of eye-tracker: should latter be read from file
    
    % Visual calulations
    vis.screen_mm       = vis.screen_inch * 25.4;
    vis.screen_h        = ( vis.screen_aspect_actual(2) / sqrt( vis.screen_aspect_actual(1)^2 + vis.screen_aspect_actual(2)^2 )) * vis.screen_mm;
    vis.screen_w        = vis.screen_h * vis.screen_aspect_used(1) / vis.screen_aspect_used(2);
    vis.screen_x_res    = vis.screen_x / vis.screen_w; % in px/mm
    vis.screen_y_res    = vis.screen_y / vis.screen_h; % in px/mm
    
    % expand fixation_point
    if ~isfield(options, 'fixation_point') || isempty(options.fixation_point) ...
            || size(options.fixation_point,1) == 1
        % set fixation point default or expand to data size
        % find first wave channel
        ct = cellfun(@(x) x.header.chantype, data, 'UniformOutput', false);
        chan_data = cellfun(@(x) ...
            settings.chantypes(find(strcmpi({settings.chantypes.type}, x))).data, ...
            ct, 'UniformOutput', false);
        wv = find(strcmpi(chan_data, 'wave'));
        % set default to middle of screen
        vis.fix_point(:,1) = zeros(numel(data{wv(1)}.data), 1);
        vis.fix_point(:,2) = zeros(numel(data{wv(1)}.data), 1);
        
        if isfield(options, 'fixation_point') && size(options.fixation_point,1) == 1
            vis.fix_point(:,1) = options.fixation_point(1);
            vis.fix_point(:,2) = options.fixation_point(2);
        else
            vis.fix_point(:,1) = vis.screen_x/2;
            vis.fix_point(:,2) = vis.screen_y/2;
        end;
    else
        vis.fix_point = options.fixation_point;
    end;
    
    % box for degree visual angle (for each data point)
    vis.box_rad         = vis.box_degree * pi / 180;
    vis.box_mm          = 2 * vis.distance_mm * tan( vis.box_rad / 2);
    vis.x_bound         = vis.box_mm * vis.screen_x_res;
    vis.y_bound         = vis.box_mm * vis.screen_y_res;
    vis.x_upper         = vis.fix_point(:,1) + vis.x_bound;
    vis.x_lower         = vis.fix_point(:,1) - vis.x_bound;
    vis.y_upper         = vis.fix_point(:,2) + vis.y_bound;
    vis.y_lower         = vis.fix_point(:,2) - vis.y_bound;
end;

if ~isfield(options, 'channel_action')
    options.channel_action = 'add';
elseif sum(strcmpi(options.channel_action, {'add','replace'})) == 0
    warning('ID:invalid_input', 'Options.channel_action must be either ''add'' or ''replace''.'); return;
end;

% overwrite
if ~isfield(options, 'overwrite')
    options.overwrite = 0;
elseif ~isnumeric(options.overwrite) || ~islogical(options.overwrite)
    warning('ID:invalid_input', 'Options.overwrite must be either numeric or logical.'); return;
end;

% dont_ask_overwrite
if ~isfield(options, 'dont_ask_overwrite')
    options.dont_ask_overwrite = 0;
elseif ~isnumeric(options.dont_ask_overwrite) || ~islogical(options.dont_ask_overwrite)
    warning('ID:invalid_input', 'Options.dont_ask_overwrite has to be numeric or logical.');
end;

% newfile
if ~isfield(options, 'newfile')
    options.newfile = '';
elseif ~ischar(options.newfile)
    warning('ID:invalid_input', 'Options.newfile is not char.'); return;
end;

% iterate through eyes
n_eyes = numel(infos.source.eyesObserved);
new_pu = cell(n_eyes, 1);
new_excl = cell(n_eyes, 1);
data_dev = cell(n_eyes,1);
for i=1:n_eyes
    eye = lower(infos.source.eyesObserved(i));
    
    gaze_x = ['gaze_x_', eye];
    gaze_y = ['gaze_y_', eye];
    blink = ['blink_', eye];
    pupil = ['pupil_', eye];
    
    % always use first found channel
    bl = find(cellfun(@(x) strcmpi(blink, x.header.chantype), data),1);    
    pu = find(cellfun(@(x) strcmpi(pupil, x.header.chantype), data),1);
    
    excl = data{bl}.data == 1;
    
    if options.validate_fixations
        gx = find(cellfun(@(x) strcmpi(gaze_x, x.header.chantype), data),1);
        gy = find(cellfun(@(x) strcmpi(gaze_y, x.header.chantype), data),1);
        
        data_dev{i}(:,1) = data{gx}.data > vis.x_upper | data{gx}.data < vis.x_lower;
        data_dev{i}(:,2) = data{gy}.data > vis.y_upper | data{gy}.data < vis.y_lower;
        data_dev{i}(:,3) = data_dev{i}(:,1) | data_dev{i}(:,2);
        
        % set fixation breaks
        excl(data_dev{i}(:,3)) = 1;
    end;

    % set excluded periods in pupil data to NaN
    new_pu{i} = data{pu};
    new_pu{i}.data(excl == 1) = NaN;
    
    if options.interpolate
        % interpolate / extrapolate at the edges
        o.extrapolate = 1;
        % interpolate
        [~, new_pu{i}.data] = scr_interpolate(new_pu{i}.data, o);
    end;
        
    excl_hdr = struct('chantype', ['pupil_missing_', eye], 'units', '', 'sr', new_pu{i}.header.sr);
    new_excl{i} = struct('data', excl, 'header', excl_hdr);
end;

op = struct();
op.dont_ask_overwrite = 1;
op.overwrite = options.overwrite;

if ~isempty(options.newfile)
    [pathstr, ~, ~] = fileparts(options.newfile);
    if exist(pathstr, 'dir')
        out_file = options.newfile;
    else
        warning('ID:invalid_input', 'Path to options.newfile (%s) does not exist.', options.newfile);
    end;
else
    out_file = fn;
end;

% collect data
if options.missing
    new_chans = [new_pu; new_excl];
else
    new_chans = new_pu;
end;

new_data = data;
for i = 1:numel(new_chans)
    if strcmpi(options.channel_action, 'add')
        new_data{end+1} = new_chans{i};
    else
        % look for same chan_type
        chans = cellfun(@(x) strcmpi(new_chans{i}.header.chantype, x.header.chantype), new_data);
        if any(chans) 
            % replace the first found channel
            idx = find(chans, 1, 'first');
            new_data{idx}.data = new_chans{i}.data;
        else
            new_data{end+1} = new_chans{i};
        end;
        
    end;
end;

file_struct.infos = infos;
file_struct.data = new_data;

[sts, ~, ~, ~] = scr_load_data(out_file, file_struct, op);
