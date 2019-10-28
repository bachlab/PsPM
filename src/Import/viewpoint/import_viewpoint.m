function [data] = import_viewpoint(filepath)
    % import_viewpoint is the function for importing raw ViewPoint (.txt) files to
    % usual PsPM structure.
    %
    % FORMAT: [data] = import_viewpoint(filepath)
    %             filepath: Path to the file which contains the recorded ViewPoint
    %                       data in ASCII format.
    %
    %             data: Output cell array of structures. Each entry in the cell array
    %                   corresponds to one recording session (trial) in the datafile.
    %                   Each of these structures have the following entries:
    %
    %                       dataraw: Cell array containing raw data columns.
    %                       dataraw_header: Column headers of each raw data column.
    %                       channels: Matrix (timestep x n_cols) of relevant PsPM columns.
    %                                 Currently, time, pupil, gaze, blink and saccade channels
    %                                 are imported.
    %                       channels_header: Column headers of each channels column.
    %                       channels_units: Units of each channels column.
    %                       eyesObserved: Either A or AB, denoting observed eyes in datafile.
    %                       viewingDistance: Viewing distance in milimeters.
    %                       screenSize: Structure with fields
    %                           - xmin: x coordinate of top left corner of screen in milimeters.
    %                           - ymin: y coordinate of top left corner of screen in milimeters.
    %                           - xmax: x coordinate of bottom right corner of screen in milimeters.
    %                           - ymax: y coordinate of bottom right corner of screen in milimeters.
    %                       marker: Structure with fields
    %                           - name: Cell array of marker name.
    %                           - pos: Indices of markers in time column.
    %                           - times: Seconds of markers.
    %                       record_date: Recording date
    %                       record_time: Recording time
    %
    %__________________________________________________________________________
    %
    % (C) 2019 Laure Ciernik
    % Function inspired by GazeAlyze �.. Most parts rewritten by Eshref Yozdemir to handle
    % newer ViewPoint files.
    bsearch_path = fullfile(fileparts(which('import_viewpoint')), '..', '..', 'backroom', 'bsearch');
    addpath(bsearch_path);

    if ~exist(filepath,'file')
        error('ID:invalid_input', 'Passed file does not exist.');
    end

    [dataraw, marker, messages, chan_info, file_info] = parse_viewpoint_file(filepath);

    channels = dataraw(:, chan_info.col_idx);
    [channels, marker, chan_info] = parse_messages(messages, channels, marker, chan_info, file_info.eyesObserved);

    sess_beg_indices = [];
    marker_indices = find(cellfun(@(x) ~isempty(x), marker));
    for i = 1:numel(marker_indices)
        idx = marker_indices(i);
        marker_str = marker{idx};
        char_eq = (marker_str == '+') + (marker_str == '=') + (marker_str == ',');
        if sum(char_eq) == numel(marker_str)
            sess_beg_indices(end + 1) = idx;
        end
    end
    sess_beg_indices(end + 1) = size(dataraw, 1) + 1;
    
    for sn = 1:numel(sess_beg_indices) - 1
        begidx = sess_beg_indices(sn);
        endidx = sess_beg_indices(sn + 1) - 1;
        data{sn}.dataraw = dataraw(begidx : endidx, :);
        data{sn}.dataraw_header = chan_info.read_numeric_columns';
        data{sn}.channels = channels(begidx : endidx, :);
        data{sn}.channels_header = chan_info.channels_header;
        data{sn}.channels_units = chan_info.channels_units;
        data{sn}.channel_indices = chan_info.col_idx;
        data{sn}.eyesObserved = file_info.eyesObserved;
        data{sn}.viewingDistance = file_info.viewingDistance;
        data{sn}.screenSize = file_info.screenSize;
        data{sn}.record_date = file_info.record_date;
        data{sn}.record_time = file_info.record_time;

        markers_in_sess = marker(begidx : endidx);
        nonempty_indices = find(cell2mat(cellfun(@(x) ~isempty(x), markers_in_sess, 'UniformOutput', 0)));
        data{sn}.marker.name = markers_in_sess(nonempty_indices);
        data{sn}.marker.value = (-1) * ones('like', nonempty_indices);
        data{sn}.marker.pos = nonempty_indices;
        data{sn}.marker.times = data{sn}.channels(nonempty_indices, 1);
    end
    rmpath(bsearch_path);
end

function [dataraw, marker, messages, chan_info, file_info] = parse_viewpoint_file(filepath)
    % read file
    str = fileread(filepath);
    has_backr = ~isempty(find(str == sprintf('\r'), 1, 'first'));
    linefeeds = [0, strfind(str, sprintf('\n'))];

    line_ctr = 1;
    [file_info, line_ctr] = parse_metadata(str, line_ctr, linefeeds, has_backr);
    [columns, column_ids, line_ctr] = parse_header(str, line_ctr, linefeeds, has_backr);

    eyesObserved = 'A';
    if any(startsWith(column_ids, 'B'))
        eyesObserved = 'AB';
    end

    [col_idx, channels_header, channels_units] = pspm_chans_in_file(column_ids, eyesObserved);
    [msg_linenums, messages] = get_msg_lines(str, linefeeds, has_backr);

    linefeeds = linefeeds(line_ctr : end);
    str = str(linefeeds(1) + 1 : end);
    msg_linenums = msg_linenums - line_ctr + 1;
    linefeeds = linefeeds - linefeeds(1);

    [read_numeric_columns, fmt_str] = get_columns_to_read(column_ids);

    for msg_line = msg_linenums
        begidx = linefeeds(msg_line) + 1;
        str(begidx : begidx + 1) = '/';
    end
    C = textscan(str, fmt_str, 'Delimiter', '\t', 'CollectOutput', 1, 'CommentStyle', '//');
    dataraw = C{1};
    marker = C{2};

    file_info.columns = columns;
    file_info.column_ids = column_ids;
    file_info.eyesObserved = eyesObserved;
    chan_info.read_numeric_columns = read_numeric_columns;
    chan_info.col_idx = col_idx;
    chan_info.channels_header = channels_header;
    chan_info.channels_units = channels_units;
end

function [file_info, line_ctr] = parse_metadata(str, line_ctr, linefeeds, has_backr)
    file_info.record_date = '00.00.0000';
    file_info.record_time = '00:00:00';
    file_info.viewingDistance = -1;
    file_info.screenSize.xmin = 0;
    file_info.screenSize.xmax = -1;
    file_info.screenSize.ymin = 0;
    file_info.screenSize.ymax = -1;
    curr_line = str(linefeeds(line_ctr) + 1 : linefeeds(line_ctr + 1) - 1 - has_backr);
    tab = sprintf('\t');
    while startsWith(curr_line, '3')
        if contains(curr_line, 'TimeStamp')
            parts = split(curr_line, tab);
            date_part = parts{3};
            date_fmt = 'eeee, MMMM d, yyyy, hh:mm:ss a';
            date = datetime(date_part, 'InputFormat', date_fmt);
            file_info.record_date = sprintf('%.2d.%.2d.%.2d', date.Day, date.Month, date.Year);
            file_info.record_time = sprintf('%.2d:%.2d:%.2d', date.Hour, date.Minute, date.Second);
        elseif contains(curr_line, 'ScreenSize')
            parts = split(curr_line, tab);
            file_info.screenSize.xmax = str2double(parts{3});
            file_info.screenSize.ymax = str2double(parts{4});
        elseif contains(curr_line, 'ViewingDistance')
            parts = split(curr_line, tab);
            file_info.viewingDistance = str2double(parts{3});
        end
        line_ctr = line_ctr + 1;
        curr_line = str(linefeeds(line_ctr) + 1 : linefeeds(line_ctr + 1) - 1 - has_backr);
    end
end

function [columns, column_ids, line_ctr] = parse_header(str, line_ctr, linefeeds, has_backr)
    columns = {};
    column_ids = {};
    curr_line = str(linefeeds(line_ctr) + 1 : linefeeds(line_ctr + 1) - 1 - has_backr);
    tab = sprintf('\t');
    n_feeds = numel(linefeeds);
    while ~startsWith(curr_line, '10')
        if startsWith(curr_line, '6')
            parts = split(curr_line, tab);
            column_ids = parts(2 : end);
        elseif startsWith(curr_line, '5')
            parts = split(curr_line, tab);
            columns = parts(2 : end);
        end
        line_ctr = line_ctr + 1;
        if line_ctr + 1 > n_feeds
            error('ID:invalid_input_file', 'Passed input file does not have data');
        end
        curr_line = str(linefeeds(line_ctr) + 1 : linefeeds(line_ctr + 1) - 1 - has_backr);
    end
end

function [col_idx, channels_header, channels_units] = pspm_chans_in_file(column_ids, eyesObserved)
    total_time_index = find(strcmp(column_ids, 'ATT'));
    col_idx = [total_time_index];
    channels_header = {'Time'};
    channels_units = {'seconds'};
    for which_eye = eyesObserved
        pupil_width_index = find(strcmp(column_ids, [which_eye 'PW']));
        gaze_col_indices = find(strcmp(column_ids, [which_eye 'LX']) | strcmp(column_ids, [which_eye 'LY']));
        corrected_gaze_col_indices = find(strcmp(column_ids, [which_eye 'CX']) | strcmp(column_ids, [which_eye 'CY']));
        pupil_dia_index = find(strcmp(column_ids, [which_eye 'PD']));

        n_prev_cols = numel(col_idx);
        col_idx = [col_idx; pupil_width_index; gaze_col_indices];
        channels_header = [channels_header; ['pupil_' which_eye]; ['gaze_x_' which_eye]; ['gaze_y_' which_eye]];
        channels_units = [channels_units; 'ratio'; 'ratio'; 'ratio'];

        if ~isempty(pupil_dia_index)
            col_idx(n_prev_cols + 1) = pupil_dia_index;
            channels_units{n_prev_cols + 1} = 'mm';
        end

        if ~isempty(corrected_gaze_col_indices)
            if numel(gaze_col_indices) ~= numel(corrected_gaze_col_indices)
                error('ID:invalid_datafile', ['Your viewpoint datafile does not conform to the standards.'
                    ' Please make sure you use a standard datafile']);
            end
            col_idx(n_prev_cols + 2 : n_prev_cols + numel(corrected_gaze_col_indices)) = corrected_gaze_col_indices;
        end
    end
end

function [msg_linenums, messages] = get_msg_lines(str, linefeeds, has_backr)
    data_beg_indices = strfind(str, sprintf('\n10\t'));
    datalines = [bsearch(linefeeds, data_beg_indices), numel(linefeeds)];
    n_message_lines = max(0, diff(datalines) - 1);
    datalines_msg_beg_indices = find(n_message_lines > 0);
    msg_beg_lines = int32(datalines(datalines_msg_beg_indices) + 1);
    msg_end_lines = int32(datalines(datalines_msg_beg_indices) + n_message_lines(datalines_msg_beg_indices));
    msg_linenums = [];
    for i = 1:numel(msg_beg_lines)
        msg_linenums(end + 1 : end + 1 + msg_end_lines(i) - msg_beg_lines(i)) = msg_beg_lines(i) : msg_end_lines(i);
    end

    messages = {};
    for msg_line = msg_linenums
        begidx = linefeeds(msg_line) + 1;
        endidx = linefeeds(msg_line + 1) - 1 - has_backr;
        messages{end + 1} = str(begidx : endidx);
    end
end

function [read_numeric_columns, fmt_str] = get_columns_to_read(column_ids)
    read_numeric_columns = ['TYPE'; column_ids];
    fmt_array = cell(1, numel(read_numeric_columns));
    fmt_array(:) = {'%f'};
    region_indices = find(endsWith(read_numeric_columns, 'RI'));
    marker_index = find(strcmp(read_numeric_columns, 'MRK'));
    str_index = find(strcmp(read_numeric_columns, 'STR'));

    fmt_array{1} = '%*f';
    indices_to_remove = [1];
    fmt_array(region_indices) = {'%*s'};
    indices_to_remove = [indices_to_remove; region_indices];
    fmt_array{marker_index} = '%s';
    indices_to_remove = [indices_to_remove; marker_index];
    if ~isempty(str_index)
        fmt_array{str_index} = '%*s';
        indices_to_remove = [indices_to_remove; str_index];
    end
    read_numeric_columns(indices_to_remove) = [];
    fmt_str = join(fmt_array, '\t');
    fmt_str = fmt_str{1};
end

function [channels, marker, chan_info] = parse_messages(messages, channels, marker, chan_info, eyesObserved)
    has_messages = ~isempty(messages);
    tab = sprintf('\t');
    if has_messages
        blinks_A = false(size(channels, 1), 1);
        blinks_B = false(size(channels, 1), 1);
        saccades_A = false(size(channels, 1), 1);
        saccades_B = false(size(channels, 1), 1);
        timecol = channels(:, 1);
        for msgline = messages
            parts = split(msgline, tab);
            msg_type = str2num(parts{1});
            if msg_type == 2 || msg_type == 12
                timestamp = str2double(parts{2});
                msg = parts{3};
                insert_idx = bsearch(timecol, timestamp);
                if timecol(insert_idx) == timestamp
                    marker{insert_idx} = msg;
                end
            elseif msg_type == 14
                continue;
            elseif (contains(msgline, 'Saccade') || contains(msgline, 'Blink')) && endsWith(msgline, 'sec')
                timestamp = str2double(parts{2});
                msg = parts{3};
                forbeg_idx = strfind(msg, ' for ');
                secbeg_idx = forbeg_idx + strfind(msg(forbeg_idx + 1 : end), ' ') + 1;
                secend_idx = secbeg_idx + strfind(msg(secbeg_idx + 1 : end), ' ') - 1;
                duration = str2double(msg(secbeg_idx : secend_idx));
                beg_timestamp = round(timestamp - duration, 4);

                index_of_beg_timestamp = bsearch(timecol, beg_timestamp);
                index_of_curr_timestamp = bsearch(timecol, timestamp);

                if contains(msgline, 'A:Saccade')
                    saccades_A(index_of_beg_timestamp : index_of_curr_timestamp) = true;
                elseif contains(msgline, 'B:Saccade')
                    saccades_B(index_of_beg_timestamp : index_of_curr_timestamp) = true;
                elseif contains(msgline, 'A:Blink')
                    blinks_A(index_of_beg_timestamp : index_of_curr_timestamp) = true;
                else
                    blinks_B(index_of_beg_timestamp : index_of_curr_timestamp) = true;
                end
            end
        end
        curr_n_cols = size(channels, 2);
        channels(:, curr_n_cols + 1) = blinks_A;
        channels(:, curr_n_cols + 2) = saccades_A;
        chan_info.channels_header = [chan_info.channels_header; 'blink_A'; 'saccade_A'];
        chan_info.channels_units = [chan_info.channels_units; 'blink'; 'saccade'];
        chan_info.col_idx = [chan_info.col_idx; -1; -1];
        if strcmp(eyesObserved, 'AB')
            channels(:, curr_n_cols + 3) = blinks_B;
            channels(:, curr_n_cols + 4) = saccades_B;
            chan_info.channels_header = [chan_info.channels_header; 'blink_B'; 'saccade_B'];
            chan_info.channels_units = [chan_info.channels_units; 'blink'; 'saccade'];
            chan_info.col_idx = [chan_info.col_idx; -1; -1];
        end
    end
end
