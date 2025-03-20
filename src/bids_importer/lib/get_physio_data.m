function [physio_data_cell] = get_physio_data(subject_id, session_id, task_name, physio_path)
% Returns a 4x1 cell array where each cell contains a struct with fields header and data (and markerinfo for events)
% Also returns physio_info_data needed to create 'info' struct

% Initialize the physio data cell array
physio_signals = { 'ecg','ppg', 'scr', 'event'}; 
num_signals = length(physio_signals);
physio_data_cell = cell(num_signals, 1);  % Preallocate cell array
pyhsio_main_struct = struct();


% Initialize variables for info
chan_names = cell(num_signals, 1);
file_paths = cell(num_signals, 1);

% Index to keep track of the cell array
cell_index = 1;


% Process each physio signal
for i = 1:num_signals - 1  % Exclude 'events' for now !
    signal = physio_signals{i};
    cell_index = i;  % Wo anders?
    % Construct filenames
    physio_json_filename = sprintf('%s_ses-%s_recording-%s_physio.json', subject_id, session_id, signal);
    physio_tsv_filename  = sprintf('%s_ses-%s_recording-%s_physio.tsv', subject_id, session_id, signal);

    physio_json_filepath = fullfile(physio_path, physio_json_filename);
    physio_tsv_filepath = fullfile(physio_path, physio_tsv_filename);

    % Collect file paths for info
    file_paths{cell_index} = physio_tsv_filepath;

    % Check if files exist
    if ~isfile(physio_json_filepath); error('File not found: %s', physio_json_filepath); end
    if ~isfile(physio_tsv_filepath);  error('File not found: %s', physio_tsv_filepath);  end

    % Read JSON metadata
    physio_json = extract_json_as_struct(physio_json_filepath);

    % Read TSV data
    headings = physio_json.Columns;  
    col_types = repmat({'double'}, 1, length(headings));
    physio_data_table = read_data_from_tsv(physio_tsv_filepath, false, headings.', col_types);
    
    % not like it should whats with multiple columns
    physio_json.Columns = physio_data_table;
    
    physio_data_cell{cell_index} = physio_json;

end

%% Process event data
cell_index = cell_index +1;
events_json_filename = sprintf('%s_ses-%s_task-%s_physioevents.json', subject_id, session_id, task_name);
events_tsv_filename  = sprintf('%s_ses-%s_task-%s_physioevents.tsv', subject_id, session_id, task_name);

events_json_filepath = fullfile(physio_path, events_json_filename);
events_tsv_filepath  = fullfile(physio_path, events_tsv_filename);

% check if files exist
if ~isfile(events_json_filepath); error('File not found: %s', events_json_filepath); end
if ~isfile(events_tsv_filepath);  error('File not found: %s', events_tsv_filepath);  end


% Read JSON metadata
events_json = extract_json_as_struct(events_json_filepath);

% Read events TSV
has_headings = true;
col_types = {'double', 'double', 'char', 'char', 'char'};
events_table = read_data_from_tsv(events_tsv_filepath, has_headings, [], col_types);

events_json.Columns = events_table;
physio_data_cell{cell_index} =   events_json;

%% Process eye data

end


function json_tsv = add_data2struct(json,tvs) % the name must change!

    %

end