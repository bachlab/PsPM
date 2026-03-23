function [data_file, json_file] = find_bids_file( ...
    ses_path, suffix, task_id, run_id, filters)
% FIND_BIDS_FILE  Locate a BIDS file using flexible entity filters.
%
%   [data_file, json_file] = find_bids_file( ...
%       ses_path, suffix, task_id, run_id, filters)
%
%   Inputs:
%       ses_path   - session directory
%       suffix     - file suffix to search (e.g. 'events.tsv')
%       task_id    - task label (optional)
%       run_id     - run label (optional)
%       filters    - additional BIDS entity filters (optional)
%                    string or cell array of strings
%
%   Returns:
%       data_file  - matched file path
%       json_file  - corresponding JSON file (if applicable)

    % Handle optional inputs safely
    if nargin < 3 || isempty(task_id)
        task_id = '';
    end

    if nargin < 4 || isempty(run_id)
        run_id = '';
    end

    if nargin < 5 || isempty(filters)
        filters = {};
    end

    % Ensure filters is a cell array
    if ischar(filters) || isstring(filters)
        filters = {char(filters)};
    end

    % Find candidate files
    all_files = FindFiles(ses_path, suffix).files;

    search = {};

    % Add task filter
    if ~isempty(task_id)
        search{end+1} = sprintf('task-%s', task_id);
    end

    % Add run filter
    if ~isempty(run_id)
        search{end+1} = sprintf('run-%s', run_id);
    end

    % Add custom filters
    search = [search, filters];

    % Locate file
    data_file = get_file_from_substring(search, all_files, 'none');

    % Find corresponding JSON
    if ~isempty(data_file)
        json_file = regexprep(data_file, '\.tsv(\.gz)?$', '.json');
        return;
    end

    % No match found
    data_file = '';
    json_file = '';
end
