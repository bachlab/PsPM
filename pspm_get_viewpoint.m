function [sts, import, sourceinfo] = pspm_get_viewpoint(datafile, import)
    % pspm_get_viewpoint is the main function for import of Arrington Research
    % ViewPoint EyeTracker files. 
    %
    % FORMAT: [sts, import, sourceinfo] = pspm_get_viewpoint(datafile, import);
    %          datafile: Path to a ViewPoint EyeTracker data stored in ASCII format.
    %          import: import job structure with 
    %                  - mandatory fields:
    %                      .type:
    %                          Type of the channel. Must be one of pupil_l, pupil_r,
    %                          gaze_x_l, gaze_y_l, gaze_x_r, gaze_y_r, blink_l, blink_r,
    %                          saccade_l, saccade_r, marker, custom.
    %
    %                          Right eye corresponds to eye A in ViewPoint; left eye
    %                          corresponds to eye B. However, when there is only one
    %                          eye in the data and in user input, they are matched.
    %
    %                          If the given channel type does not exist in the given
    %                          datafile, it will be filled with NaNs and a warning will
    %                          be emitted.
    %
    %                          The pupil diameter values returned by get_viewpoint are
    %                          normalized ratio values reported by Viewpoint Eyetracker
    %                          software. This is the ratio of the horizontal pupil
    %                          diameter to the eyecamera window width.
    %
    %                          The gaze values returned are in the given target_unit.
    %                          (x, y) = (0, 0) coordinate represents the top left
    %                          corner of the whole stimulus window. x coordinates grow
    %                          towards right and y coordinates grow towards bottom. The
    %                          gaze coordinates can be negative or larger than screen
    %                          size. These correspond to gaze positions outside the
    %                          screen.
    %
    %                          Specified custom channels must correspond to some form of
    %                          pupil/gaze channels. In addition, when the channel
    %                          type is custom, no postprocessing/conversion is performed
    %                          by pspm_get_viewponit and the channel is returned directly as
    %                          it is in the given datafile.
    %
    %                          Blinks and saccades are read and can be imported if they are
    %                          included in the given datafile as asynchronous messages. This
    %                          corresponds to "Include Events in File" option in ViewPoint
    %                          EyeTracker software. For a given eye, pupil and gaze values
    %                          corresponding to blinks/saccades for that eye are set to NaN.
    %
    %                  - optional fields:
    %                      .channel:
    %                          If .type is custom, the index of the channel to import
    %                          must be specified using this option. This value must be
    %                          the channel index of the desired channel in the raw data columns.
    %                      .target_unit:
    %                          the unit to which the gaze data should be converted. This option
    %                          has no effect for pupil diameter channel since that is always
    %                          returned as ratio. (Default: mm)
    %
    %                  - Each import structure will get the following output fields:
    %                      .data:
    %                          Data channel corresponding to the input channel type or
    %                          custom channel id.
    %                      .units:
    %                          Units of the channel.
    %                      .sr:
    %                          Sampling rate.
    %                      .chan_id:
    %                          Channel index of the imported channel in the raw data columns.
    %__________________________________________________________________________
    %
    % (C) 2019 Eshref Yozdemir (University of Zurich)

    global settings;
    if isempty(settings), pspm_init; end
    sourceinfo = []; sts = -1;
    addpath([settings.path, 'Import', filesep, 'viewpoint']);

    if ~iscell(import)
        import = {import};
    end
    for i = 1:numel(import)
        is_pupil = contains(lower(import{i}.type), 'pupil');
        is_gaze = contains(lower(import{i}.type), 'gaze');
        if ~isfield(import{i}, 'target_unit') && (is_pupil || is_gaze)
            import{i}.target_unit = 'mm';
        end
    end

    if ~assert_custom_import_channels_has_channel_field(import); return; end;
    if ~assert_all_chantypes_are_supported(settings, import); return; end;
    try
        data = import_viewpoint(datafile);
    catch err
        warning(err.identifier, err.message);
        return;
    end
    if numel(data) > 1
        if ~assert_same_sample_rate(data); return; end;
        if ~assert_same_eyes_observed(data); return; end;
        if ~assert_sessions_are_one_after_another(data); return; end;
    end

    data = map_viewpoint_eyes_to_left_right(data, import);
    [data_concat, markers, mi_names, mi_values] = concat_sessions(data);

    sampling_rate = compute_sampling_rate(data{1}.channels(:, 1));
    eyes_observed = lower(data{1}.eyesObserved);
    chan_struct = data{1}.channels_header;
    raw_columns = data{1}.dataraw_header;
    channel_indices = data{1}.channel_indices;
    units = data{1}.channels_units;
    screen_size = data{1}.screenSize;
    viewing_dist = data{1}.viewingDistance;

    data_concat = set_blink_saccade_rows_to_nan(data_concat, chan_struct);

    num_import_cells = numel(import);
    for k = 1:num_import_cells
        import{k}.data = [];
        chan_id = NaN;
        import{k}.units = 'N/A';
        import{k}.sr = sampling_rate;
        if strcmpi(import{k}.type, 'marker')
            import{k} = import_marker_chan(import{k}, markers, mi_names, mi_values, size(data_concat, 1), sampling_rate);
        else
            if strcmpi(import{k}.type, 'custom')
                [import{k}, chan_id] = import_custom_chan(import{k}, data_concat, channel_indices, raw_columns, chan_struct, units, sampling_rate);
            else
                [import{k}, chan_id] = import_data_chan(import{k}, data_concat, eyes_observed, channel_indices, chan_struct, units, sampling_rate);
                chantype = import{k}.type;
                is_gaze_x_chan = ~isempty(regexpi(chantype, 'gaze_x_'));
                is_gaze_y_chan = ~isempty(regexpi(chantype, 'gaze_y_'));
                if is_gaze_x_chan
                    import{k} = convert_gaze_chan(import{k}, screen_size.xmin, screen_size.xmax);
                elseif is_gaze_y_chan
                    import{k} = convert_gaze_chan(import{k}, screen_size.ymin, screen_size.ymax);
                end
            end
            if isempty(import{k}.data)
                import{k}.data = NaN(size(data_concat, 1), 1); 
                warning('ID:channel_not_contained_in_file', ...
                    sprintf(['Cannot import channel type %s, as data for this eye', ...
                     ' does not seem to be present in the datafile. ', ...
                     'Will create artificial channel with NaN values.'], import{k}.type));
            end
            sourceinfo.chan{k, 1} = sprintf('Column %02.0f', chan_id);
            sourceinfo.chan_stats{k,1} = struct();
            n_nan = sum(isnan(import{k}.data));
            n_data = numel(import{k}.data);
            sourceinfo.chan_stats{k}.nan_ratio = n_nan / n_data;
        end
    end

    sourceinfo.date = data{1}.record_date;
    sourceinfo.time = data{1}.record_time;
    sourceinfo.screenSize = screen_size;
    sourceinfo.viewingDistance = viewing_dist;
    sourceinfo.eyesObserved = eyes_observed;
    sourceinfo.best_eye = eye_with_smaller_nan_ratio(import, eyes_observed);

    rmpath([settings.path, 'Import', filesep, 'viewpoint']);
    sts = 1;
end

function sr = compute_sampling_rate(seconds_channel)
    sr = round(median(1 ./ diff(seconds_channel)));
end

function proper = assert_same_sample_rate(data)
    proper = true;
    sample_rates = [];
    for i = 1:numel(data)
        sample_rates(end + 1) = compute_sampling_rate(data{i}.channels(:, 1));
    end
    if any(diff(sample_rates))
        sample_rates_str = sprintf('%d ', sample_rates);
        error_msg = sprintf(['Cannot concatenate multiple sessions with', ...
            ' different sample rates. Found sample rates: %s'], sample_rates_str);
        warning('ID:invalid_data_structure', error_msg);
        proper = false;
        return;
    end
end

function proper = assert_same_eyes_observed(data)
    proper = true;
    eyes_observed = cellfun(@(x) x.eyesObserved, data, 'UniformOutput', false);
    eyes_observed = cell2mat(eyes_observed);

    channel_headers = cellfun(@(x) x.channels_header, data, 'UniformOutput', false);
    same_headers = true;
    for i = 1:(numel(channel_headers) - 1)
        if ~all(strcmpi(channel_headers{i}, channel_headers{i+1}))
            same_headers = false;
            break
        end
    end

    if any(diff(eyes_observed)) || ~same_headers
        error_msg = 'Cannot concatenate multiple sessions with different eye observation or channel headers';
        warning('ID:invalid_data_structure', error_msg);
        proper = false;
        return;
    end
end

function proper = assert_sessions_are_one_after_another(data)
    proper = true;
    seconds_concat = cell2mat(cellfun(@(x) x.channels(:, 1), data, 'UniformOutput', false));
    neg_diff_indices = find(diff(seconds_concat) < 0);
    if ~isempty(neg_diff_indices)
        first_neg_idx = neg_diff_indices(1);
        error_msg = sprintf('Cannot concatenate multiple sessions with decreasing timesteps: samples %d and %d', first_neg_idx, first_neg_idx + 1);
        warning('ID:invalid_data_structure', error_msg);
        proper = false;
        return;
    end
end

function proper = assert_custom_import_channels_has_channel_field(import)
    proper = true;
    for i = 1:numel(import)
        if strcmpi(import{i}.type, 'custom') && ~isfield(import{i}, 'channel')
            warning('ID:invalid_imported_data', sprintf('Custom channel in import{%d} has no channel id to import', i));
            proper = false;
            return;
        end
    end
end

function proper = assert_all_chantypes_are_supported(settings, import)
    proper = true;
    viewpoint_idx = find(strcmpi('viewpoint', {settings.import.datatypes.short}));
    viewpoint_types = settings.import.datatypes(viewpoint_idx).chantypes;
    for k = 1:numel(import)
        input_type = import{k}.type;
        if ~any(strcmpi(input_type, viewpoint_types))
            error_msg = sprintf('Channel %s is not a ViewPoint supported type', input_type);
            warning('ID:channel_not_contained_in_file', error_msg);
            proper = false;
            return;
        end
    end
end

function data = map_viewpoint_eyes_to_left_right(data, import)
    % Map eye A to right eye, eye B to left eye.
    for i = 1:numel(data)
        channels = data{i}.channels_header;
        for k = 1:numel(data{i}.channels_header)
            header = data{i}.channels_header{k};
            if strcmpi(header(end - 1:end), '_A')
                header(end - 1:end) = '_R';
            elseif strcmpi(header(end - 1:end), '_B')
                header(end - 1:end) = '_L';
            end
            data{i}.channels_header{k} = header;
        end

        if strcmpi(data{i}.eyesObserved, 'a')
            data{i}.eyesObserved = 'R';
        elseif strcmpi(data{i}.eyesObserved, 'b')
            data{i}.eyesObserved = 'L';
        elseif strcmpi(data{i}.eyesObserved, 'ab')
            data{i}.eyesObserved = 'RL';
        else
            warning('ID:invalid_imported_data', 'eyesObserved field in imported data has a value different than A and/or B');
            return;
        end
    end
    % If import has only left eye and data only right eye, map data right eye to left
    data_has_only_right_eye = true;
    for i = 1:numel(data)
        if contains(data{i}.eyesObserved, 'L', 'IgnoreCase', true)
            data_has_only_right_eye = false;
            break;
        end
    end
    import_has_only_left_eye = true;
    for i = 1:numel(import)
        if strcmpi(import{i}.type(end - 1:end), '_R')
            import_has_only_left_eye = false;
            break;
        end
    end
    if data_has_only_right_eye && import_has_only_left_eye
        for i = 1:numel(data)
            for k = 1:numel(data{i}.channels_header)
                header = data{i}.channels_header{k};
                if strcmpi(header(end - 1:end), '_R')
                    header(end - 1:end) = '_L';
                    data{i}.channels_header{k} = header;
                end
            end
            data{i}.eyesObserved = 'L';
        end
    end
end

function import_cell = import_marker_chan(import_cell, markers, mi_names, mi_values, n_rows, sampling_rate)
    import_cell.marker = 'continuous';
    import_cell.flank = 'ascending';
    import_cell.sr     = sampling_rate;
    import_cell.data = false(n_rows, 1);
    marker_indices = 1 + markers * sampling_rate;
    import_cell.data(int64(marker_indices)) = true;
    import_cell.units = 'unknown';
    markerinfo.name = mi_names;
    markerinfo.value = mi_values;
    import_cell.markerinfo = markerinfo;
end

function [import_cell, chan_id] = import_custom_chan(import_cell, data_concat, channel_indices, raw_columns, chan_struct, units, sampling_rate)
    n_raw_cols = size(raw_columns, 2);
    n_concat_rows = size(data_concat, 1);
    chan_id = import_cell.channel;
    if chan_id < 1
        warning('ID:invalid_input', sprintf('Custom channel id %d is less than 1', chan_id));
        return;
    end
    if chan_id > n_raw_cols || ~ismember(chan_id, channel_indices)
        warning('ID:invalid_input', sprintf(['Custom channel id (%d) cannot be imported using get_viewpoint.'...
            ' Creating a channel with NaNs'], chan_id));
        return;
    else
        chan_id_in_concat = find(channel_indices == chan_id);
        import_cell.data = data_concat(:, chan_id_in_concat);
        import_cell.units = units{chan_id_in_concat};
        import_cell.data_header = chan_struct{chan_id_in_concat};
    end
    import_cell.sr = sampling_rate;
end

function [import_cell, chan_id] = import_data_chan(import_cell, data_concat, eyes_observed, channel_indices, chan_struct, units, sampling_rate)
    n_data = size(data_concat, 1);
    chan_id_in_concat = find(strcmpi(chan_struct, import_cell.type), 1, 'first');

    chantype_has_L_or_R = ~isempty(regexpi(import_cell.type, '_[lr]', 'once'));
    chantype_hasnt_eyes_obs = isempty(regexpi(import_cell.type, ['_([' eyes_observed '])'], 'once'));
    if (chantype_has_L_or_R && chantype_hasnt_eyes_obs) || isempty(chan_id_in_concat)
        chan_id = NaN;
        return;
    else
        import_cell.data = data_concat(:, chan_id_in_concat);
        import_cell.units = units{chan_id_in_concat};
        chan_id = channel_indices(chan_id_in_concat);
    end
    import_cell.sr = sampling_rate;
end

function import_cell = convert_gaze_chan(import_cell, mincoord, maxcoord)
    import_cell.range = [mincoord maxcoord];
    import_cell.data = import_cell.data * (maxcoord - mincoord) + mincoord;
    if ~strcmp('mm', import_cell.target_unit)
        [~, import_cell.data] = pspm_convert_unit(import_cell.data, 'mm', import_cell.target_unit);
    end
    import_cell.units = import_cell.target_unit;
end

function [data_concat, markers, mi_names, mi_values] = concat_sessions(data)
    % Concatenate multiple sessions into contiguous arrays, inserting NaN or N/A fields
    % in between two sessions when there is a time gap.
    %
    % data: Cell array containing data for multiple sessions.
    %
    % data_concat : Matrix formed by concatenating data{i}.channels arrays according to
    %               timesteps. If end and begin of consecutive channels are far apart,
    %               NaNs are inserted.
    % markers     : Array of marker seconds, formed by simply concatening data{i}.marker.times.
    % mi_names    : Array of marker names, formed by simply concatening data{i}.marker.name.
    % mi_values   : Array of marker values, formed by simply concatening data{i}.marker.value.
    %
    data_concat = [];
    markers = [];
    mi_names = {};
    mi_values = [];

    second_col_idx = 1;
    n_cols = size(data{1}.channels, 2);
    sr = compute_sampling_rate(data{1}.channels(:, second_col_idx));
    last_time = data{1}.channels(1, second_col_idx);

    for c = 1:numel(data)
        start_time = data{c}.channels(1, second_col_idx);
        end_time = data{c}.channels(end, second_col_idx);

        n_missing = round((start_time - last_time) * sr);
        if n_missing > 0
            curr_len = size(data_concat, 1);
            data_concat(end + 1:(end + n_missing), 1:n_cols) = NaN(n_missing, n_cols);
        end

        n_data_in_session = size(data{c}.channels, 1);
        n_markers_in_session = size(data{c}.marker.times, 1);

        data_concat(end + 1:(end + n_data_in_session), 1:n_cols) = data{c}.channels;
        markers(end + 1:(end + n_markers_in_session), 1) = data{c}.marker.times;
        mi_values(end + 1:(end + n_markers_in_session),1) = data{c}.marker.value;
        mi_names(end + 1:(end + n_markers_in_session),1) = data{c}.marker.name;

        last_time = end_time;
    end
end

function best_eye = eye_with_smaller_nan_ratio(import, eyes_observed)
    if numel(eyes_observed) == 1
        best_eye = lower(eyes_observed);
    else
        eye_L_max_nan_ratio = 0;
        eye_R_max_nan_ratio = 0;
        for i = 1:numel(import)
            left_data = ~isempty(regexpi(import{i}.type, '_l', 'once'));
            right_data = ~isempty(regexpi(import{i}.type, '_r', 'once'));
            if left_data
                eye_L_max_nan_ratio = max(eye_L_max_nan_ratio, sum(isnan(import{i}.data)));
            elseif right_data
                eye_R_max_nan_ratio = max(eye_R_max_nan_ratio, sum(isnan(import{i}.data)));
            end
        end
        if eye_L_max_nan_ratio < eye_R_max_nan_ratio
            best_eye = 'l';
        else
            best_eye = 'r';
        end
    end
end

function data = set_blink_saccade_rows_to_nan(data, chan_struct)
    chan_struct = lower(chan_struct);
    blink_l_col = find(strcmp(chan_struct, 'blink_l'));
    blink_r_col = find(strcmp(chan_struct, 'blink_r'));
    saccade_l_col = find(strcmp(chan_struct, 'saccade_l'));
    saccade_r_col = find(strcmp(chan_struct, 'saccade_r'));
    
    blink_l = logical(data(:, blink_l_col));
    blink_r = logical(data(:, blink_r_col));
    saccade_l = logical(data(:, saccade_l_col));
    saccade_r = logical(data(:, saccade_r_col));
    
    left_data_cols = contains(chan_struct, '_l') & ~contains(chan_struct, 'blink') & ~contains(chan_struct, 'saccade');
    right_data_cols = contains(chan_struct, '_r') & ~contains(chan_struct, 'blink') & ~contains(chan_struct, 'saccade');
    if ~isempty(blink_l_col)
        data(blink_l, left_data_cols) = NaN;
    end
    if ~isempty(saccade_l_col)
        data(saccade_l, left_data_cols) = NaN;
    end
    if ~isempty(blink_r_col)
        data(blink_r, right_data_cols) = NaN;
    end
    if ~isempty(saccade_r_col)
        data(saccade_r, right_data_cols) = NaN;
    end
end
