function out = read_smi_events(filepath)
    % Read an SMI event file and return left blinks, right blinks, left saccades,
    % right saccades and user messages in out struct.
    %
    % FORMAT:
    %   [out] = read_smi_events(filepath)
    %
    % INPUT:
    %             filepath: Path to the file which contains SMI events in ASCII format.
    %
    % OUTPUT:
    %             out: Output structure with the following fields:
    %
    %               blink_l: Structure with the following fields:
    %                   trial: Trials of the blink events
    %                   start: Start timestamps of the blink events
    %                   end  : End timestamps of the blink events
    %
    %               blink_r: Structure with the following fields:
    %                   trial: Trials of the blink events
    %                   start: Start timestamps of the blink events
    %                   end  : End timestamps of the blink events
    %
    %               sacc_l: Structure with the following fields:
    %                   trial: Trials of the saccade events
    %                   start: Start timestamps of the saccade events
    %                   end  : End timestamps of the saccade events
    %
    %               sacc_r: Structure with the following fields:
    %                   trial: Trials of the saccade events
    %                   start: Start timestamps of the saccade events
    %                   end  : End timestamps of the saccade events
    %
    %               marker: Structure with the following fields:
    %                   trial: Trials of the markers (user events)
    %                   start: Start timestamps of the markers (user events)
    %                   msg:   User messages at each marker (user event)
    %__________________________________________________________________________
    %
    % (C) 2019 Eshref Yozdemir
    bsearch_path = pspm_path('backroom', 'bsearch');
    addpath(bsearch_path);

    if ~exist(filepath,'file')
        error('ID:invalid_input', sprintf('Passed file %s does not exist.', filepath));
    end
    str = fileread(filepath);
    line_ctr = 1;
    has_backr = ~isempty(find(str == sprintf('\r'), 1, 'first'));
    linefeeds = [0, strfind(str, sprintf('\n'))];

    [header_struct, line_ctr] = parse_header(str, line_ctr, linefeeds, has_backr);

    linefeeds = linefeeds(line_ctr : end);
    str = str(linefeeds(1) + 1 : end);
    linefeeds = linefeeds - linefeeds(1);
    line_ctr = 1;

    [markernum, msg, blink_l, blink_r, sacc_l, sacc_r] = parse_events(str, linefeeds, has_backr, header_struct);
    rmpath(bsearch_path);

    out.blink_l.trial = blink_l(:, find(strcmpi(header_struct.blink_names, 'Trial')));
    out.blink_l.start = blink_l(:, find(strcmpi(header_struct.blink_names, 'Start')));
    out.blink_l.end = blink_l(:, find(strcmpi(header_struct.blink_names, 'End')));
    out.blink_r.trial = blink_r(:, find(strcmpi(header_struct.blink_names, 'Trial')));
    out.blink_r.start = blink_r(:, find(strcmpi(header_struct.blink_names, 'Start')));
    out.blink_r.end = blink_r(:, find(strcmpi(header_struct.blink_names, 'End')));

    out.sacc_l.trial = sacc_l(:, find(strcmpi(header_struct.sacc_names, 'Trial')));
    out.sacc_l.start = sacc_l(:, find(strcmpi(header_struct.sacc_names, 'Start')));
    out.sacc_l.end = sacc_l(:, find(strcmpi(header_struct.sacc_names, 'End')));
    out.sacc_r.trial = sacc_r(:, find(strcmpi(header_struct.sacc_names, 'Trial')));
    out.sacc_r.start = sacc_r(:, find(strcmpi(header_struct.sacc_names, 'Start')));
    out.sacc_r.end = sacc_r(:, find(strcmpi(header_struct.sacc_names, 'End')));

    out.marker.trial = markernum(:, find(strcmpi(header_struct.marker_names, 'Trial')));
    out.marker.start = markernum(:, find(strcmpi(header_struct.marker_names, 'Start')));
    out.marker.msg = msg;
end

function [out, line_ctr] = parse_header(str, line_ctr, linefeeds, has_backr)
    curr_line = str(linefeeds(line_ctr) + 1 : linefeeds(line_ctr + 1) - 1 - has_backr);
    tab = sprintf('\t');
    found = false(3, 1);
    out = struct();
    while ~all(found)
        if contains(curr_line, 'Table Header for Saccades') || contains(curr_line, 'Table Header for Blinks')
            line_ctr = line_ctr + 1;
            next_line = readline(str, linefeeds, line_ctr, has_backr);

            parts = split(next_line, tab);
            fmt = '%*s';
            names = {};
            for i = 2:numel(parts)
                fmt = [fmt tab];
                if strcmpi(parts{i}, 'Start') || strcmpi(parts{i}, 'End') || strcmpi(parts{i}, 'Trial')
                    fmt = [fmt '%d64'];
                    names{end + 1} = parts{i};
                else
                    fmt = [fmt '%*s'];
                end
            end

            if contains(curr_line, 'Table Header for Saccades')
                found(1) = true;
                out.sacc_fmt = fmt;
                out.sacc_names = names;
            else
                found(2) = true;
                out.blink_fmt = fmt;
                out.blink_names = names;
            end
        elseif contains(curr_line, 'Table Header for User Events')
            line_ctr = line_ctr + 1;
            next_line = readline(str, linefeeds, line_ctr, has_backr);

            parts = split(next_line, tab);
            fmt = '%*s';
            names = {};
            for i = 2:numel(parts)
                fmt = [fmt tab];
                if strcmpi(parts{i}, 'Start') || strcmpi(parts{i}, 'Trial')
                    fmt = [fmt '%d64'];
                    names{end + 1} = parts{i};
                elseif strcmpi(parts{i}, 'Description')
                    fmt = [fmt '%s'];
                    names{end + 1} = parts{i};
                else
                    fmt = [fmt '%*s'];
                end
            end

            out.marker_fmt = fmt;
            out.marker_names = names;
            found(3) = true;
        end
        line_ctr = line_ctr + 1;
        curr_line = readline(str, linefeeds, line_ctr, has_backr);
    end

    while true
        if isempty(curr_line)
            go_forward = 1;
        elseif startsWith(curr_line, 'Table Header for')
            go_forward = 2;
        else
            break
        end
        line_ctr = line_ctr + go_forward;
        curr_line = readline(str, linefeeds, line_ctr, has_backr);
    end
end

function [markernum, messages, blink_l, blink_r, sacc_l, sacc_r] = parse_events(str, linefeeds, has_backr, header_struct)
    linebeg_indices = linefeeds(1: end - 1) + 1;
    linebegs = str(linebeg_indices);

    marker_str = concatenate_separate_event_lines(str, find(linebegs == 'U'), linefeeds);
    blink_str = concatenate_separate_event_lines(str, find(linebegs == 'B'), linefeeds);
    sacc_str = concatenate_separate_event_lines(str, find(linebegs == 'S'), linefeeds);

    blink_left_mask = find_lefteye_events(blink_str, 'Blink');
    sacc_left_mask = find_lefteye_events(sacc_str, 'Saccade');

    C = textscan(marker_str, header_struct.marker_fmt, ...
        'Delimiter', '\t', ...
        'CollectOutput', 1);
    markernum = C{1};
    messages = C{2};

    C = textscan(blink_str, header_struct.blink_fmt, ...
        'Delimiter', '\t', ...
        'CollectOutput', 1);
    blinknum = C{1};
    blink_l = blinknum(blink_left_mask, :);
    blink_r = blinknum(~blink_left_mask, :);

    C = textscan(sacc_str, header_struct.sacc_fmt, ...
        'Delimiter', '\t', ...
        'CollectOutput', 1);
    saccnum = C{1};
    sacc_l = saccnum(sacc_left_mask, :);
    sacc_r = saccnum(~sacc_left_mask, :);
end

function leftmask = find_lefteye_events(str, event_name)
    n_to_the_right = numel(event_name) + 1;
    linefeeds = [0, strfind(str, sprintf('\n'))];
    linebegs = linefeeds(1 : end - 1) + 1;
    eye_chars = str(linebegs + n_to_the_right);
    leftmask = eye_chars == 'L';
end

function events_concat = concatenate_separate_event_lines(str, line_indices, linefeeds)
    char_indices = false(numel(str), 1);
    for i = 1:numel(line_indices)
        begidx = linefeeds(line_indices(i)) + 1;
        endidx = linefeeds(line_indices(i) + 1);
        char_indices(begidx : endidx) = true;
    end
    events_concat = str(char_indices);
end

function linestr = readline(str, linefeeds, line_ctr, has_backr)
    linestr = str(linefeeds(line_ctr) + 1 : linefeeds(line_ctr + 1) - 1 - has_backr);
end
