function [sts, import, sourceinfo] = pspm_get_smi(datafile, import)
    % pspm_get_smi is the main function for import of SensoMotoric Instruments
    % iView X EyeTracker files. 
    %
    % FORMAT: [sts, import, sourceinfo] = pspm_get_smi(datafile, import);
    %          datafile: Structure with
    %                  - mandatory fields:
    %                      .sample_file:
    %                          File containing the eye measurements, stored in ASCII format.
    %                  - optional fields:
    %                      .event_file:
    %                          File containing the blink/saccade events, stored in ASCII format.
    %
    %          import: import job structure with 
    %                  - mandatory fields:
    %                      .type:
    %                          Type of the channel. Must be one of pupil_l, pupil_r,
    %                          gaze_x_l, gaze_y_l, gaze_x_r, gaze_y_r, blink_l, blink_r,
    %                          saccade_l, saccade_r, marker, custom.
    %
    %                          The given channel type has to be recorded in all of
    %                          the sessions contained in the datafile.
    %                  - optional fields:
    %                      .channel:
    %                          If .type is custom, the index of the channel to import
    %                          must be specified using this option.
    %                      .distance_unit:
    %                          the unit to which the data should be converted.
    %                          (Default: mm)
    %__________________________________________________________________________
    %
    % (C) 2019 Eshref Yozdemir (University of Zurich)

    global settings;
    if isempty(settings), pspm_init; end
    sourceinfo = []; sts = -1;
    addpath([settings.path, 'Import', filesep, 'smi']);

    if ~iscell(import)
        import = {import};
    end
    for i = 1:numel(import)
        if ~isfield(import{i}, 'distance_unit')
            import{i}.distance_unit = 'mm';
        end
    end

    assert_custom_import_channels_has_channel_field(import);
    assert_all_chantypes_are_supported(settings, import);
    if isfield(datafile, 'event_file')
        data = import_smi(datafile.sample_file, datafile.event_file);
    else
        data = import_smi(datafile.sample_file);
    end
    if numel(data) > 1
        assert_same_sample_rate(data);
        assert_same_eyes_observed(data);
        assert_sessions_are_one_after_another(data);
    end

    assert_all_chantypes_are_in_imported_data(data, datafile.sample_file, import);
    [data_concat, markers, mi_values, mi_names] = concat_sessions(data);

    sampling_rate = compute_sampling_rate(data{1});
    eyes_observed = lower(data{1}.eyesObserved);
    chan_struct = cellfun(@(x) smi_header_to_pspm_header(x), data{1}.channels_columns, 'UniformOutput', false);
    units = data{1}.units;
    screen_size = data{1}.stimulus_dimension;
    viewing_dist = data{1}.head_distance;
    num_import_cells = numel(import);
    for k = 1:num_import_cells
        if strcmpi(import{k}.type, 'marker')
            import{k} = import_marker_chan(import{k}, markers, mi_values, mi_names, sampling_rate);
        else
            [import{k}, chan_id] = import_data_chan(import{k}, data_concat, eyes_observed, chan_struct, units, sampling_rate);
            %import{k} = convert_data_chan(import{k}, viewing_dist, screen_size, import{k}.eyecamera_width, import{k}.eyecamera_height);
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

    rmpath([settings.path, 'Import', filesep, 'smi']);
    sts = 1;
end

function sr = compute_sampling_rate(data_cell)
    sr = data_cell.sampleRate;
end

function assert_same_sample_rate(data)
    sample_rates = [];
    for i = 1:numel(data)
        sample_rates(end + 1) = compute_sampling_rate(data{i});
    end
    if any(diff(sample_rates))
        sample_rates_str = sprintf('%d ', sample_rates);
        error_msg = sprintf(['Cannot concatenate multiple sessions with', ...
            ' different sample rates. Found sample rates: %s'], sample_rates_str);
        error('ID:invalid_data_structure', error_msg);
    end
end

function equal = all_strs_in_cell_array_are_equal(cell_arr)
    equal = true;
    for i = 1:numel(cell_arr) - 1
        if ~all(strcmpi(cell_arr{i}, cell_arr{i+1}))
            equal = false;
            break;
        end
    end
end

function assert_same_eyes_observed(data)
    eyes_observed = cellfun(@(x) x.eyesObserved, data, 'UniformOutput', false);
    same_eyes = all_strs_in_cell_array_are_equal(eyes_observed);

    channel_headers = cellfun(@(x) x.channels_columns, data, 'UniformOutput', false);
    same_headers = all_strs_in_cell_array_are_equal(channel_headers);

    if ~(same_eyes && same_headers)
        error_msg = 'Cannot concatenate multiple sessions with different eye observation or channel headers';
        error('ID:invalid_data_structure', error_msg);
    end
end

function assert_sessions_are_one_after_another(data)
    timesteps_concat = cell2mat(cellfun(@(x) x.raw(:, 1), data, 'UniformOutput', false));
    neg_diff_indices = find(diff(timesteps_concat) < 0);
    if ~isempty(neg_diff_indices)
        first_neg_idx = neg_diff_indices(1);
        error_msg = sprintf('Cannot concatenate multiple sessions with decreasing timesteps: samples %d and %d', first_neg_idx, first_neg_idx + 1);
        error('ID:invalid_data_structure', error_msg);
    end
end

function assert_custom_import_channels_has_channel_field(import)
    for i = 1:numel(import)
        if strcmpi(import{i}.type, 'custom') && ~isfield(import{i}, 'channel')
            error('ID:invalid_imported_data', sprintf('Custom channel in import{%d} has no channel id to import', i));
        end
    end
end

function assert_all_chantypes_are_supported(settings, import)
    viewpoint_idx = find(strcmpi('viewpoint', {settings.import.datatypes.short}));
    viewpoint_types = settings.import.datatypes(viewpoint_idx).chantypes;
    for k = 1:numel(import)
        input_type = import{k}.type;
        if ~any(strcmpi(input_type, viewpoint_types))
            error_msg = sprintf('Channel %s is not a ViewPoint supported type', input_type);
            error('ID:channel_not_contained_in_file', error_msg);
        end
    end
end

function assert_all_chantypes_are_in_imported_data(data, sample_file, import)
    % Assert that all given input channels are contained in at least one of the
    % imported sessions. They don't have to be in all the sessions; the remaining
    % parts will be filled with NaNs.
    for k = 1:numel(import)
        input_type = import{k}.type;
        type_parts = split(input_type, '_');
        data_contains_type = false;
        if strcmpi(type_parts{1}, 'pupil')
            which_eye = type_parts{2};
            expect_list = {[which_eye ' Dia'], [which_eye ' Area'], [which_eye ' Mapped Diameter']};
        elseif strcmpi(type_parts{1}, 'gaze')
            coord = type_parts{2};
            which_eye = type_parts{3};
            expect_list = {[which_eye ' Raw ' coord]};
        elseif strcmpi(type_parts{1}, 'blink')
            which_eye = type_parts{2};
            expect_list = {[which_eye, ' Blink']};
        elseif strcmpi(type_parts{1}, 'saccade')
            which_eye = type_parts{2};
            expect_list = {[which_eye ' Saccade']};
        end
        for i = 1:numel(data)
            session_channels = data{i}.channels_columns;
            for j = 1:numel(expect_list)
                data_contains_type = data_contains_type || any(contains(lower(session_channels), lower(expect_list{j})));
            end
        end
        if ~data_contains_type
            error_msg = sprintf('Channel type %s is not in the given sample_file %s', input_type, sample_file);
            error('ID:channel_not_contained_in_file', error_msg);
        end
    end
end

function import_cell = import_marker_chan(import_cell, markers, mi_values, mi_names, sampling_rate)
    import_cell.marker = 'continuous';
    import_cell.sr     = sampling_rate;
    import_cell.data   = markers;
    markerinfo.names = mi_names;
    markerinfo.values = mi_values;
    import_cell.markerinfo = markerinfo;
    import_cell.flank = 'ascending';
end

function [import_cell, chan_id] = import_data_chan(import_cell, data_concat, eyes_observed, chan_struct, units, sampling_rate)
    n_data = size(data_concat, 1);
    if strcmpi(import_cell.type, 'custom')
        chan_id = import_cell.channel;
    else
        chan_id = find(strcmpi(chan_struct, import_cell.type), 1, 'first');
    end

    chantype_has_L_or_R = ~isempty(regexpi(import_cell.type, '_[lr]', 'once'));
    chantype_hasnt_eyes_obs = isempty(regexpi(import_cell.type, ['_([' eyes_observed '])'], 'once'));
    if chantype_has_L_or_R && chantype_hasnt_eyes_obs
        error('ID:channel_not_contained_in_file', ...
            ['Cannot import channel type %s, as data for this eye',
        ' does not seem to be present in the datafile. ', ...
            'Will create artificial channel with NaN values.'], import_cell.type);

        import_cell.data = NaN(n_data, 1);
        chan_id = -1;
        import_cell.units = '';
    else
        import_cell.data = data_concat(:, chan_id);
        import_cell.units = units{chan_id};
    end
    import_cell.sr = sampling_rate;
end

function import_cell = convert_data_chan(import_cell, viewing_dist, screen_size, eyecamera_width, eyecamera_height)
    chantype = import_cell.type;
    is_pupil_chan = ~isempty(regexpi(chantype, 'pupil'));
    is_gaze_x_chan = ~isempty(regexpi(chantype, 'gaze_x_'));
    is_gaze_y_chan = ~isempty(regexpi(chantype, 'gaze_y_'));
    if is_pupil_chan
        import_cell.data = import_cell.data * eyecamera_width;
        target_unit = import_cell.distance_unit;
        viewing_dist = pspm_convert_unit(viewing_dist, 'mm', target_unit);
        [~, import_cell.data] = pspm_convert_au2unit(import_cell.data, target_unit, viewing_dist, 'diameter');
        import_cell.units = target_unit;
    elseif is_gaze_x_chan
        % normalized to mm
        xmin = screen_size.xmin;
        xmax = screen_size.xmax;
        import_cell.range = [xmin xmax];
        import_cell.data = import_cell.data * (xmax - xmin) + xmin;
        import_cell.units = 'mm';
    elseif is_gaze_y_chan
        % normalized to mm
        ymin = screen_size.ymin;
        ymax = screen_size.ymax;
        import_cell.range = [ymin ymax];
        import_cell.data = import_cell.data * (ymax - ymin) + ymin;
        import_cell.units = 'mm';
    else
        error('ID:invalid_imported_data', sprintf('Imported data contains an unsupported data channel: %s', chantype));
    end
end

function [data_concat, markers, mi_values, mi_names] = concat_sessions(data)
    % Concatenate multiple sessions into contiguous arrays, inserting NaN or N/A fields
    % in between two sessions when there is a time gap.
    %
    % data: Cell array containing data for multiple sessions.
    %
    % data_concat : Matrix formed by concatenating data{i}.channels arrays according to
    %               timesteps. If end and begin of consecutive channels are far apart,
    %               NaNs are inserted.
    % markers     : Array of marker seconds, formed by simply concatening data{i}.marker.times.
    % mi_values   : Array of marker values, formed by simply concatening data{i}.marker.values.
    % mi_names    : Array of marker names, formed by simply concatening data{i}.marker.names.
    %
    data_concat = [];
    markers = [];
    mi_values = [];
    mi_names = {};

    microsecond_col_idx = 1;
    n_cols = size(data{1}.channels, 2);
    sr = compute_sampling_rate(data{1});
    last_time = data{1}.raw(1, microsecond_col_idx);
    microsec_to_sec = 1e-6;

    for c = 1:numel(data)
        start_time = data{c}.raw(1, microsecond_col_idx);
        end_time = data{c}.raw(end, microsecond_col_idx);

        n_missing = round((start_time - last_time) * microsec_to_sec * sr);
        if n_missing > 0
            curr_len = size(data_concat, 1);
            data_concat(end + 1:(end + n_missing), 1:n_cols) = NaN(n_missing, n_cols);
        end

        n_data_in_session = size(data{c}.channels, 1);
        n_markers_in_session = numel(data{c}.markerinfos.name);

        data_concat(end + 1:(end + n_data_in_session), 1:n_cols) = data{c}.channels;
        markers(end + 1:(end + n_markers_in_session), 1) = data{c}.markers';
        mi_values(end + 1:(end + n_markers_in_session),1) = data{c}.markerinfos.values';
        mi_names(end + 1:(end + n_markers_in_session),1) = data{c}.markerinfos.name';

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

function [header] = smi_header_to_pspm_header(header)
    % Convert SMI header format to PsPM header format
    parts = split(header);
    which_eye = lower(parts{1});
    datatype = lower(parts{2});

    sts = true;
    if numel(parts) == 2
        if strcmpi(datatype, 'blink')
            header = ['blink_', which_eye];
        elseif strcmpi(datatype, 'saccade')
            header = ['saccade_', which_eye];
        else
            sts = false;
        end
    elseif numel(parts) == 3
        if strcmpi(datatype, 'dia')
            header = ['pupil_', which_eye];
        elseif strcmpi(datatype, 'area')
            header = ['pupil_', which_eye];
        else
            sts = false;
        end
    elseif numel(parts) == 4
        if strcmpi(datatype, 'raw')
            axis = lower(parts{3});
            header = ['gaze_', axis, '_', which_eye];
        elseif strcmpi(datatype, 'dia')
            axis = lower(parts{3});
            if strcmpi(axis, 'x')
                header = ['pupil_', which_eye];
            end
        elseif strcmpi(datatype, 'mapped')
            header = ['pupil_', which_eye];
        elseif strcmpi(datatype, 'por')
            axis = lower(parts{3});
            header = ['gaze_', axis, '_', which_eye];
        else
            sts = false;
        end
    else
        sts = false;
    end
    if ~sts
        error('ID:invalid_data_structure', sprintf('Samples file contain an unexpected data header %s', header));
    end
end
