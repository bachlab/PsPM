function data = read_data_from_tsv(tsv_filepath, has_headings, headings, col_types)

if ~has_headings && isempty(headings)
    error('If the file has no header, you must provide column headings.');
end


opts = detectImportOptions(tsv_filepath, 'FileType', 'text', 'Delimiter', '\t');

if ~has_headings
    opts.VariableNamingRule = 'preserve';
    opts.VariableNames = headings;
    opts.DataLines = [1 inf]; % Read all data lines
    opts.EmptyLineRule = 'read';
end


% Determine the number of columns in the file.
numCols = numel(opts.VariableNames);

% Adjust the col_types list to match the file's number of columns.
if length(col_types) < numCols
    % Append default type 'char' for extra columns. % what if it is not a
    % char ????
    additional = repmat({'char'}, 1, numCols - length(col_types));
    col_types = [col_types, additional];
elseif length(col_types) > numCols
    col_types = col_types(1:numCols);
end

opts.VariableTypes = col_types;

data = readtable(tsv_filepath, opts);

end
