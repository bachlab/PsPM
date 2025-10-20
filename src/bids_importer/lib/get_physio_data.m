function [sts , physio_data, physio_infos] = get_physio_data(subject_id, session_id, task_name, physio_path)
% Returns a  cell array where each cell contains a struct with fields header and data (and markerinfo for events)
% Also returns physio_info_data needed to create 'info' struct
% UPDATE HELPTEXT

%% Initialize the physio data cell array
sts = -1;
physio_data = {}; 
physio_infos = {};

physio_signals = {'ecg','ppg', 'scr'};
num_signals = length(physio_signals);

% Initialize variables for infos

chan_names = {}; 
file_paths = {}; 

% Index to keep track of the cell array
cell_index = 1;


%% Process each physio signal
for i = 1:num_signals   

    signal = physio_signals{i};
    
    % Construct filenames
    physio_json_filename = sprintf('%s_ses-%s_recording-%s_physio.json', subject_id, session_id, signal);
    physio_tsv_filename  = sprintf('%s_ses-%s_recording-%s_physio.tsv', subject_id, session_id, signal);

    physio_json_filepath = fullfile(physio_path, physio_json_filename);
    physio_tsv_filepath  = fullfile(physio_path, physio_tsv_filename);



    % Check if files exist  
    % The warning could be confusing 
    if ~isfile(physio_json_filepath); warning('File not found: %s', physio_json_filepath);continue; end
    if ~isfile(physio_tsv_filepath);  warning('File not found: %s', physio_tsv_filepath); continue; end
    

    
    % Collect file paths for infos
    file_paths{cell_index,1} = {physio_json_filepath,physio_tsv_filepath};

    % Read JSON metadata
    physio_json = extract_json_as_struct(physio_json_filepath);

    % Read TSV data
    headings = physio_json.Columns;  
    col_types = repmat({'double'}, 1, length(headings));
    physio_data_table = read_data_from_tsv(physio_tsv_filepath, false, headings.', col_types);
    

 
    % Create channel struct
    chaninfo = physio_json; % add the json to the infos field
    chaninfo = rmfield(chaninfo,'Columns'); % removes Columns field
    chan = struct();
    % header chantype, sr, StartTime and units
    chan.header = struct();
    chan.header.chantype = signal;
    chan.header.sr = physio_json.SamplingFrequency; 
    chan.header.StartTime = physio_json.StartTime; 
   


    % Access Units field inside the signal-specific structure
    if isfield(physio_json, signal) && isfield(physio_json.(signal), 'Units') ; chan.header.units = physio_json.(signal).Units;
    else; chan.header.units = 'unknown'; warning('Units not specified in JSON file for %s. Setting units to "unknown".', signal); 
    end 

    % Assign data
    chan.data = physio_data_table.(headings{1});

    % Add to physio data cell array 
    physio_data{cell_index,1} = chan;

    % index
    cell_index = cell_index +1;
end


end
