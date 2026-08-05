classdef FindFiles
    %FINDFILES Search for files in a directory based on extension, filters, and depth.
    %
    % Usage:
    %   ff = FindFiles("/data", ".nii");
    %   disp(ff.files)
    %
    %   % With max depth + filters + exclude
    %   ff = FindFiles("/data", ".tsv.gz", "exclude", "._", "filters", {"task-rest","physio"}, "maxdepth", 2);

    properties
        directory   (1,1) string
        extension   (1,1) string
        exclude             % [] | string | cellstr
        maxdepth            % [] | integer
        filters             % [] | string | cellstr
        files               % char | cellstr (mirrors python behavior)
    end

    methods
        function obj = FindFiles(directory, extension, varargin)
            % FindFiles(directory, extension, 'exclude', ..., 'maxdepth', ..., 'filters', ...)
            %
            % directory: folder to search
            % extension: like ".nii" or ".csv" or ".tsv.gz"

            p = inputParser;
            p.addRequired("directory", @(x) ischar(x) || isstring(x));
            p.addRequired("extension", @(x) ischar(x) || isstring(x));
            p.addParameter("exclude", [], @(x) isempty(x) || ischar(x) || isstring(x) || iscell(x));
            p.addParameter("maxdepth", [], @(x) isempty(x) || (isscalar(x) && isnumeric(x) && x>=0));
            p.addParameter("filters", [], @(x) isempty(x) || ischar(x) || isstring(x) || iscell(x));
            p.parse(directory, extension, varargin{:});

            obj.directory = string(p.Results.directory);
            obj.extension = string(p.Results.extension);
            obj.exclude   = p.Results.exclude;
            obj.maxdepth  = p.Results.maxdepth;
            obj.filters   = p.Results.filters;

            % --- collect files recursively ---
            pattern = "*" + obj.extension; % e.g. "*.nii" or "*.tsv.gz"
            file_list = FindFiles.find_files(obj.directory, pattern, obj.maxdepth);

            % remove macOS resource fork files "._*"
            keep = true(1, numel(file_list));
            for i = 1:numel(file_list)
                [~, nm, ext] = fileparts(file_list{i});
                base = [nm ext];
                if startsWith(base, "._")
                    keep(i) = false;
                end
            end
            file_list = file_list(keep);

            % sort
            file_list = sort(file_list);

            % --- apply filters/exclude like python (using get_file_from_substring) ---
            if ~isempty(obj.exclude) || ~isempty(obj.filters)
                filt = obj.filters;
                if isempty(filt)
                    filt = {};  % no filters means "everything", but python only filters when provided.
                end

                % If filters are empty but exclude exists, we still want exclusion applied.
                % We'll emulate that by filtering with an empty filt (= match all),
                % then applying exclusion.
                if isempty(filt)
                    % match all files
                    if isempty(obj.exclude)
                        out = file_list;
                    else
                        out = apply_exclude_only(file_list, obj.exclude);
                    end
                else
                    out = get_file_from_substring(filt, file_list, 'error', obj.exclude);
                end

                obj.files = out;
            else
                obj.files = file_list;
            end
        end
    end

    methods (Static)
        function files = find_files(directory, pattern, maxdepth)
            %FINDFILES Recursively find files matching pattern with optional max depth.
            %
            % directory: string/char
            % pattern: e.g. "*.nii", "*.csv", "*.tsv.gz"
            % maxdepth: [] for unlimited, or non-negative integer
            %
            % Returns cell array of full paths.

            directory = char(directory);
            pattern   = char(pattern);

            if nargin < 3
                maxdepth = [];
            end

            if ~isfolder(directory)
                error('FindFiles:NotAFolder', 'Directory does not exist: %s', directory);
            end

            files = {};
            rootDepth = count_seps(directory);

            % BFS stack of directories
            stack = {directory};

            while ~isempty(stack)
                current = stack{1};
                stack(1) = [];

                curDepth = count_seps(current) - rootDepth;
                if ~isempty(maxdepth) && curDepth > maxdepth
                    continue;
                end

                listing = dir(current);

                for i = 1:numel(listing)
                    item = listing(i);

                    if item.isdir
                        nm = item.name;
                        if strcmp(nm, '.') || strcmp(nm, '..')
                            continue;
                        end
                        stack{end+1} = fullfile(current, nm); %#ok<AGROW>
                    else
                        if FindFiles.match_pattern(item.name, pattern)
                            files{end+1} = fullfile(current, item.name); %#ok<AGROW>
                        end
                    end
                end
            end
        end

        function tf = match_pattern(filename, pattern)
            % Simple glob match supporting '*' wildcard.
            % pattern like "*.nii" or "*.tsv.gz"
            %
            % Convert glob -> regex
            expr = regexptranslate('wildcard', pattern);
            tf = ~isempty(regexp(filename, ['^' expr '$'], 'once'));
        end
    end
end

% ---- local helpers (same file is okay in modern MATLAB; otherwise split) ----

function n = count_seps(p)
    % count path separators to approximate depth
    p = char(p);
    n = sum(p == filesep);
end

function out = apply_exclude_only(file_list, exclude)
    % Apply exclude to a cell array of paths; return char if single like python helper.

    if ischar(exclude) || isstring(exclude)
        exclude = {char(exclude)};
    elseif iscell(exclude)
        % ok
    else
        exclude = {};
    end

    keep = true(1, numel(file_list));
    for i = 1:numel(file_list)
        f = file_list{i};
        for ex = 1:numel(exclude)
            if contains(f, exclude{ex})
                keep(i) = false;
                break;
            end
        end
    end
    out = file_list(keep);

    if numel(out) == 1
        out = out{1};
    end
end
