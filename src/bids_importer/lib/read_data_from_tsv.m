function data = read_data_from_tsv(tsv_filepath, has_headings, headings, col_types)

if ~has_headings && isempty(headings)
    error('If the file has no header, you must provide column headings.');
end

cleanupFile = "";   % track temporary file for deletion
originalFile = tsv_filepath;

% -------------------------------------------------------------------------
% Handle .tsv.gz files
if endsWith(tsv_filepath, '.gz', 'IgnoreCase', true)

    if ~isfile(tsv_filepath)
        error('File not found: %s', tsv_filepath);
    end

    tmpDir = tempname;
    mkdir(tmpDir);

    % unzip into temporary folder
    gunzip(tsv_filepath, tmpDir);

    % get unzipped filename
    [~, name, ~] = fileparts(tsv_filepath);  % removes .gz
    unzippedFile = fullfile(tmpDir, name);

    tsv_filepath = unzippedFile;
    cleanupFile = unzippedFile;
end

% -------------------------------------------------------------------------
% Detect import options
opts = detectImportOptions(tsv_filepath, ...
    'FileType', 'text', ...
    'Delimiter', '\t');

if ~has_headings
    opts.VariableNamingRule = 'preserve';
    opts.VariableNames = headings;
    opts.DataLines = [1 inf];
    opts.EmptyLineRule = 'read';
end

% -------------------------------------------------------------------------
% Adjust column types
numCols = numel(opts.VariableNames);

if length(col_types) < numCols
    additional = repmat({'char'}, 1, numCols - length(col_types));
    col_types = [col_types, additional];
elseif length(col_types) > numCols
    col_types = col_types(1:numCols);
end

opts.VariableTypes = col_types;

% -------------------------------------------------------------------------
% Read table
data = readtable(tsv_filepath, opts);

% -------------------------------------------------------------------------
% Cleanup temporary file
if strlength(cleanupFile) > 0
    try
        delete(cleanupFile);
        rmdir(fileparts(cleanupFile));
    catch
        % silently ignore cleanup failure
    end
end

end
