function [sts , physio_data, infos] = get_physio_data(physio_path, subject_id, session_id, task_id, run_id)
% Returns a  cell array where each cell contains a struct with fields header and data (and markerinfo for events)
% Also returns physio_info_data needed to create 'info' struct
% UPDATE HELPTEXT

%% Initialize the physio data cell array
sts                 = -1;
physio_data         = {}; 
file_paths          = {}; 
infos.source.file   = {};
physio_signals      = {'ecg', 'ppg', 'scr'};
num_signals         = length(physio_signals);


% Index to keep track of the cell array
cell_index = 1;
%% Process each physio signal
for i = 1:num_signals   

    signal = physio_signals{i};

    % find modality-specific physio file
    [physio_tsv_filepath, physio_json_filepath] = find_physio_file( ...
        physio_path, ...
        signal, ...
        task_id, ...
        run_id ...
    );
    
    %% Check if files exist  
    % The warning could be confusing 
    if ~isfile(physio_json_filepath) || ~isfile(physio_tsv_filepath)
        continue; 
    end

    fprintf('%s:\t%s\n', signal, physio_tsv_filepath);
    %% Collect file paths for infos
    file_paths{cell_index,1} = {physio_json_filepath,physio_tsv_filepath};

    % Read JSON metadata
    physio_json = extract_json_as_struct(physio_json_filepath);

    % Read TSV data
    headings = physio_json.Columns;  
    col_types = repmat({'double'}, 1, length(headings));
    physio_data_table = read_data_from_tsv( ...
        physio_tsv_filepath, ...
        false, ...
        headings.', ...
        col_types ...
    );
    
    % Create channel struct

    chan = struct();
    chan.header = struct();
    chan.header.chantype = signal;
    chan.header.sr = physio_json.SamplingFrequency; 
    chan.header.StartTime = physio_json.StartTime; 

    % Access Units field inside the signal-specific structure
    if isfield(physio_json, signal) && isfield(physio_json.(signal), 'Units')  
        chan.header.units = physio_json.(signal).Units;
    else 
        chan.header.units = 'unknown'; 
        warning('Units not specified in JSON file for %s. Setting units to "unknown".', signal); 
    end 

    % Assign data
    chan.data = physio_data_table.(headings{strcmp(headings, signal)});

    % Add to physio data cell array 
    physio_data{cell_index,1} = chan; %#ok<*AGROW> 

    % index
    cell_index = cell_index +1;
end

if isempty(physio_data)
    fprintf(">No physio data ('ecg','ppg','scr') were imported for %s, ses-%s.\n", subject_id, session_id);
    return
end

infos.source.file = file_paths;
sts = 1;

end
