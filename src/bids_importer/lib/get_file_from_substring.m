function out = get_file_from_substring(filt, path, return_msg, exclude)
%GET_FILE_FROM_SUBSTRING Find file(s) whose names contain all substrings in filt.
%
% out = get_file_from_substring(filt, path, return_msg, exclude)
%
% filt: char/string or cellstr/string array of required substrings
% path: folder path (char/string) OR cell array of filenames
% return_msg: 'error' (default) to throw if none found, otherwise returns []
% exclude: optional char/string or cellstr/string array of substrings to exclude
%
% Returns:
%  - char (full path) if exactly one match
%  - cell array of char (full paths) if multiple matches
%  - [] if none found and return_msg ~= 'error'

    if nargin < 3 || isempty(return_msg)
        return_msg = 'error';
    end
    if nargin < 4
        exclude = [];
    end

    % Normalize filt -> cellstr
    filt = normalize_to_cellstr(filt, 'filt');

    % Normalize exclude -> cellstr (or empty)
    if ~isempty(exclude)
        exclude = normalize_to_cellstr(exclude, 'exclude');
    else
        exclude = {};
    end

    input_is_list = false;

    % Get list of files
    if ischar(path) || isstring(path)
        folder = char(path);
        if ~isfolder(folder)
            error('get_file_from_substring:NotAFolder', ...
                'Path is not a folder: %s', folder);
        end
        listing = dir(folder);
        listing = listing(~[listing.isdir]); % files only
        files_in_directory = sort({listing.name});
    elseif iscell(path)
        input_is_list = true;
        files_in_directory = path(:)'; % row cell
        folder = ''; % unused
    else
        error('get_file_from_substring:BadInputType', ...
            'path must be a folder path (char/string) or a cell array of filenames.');
    end

    % Build match mask: file matches if it contains ALL filt substrings
    nFiles = numel(files_in_directory);
    match_mask = true(1, nFiles);

    for fi = 1:numel(filt)
        this_f = filt{fi};
        contains_mask = false(1, nFiles);
        for i = 1:nFiles
            contains_mask(i) = contains(files_in_directory{i}, this_f);
        end
        match_mask = match_mask & contains_mask;
    end

    match_idx = find(match_mask);

    % No matches
    if isempty(match_idx)
        if strcmpi(return_msg, 'error')
            error('get_file_from_substring:NotFound', ...
                'Could not find file with filters: [%s] in %s', strjoin(filt, ', '), path_to_str(path));
        else
            out = [];
            return;
        end
    end

    % Build match list (filenames or fullpaths)
    if input_is_list
        match_list = files_in_directory(match_idx);
    else
        match_list = cellfun(@(fn) fullfile(folder, fn), files_in_directory(match_idx), 'UniformOutput', false);
    end

    % Apply exclusions (exclude after matching)
    if ~isempty(exclude)
        keep = true(1, numel(match_list));
        for i = 1:numel(match_list)
            f = match_list{i};
            % exclude checks against full path (like your python version)
            for ex = 1:numel(exclude)
                if contains(f, exclude{ex})
                    keep(i) = false;
                    break;
                end
            end
        end
        match_list = match_list(keep);

        if isempty(match_list)
            if strcmpi(return_msg, 'error')
                error('get_file_from_substring:NotFoundAfterExclude', ...
                    'Could not find file with filters: [%s] and exclusion of [%s] in %s', ...
                    strjoin(filt, ', '), strjoin(exclude, ', '), path_to_str(path));
            else
                out = [];
                return;
            end
        end
    end

    % Return scalar as char, multiple as cellstr
    if numel(match_list) == 1
        out = match_list{1};
    else
        out = match_list;
    end
end

% ---------- helpers ----------

function c = normalize_to_cellstr(x, name)
    if ischar(x)
        c = {x};
    elseif isstring(x)
        x = x(:);
        c = cellstr(x);
    elseif iscell(x)
        % ensure cell array of char
        c = cell(1, numel(x));
        for i = 1:numel(x)
            if isstring(x{i})
                c{i} = char(x{i});
            elseif ischar(x{i})
                c{i} = x{i};
            else
                error('get_file_from_substring:Bad%s', name, ...
                    '%s must be char/string or a cell array of char/string.', name);
            end
        end
    else
        error('get_file_from_substring:Bad%s', name, ...
            '%s must be char/string or a cell array of char/string.', name);
    end
end

function s = path_to_str(p)
    if ischar(p) || isstring(p)
        s = char(p);
    else
        s = '<cell list>';
    end
end
