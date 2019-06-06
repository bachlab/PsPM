function [sts, import, sourceinfo] = pspm_get_smi(datafile, import)
    % pspm_get_smi is the main function for import of SensoMotoric Instruments
    % iView X EyeTracker files. 
    %
    % FORMAT: [sts, import, sourceinfo] = pspm_get_smi(datafile, import);
    %          datafile: String or cell array of strings. The size of the cell array can be 1 or 2.
    %
    %                    If datafile is string, it must be the path to the sample file containing
    %                    eye measuremnts. The file must be stored in ASCII format.
    %
    %                    If datafile is a cell array, the first element must be the path to the
    %                    sample file defined above. The optional second string in the cell array
    %                    can be the event file containing blink/saccade events. The file must be
    %                    stored in ASCII format.
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
    %
    %                          Specified custom channels must correspond to some form of
    %                          pupil/gaze/blink/saccade/marker channels. In addition,
    %                          when the channel type is custom, no postprocessing/conversion
    %                          is performed by pspm_get_smi and the channel is returned directly
    %                          as it is in the given datafile.
    %
    %                          The gaze values returned are in the given target_unit.
    %                          (x, y) = (0, 0) coordinate represents the top left
    %                          corner of the whole stimulus window. x coordinates grow
    %                          towards right and y coordinates grow towards bottom. The
    %                          gaze coordinates can be negative or larger than screen
    %                          size. These correspond to gaze positions outside the
    %                          screen.
    %
    %                  - optional fields:
    %                      .channel:
    %                          If .type is custom, the index of the channel to import
    %                          must be specified using this option.
    %                      .target_unit:
    %                          the unit to which the data should be converted.
    %                          (Default: mm)
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
    addpath([settings.path, 'Import', filesep, 'smi']);

    if ~iscell(import)
        import = {import};
    end
    for i = 1:numel(import)
        not_custom = ~strcmpi(import{i}.type, 'custom');
        not_marker = ~strcmpi(import{i}.type, 'marker');
        if ~isfield(import{i}, 'target_unit') && not_custom && not_marker
            import{i}.target_unit = 'mm';
        end
    end

    if isstr(datafile)
        datafile = {datafile};
    end
    assert_proper_datafile_format(datafile);
    assert_custom_import_channels_has_channel_field(import);
    assert_all_chantypes_are_supported(settings, import);
    if numel(datafile) == 2
        data = import_smi(datafile{1}, datafile{2});
    else
        warning(['get_smi will only read pupil and/or gaze data. ',...
            'No information about blinks or saccades will be generated. ',...
            'In order to generate this information you have to specify an event file.']);
        data = import_smi(datafile{1});
    end
    if numel(data) > 1
        assert_same_sample_rate(data);
        assert_same_eyes_observed(data);
        assert_sessions_are_one_after_another(data);
    end

    assert_all_chantypes_are_in_imported_data(data, datafile{1}, import);
    [data_concat, markers, mi_values, mi_names] = concat_sessions(data);

    sampling_rate = data{1}.sampleRate;
    eyes_observed = lower(data{1}.eyesObserved);
    units = data{1}.units;
    chan_struct = data{1}.channels_columns;
    raw_columns = data{1}.raw_columns;
    screen_size_mm = data{1}.stimulus_dimension;
    screen_size_px = [data{1}.gaze_coords.xmax, data{1}.gaze_coords.ymax];
    viewing_dist = data{1}.head_distance;
    num_import_cells = numel(import);
    for k = 1:num_import_cells
        chantype = lower(import{k}.type);
        chantype_has_L_or_R = ~isempty(regexpi(chantype, '_[lr]', 'once'));
        chantype_hasnt_eyes_obs = isempty(regexpi(chantype, ['_([' eyes_observed '])'], 'once'));
        if chantype_has_L_or_R && chantype_hasnt_eyes_obs
            error('ID:channel_not_contained_in_file', ...
                ['Cannot import channel type %s, as data for this eye',
            ' does not seem to be present in the datafile. ', ...
                'Will create artificial channel with NaN values.'], import_cell.type);

            import{k}.data = NaN(size(data_concat, 1), 1);
            chan_id = -1;
            import{k}.units = '';
        elseif strcmpi(chantype, 'marker')
            [import{k}, chan_id] = import_marker_chan(import{k}, markers, mi_values, mi_names, sampling_rate);
        elseif contains(chantype, 'pupil')
            [import{k}, chan_id] = import_pupil_chan(import{k}, data_concat, viewing_dist, raw_columns, chan_struct, units, sampling_rate);
        elseif contains(chantype, 'gaze')
            [import{k}, chan_id] = import_gaze_chan(import{k}, data_concat, screen_size_px, screen_size_mm, raw_columns, chan_struct, sampling_rate);
        elseif contains(chantype, 'blink') || contains(chantype, 'saccade')
            [import{k}, chan_id] = import_blink_or_saccade_chan(import{k}, data_concat, raw_columns, chan_struct, units, sampling_rate);
        elseif strcmpi(chantype, 'custom')
            [import{k}, chan_id] = import_custom_chan(import{k}, data_concat, raw_columns, chan_struct, units, sampling_rate);
        else
            error('ID:pspm_error', 'This branch should not have been taken. Please report this error to PsPM dev team');
        end
        sourceinfo.chan{k, 1} = sprintf('Column %02.0f', chan_id);
        sourceinfo.chan_stats{k,1} = struct();
        n_nan = sum(isnan(import{k}.data));
        n_data = numel(import{k}.data);
        sourceinfo.chan_stats{k}.nan_ratio = n_nan / n_data;
    end

    sourceinfo.date = data{1}.record_date;
    sourceinfo.time = data{1}.record_time;
    sourceinfo.screen_size_mm = screen_size_mm;
    sourceinfo.screen_size_px = screen_size_px;
    sourceinfo.viewing_distance_mm = viewing_dist;
    sourceinfo.eyes_observed = eyes_observed;
    sourceinfo.best_eye = eye_with_smaller_nan_ratio(import, eyes_observed);

    rmpath([settings.path, 'Import', filesep, 'smi']);
    sts = 1;
end

function assert_proper_datafile_format(datafile)
    if ~is_proper_datafile_format(datafile)
        error('ID:invalid_input', 'Given datafile is not valid. Please check the documentation');
    end
end

function proper = is_proper_datafile_format(datafile)
    if ~iscell(datafile)
        proper = false;
        return;
    end
    if numel(datafile) ~= 1 && numel(datafile) ~= 2
        proper = false;
        return;
    end
    if ~isstr(datafile{1})
        proper = false;
        return;
    end
    if numel(datafile) == 2 && ~isstr(datafile{2})
        proper = false;
        return;
    end
    proper = true;
end

function assert_same_sample_rate(data)
    sample_rates = [];
    for i = 1:numel(data)
        sample_rates(end + 1) = data{i}.sampleRate;
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

function expect_list = map_pspm_header_to_smi_headers(pspm_chantype)
    type_parts = split(pspm_chantype, '_');
    if strcmpi(type_parts{1}, 'pupil')
        which_eye = upper(type_parts{2});
        expect_list = {[which_eye ' Dia'], [which_eye ' Dia X'], [which_eye ' Area'], [which_eye ' Mapped Diameter']};
    elseif strcmpi(type_parts{1}, 'gaze')
        coord = upper(type_parts{2});
        which_eye = upper(type_parts{3});
        expect_list = {[which_eye ' POR ' coord]};
    elseif strcmpi(type_parts{1}, 'blink')
        which_eye = upper(type_parts{2});
        expect_list = {[which_eye, ' Blink']};
    elseif strcmpi(type_parts{1}, 'saccade')
        which_eye = upper(type_parts{2});
        expect_list = {[which_eye ' Saccade']};
    end
end

function assert_all_chantypes_are_in_imported_data(data, sample_file, import)
    % Assert that all given input channels are contained in at least one of the
    % imported sessions. They don't have to be in all the sessions; the remaining
    % parts will be filled with NaNs.
    for k = 1:numel(import)
        if strcmpi(import{k}.type, 'marker') || strcmpi(import{k}.type, 'custom')
            continue
        end
        expect_list = map_pspm_header_to_smi_headers(import{k}.type);
        data_contains_type = false;
        for i = 1:numel(data)
            session_channels = data{i}.channels_columns;
            for j = 1:numel(expect_list)
                data_contains_type = data_contains_type || any(contains(lower(session_channels), lower(expect_list{j})));
            end
        end
        if ~data_contains_type
            expect_list_str = sprintf('"%s", ', expect_list{:});
            expect_list_str = expect_list_str(1:end-2);
            error_msg = sprintf(['Channel type %s is not in the given sample_file %s.' ...
                ' For channel type %s, we searched for %s channel(s)'], ...
                input_type, sample_file, input_type, expect_list_str);
            error('ID:channel_not_contained_in_file', error_msg);
        end
    end
end

function [import_cell, chan_id] = import_marker_chan(import_cell, markers, mi_values, mi_names, sampling_rate)
    import_cell.marker = 'continuous';
    import_cell.sr     = sampling_rate;
    import_cell.data   = markers;
    markerinfo.names = mi_names;
    markerinfo.values = mi_values;
    import_cell.markerinfo = markerinfo;
    import_cell.flank = 'ascending';
    chan_id = -1;
end

function [import_cell, chan_id] = import_pupil_chan(import_cell, data_concat, viewing_dist, raw_columns, chan_struct, units, sampling_rate)
    smi_headers = map_pspm_header_to_smi_headers(import_cell.type);

    % try mapped diameter method first
    mapped_diam_header = smi_headers(contains(smi_headers, 'Mapped Diameter'));
    mapped_diam_idx_in_data = find(contains(chan_struct, mapped_diam_header));
    if ~isempty(mapped_diam_idx_in_data)
        import_cell.data = data_concat(:, mapped_diam_idx_in_data);
        chan_id_concat = mapped_diam_idx_in_data;
    else
        % check if there is any channel in mm
        all_channels = [];
        for i = 1:numel(smi_headers)
            possible_pupil_indices = find(contains(chan_struct, smi_headers{i}));
            all_channels = [all_channels possible_pupil_indices];
        end
        all_channels = unique(all_channels);
        channel_indices_in_mm = find(contains(units(all_channels), 'mm'));
        all_channels_in_mm = all_channels(channel_indices_in_mm);
        if ~isempty(all_channels_in_mm)
            % prefer diameter to area
            mm_units = units(all_channels_in_mm);
            mm_diameter_indices = find(contains(mm_units, 'diameter'));
            if ~isempty(mm_diameter_indices)
                chan_id_concat = all_channels_in_mm(mm_diameter_indices(1));
                import_cell.data = data_concat(:, chan_id_concat);
            else
                chan_id_concat = all_channels_in_mm(1);
                area_mm2 = data_concat(:, chan_id_concat);
                import_cell.data = (2 / sqrt(pi)) * sqrt(area_mm2);
            end
        else
            % prefer diameter to area
            all_channels_in_px = all_channels;
            px_units = units(all_channels_in_px);
            px_diameter_indices = find(contains(px_units, 'diameter'));
            if ~isempty(px_diameter_indices)
                chan_id_concat = all_channels_in_px(px_diameter_indices(1));
                dia_px = data_concat(:, chan_id_concat);
                % TODO: validate conversion coefficients
                [~, import_cell.data] = pspm_convert_au2unit(dia_px, 'mm', viewing_dist, 'diameter', 0.00087743, 0.0, 700, 'mm');
            else
                chan_id_concat = all_channels_in_px(1);
                area_px2 = data_concat(:, chan_id_concat);
                % TODO: validate conversion coefficients
                [~, import_cell.data] = pspm_convert_au2unit(area_px2, 'mm', viewing_dist, 'area', 0.12652, 0.0, 700, 'mm');
            end
        end
    end
    chan_id = find(contains(raw_columns, chan_struct{chan_id_concat}));
    if ~strcmp('mm', import_cell.target_unit)
        [~, import_cell.data] = pspm_convert_unit(import_cell.data, 'mm', import_cell.target_unit);
    end
    import_cell.units = import_cell.target_unit;
    import_cell.sr = sampling_rate;
end

function [import_cell, chan_id] = import_gaze_chan(import_cell, data_concat, screen_size_px, screen_size_mm, raw_columns, chan_struct, sampling_rate)
    smi_headers = map_pspm_header_to_smi_headers(import_cell.type);
    % in case of gaze, there is only one possible header
    smi_header = smi_headers{1};

    chan_id_concat = find(contains(chan_struct, smi_header), 1, 'first');
    gaze_px = data_concat(:, chan_id_concat);

    if contains(lower(smi_header), ' x')
        n_pixels_along_axis = screen_size_px(1);
        axis_len_mm = screen_size_mm(1);
    elseif contains(lower(smi_header), ' y')
        n_pixels_along_axis = screen_size_px(2);
        axis_len_mm = screen_size_mm(2);
    else
        error('ID:pspm_error', 'This branch should not have been taken. Please report this error to PsPM dev team');
    end

    ratio = gaze_px / n_pixels_along_axis;
    chan_id = find(contains(raw_columns, chan_struct{chan_id_concat}));
    import_cell.data = ratio * axis_len_mm;
    if ~strcmp('mm', import_cell.target_unit)
        [~, import_cell.data] = pspm_convert_unit(import_cell.data, 'mm', import_cell.target_unit);
    end
    import_cell.units = import_cell.target_unit;
    import_cell.sr = sampling_rate;
end

function [import_cell, chan_id] = import_blink_or_saccade_chan(import_cell, data_concat, raw_columns, chan_struct, units, sampling_rate)
    smi_headers = map_pspm_header_to_smi_headers(import_cell.type);
    % in case of blink/saccade, there is only one possible header
    smi_header = smi_headers{1};

    chan_id_concat = find(contains(chan_struct, smi_header), 1, 'first');
    chan_id = -1;
    import_cell.data = data_concat(:, chan_id_concat);
    import_cell.units = units{chan_id_concat};
    import_cell.sr = sampling_rate;
end

function [import_cell, chan_id] = import_custom_chan(import_cell, data_concat, raw_columns, chan_struct, units, sampling_rate)
    n_cols = size(raw_columns, 2);
    chan_id = import_cell.channel;
    if chan_id < 1
        error('ID:invalid_input', sprintf('Custom channel id %d is less than 1', chan_id));
    end
    if chan_id > n_cols
        error('ID:invalid_input', sprintf('Custom channel id (%d) is greater than number of columns (%d) in sample file', chan_id, n_cols));
    end
    custom_channel_header = raw_columns{chan_id};
    chan_id_in_concat = find(strcmpi(custom_channel_header, chan_struct));
    if isempty(chan_id_in_concat)
        error('ID:invalid_input', sprintf('Custom channel %s cannot be imported using get_smi', custom_channel_header));
    end
    import_cell.data = data_concat(:, chan_id_in_concat);
    import_cell.units = units{chan_id_in_concat};
    import_cell.data_header = chan_struct{chan_id_in_concat};
    import_cell.sr = sampling_rate;
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
    sr = data{1}.sampleRate;
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
