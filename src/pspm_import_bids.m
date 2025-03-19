function [sts, outfile] = pspm_import_bids(dataset_path, save_path)
% ● Description
%   pspm_import_bids reads a BIDS-PP formatted dataset for a set of 
%   participants from a given data path and stores data as PsPM file(s).
% ● Format
%   [sts, outfile] = pspm_import_bids(dataset_path, save_path)
% ● Arguments
%    dataset_path:  path to the data set
%       save_path:  path to save the PsPM files
% ● Output
%         outfile:  cell array of generated PsPM file names
% ● History
%   Introduced in PsPM 7.0
%   Written in 2024 by Sourav Koulkarni & Dominik R Bach & Bernhard A. von Raußendorf (Uni Bonn)


%% 1. Initialise -----------------------------------------------------------
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
outfile = {};

if ~exist(save_path, 'dir')
    mkdir(save_path);
end

%% 2. Read meta information ------------------------------------------------
dataset_description = read_dataset_description(dataset_path);
[participants_data, participant_data_headings] = read_participants_data(dataset_path);

% Store participant information headings in dataset description
dataset_description.ParticipantInformation = participant_data_headings;

% Get list of subject directories (assumes names start with 'sub-')
dataset_dir = dir(fullfile(dataset_path, 'sub-*'));
dataset_dir = dataset_dir([dataset_dir.isdir]);

%% 3. Loop over subjects ---------------------------------------------------
for i = 1:length(dataset_dir)
    subject_full_id = dataset_dir(i).name;  % e.g., 'sub-CalinetBonn01'
    fprintf('Importing %s ... \n', subject_full_id);

    sub_path = fullfile(dataset_path, subject_full_id);
    
    % Find the corresponding row index in the participants TSV file.
    % Assumes the first column of participants_data contains subject IDs.
    subject_idx = find(strcmp(participants_data{1}, subject_full_id));
    if isempty(subject_idx)
        warning('Subject %s not found in participants file.', subject_full_id);
        continue;
    end

    % Build participant structure by mapping each field.
    participant = struct();
    for p_info_ind = 1:numel(participant_data_headings)
        field_name = participant_data_headings{p_info_ind};
        participant.(field_name) = participants_data{p_info_ind}{subject_idx};
    end

    % Get session directories (names starting with 'ses-')
    subject_contents = dir(sub_path);
    session_dirs = subject_contents(arrayfun(@(x) x.isdir && startsWith(x.name, 'ses-'), subject_contents));

    % Process each session
    for j = 1:length(session_dirs)
        session_id = session_dirs(j).name(5:end);  % e.g., '01' or '02'
        
        % Map session ID to task name based on CALINET specification
        switch session_id
            case '01'
                task_name = 'FearAcquisition';
            case '02'
                task_name = 'FearExtinction';
            otherwise
                task_name = 'UnknownTask';
        end
        
        fprintf('  Processing session %s with task %s...\n', session_dirs(j).name, task_name);
        ses_path = fullfile(sub_path, session_dirs(j).name);
        beh_path = fullfile(sub_path, session_dirs(j).name, 'beh');


        % Build expected filenames based on CALINET naming conventions
        filenames = cell(1, 3);

        
        events_tsv_filename = sprintf('%s_%s_task-%s_events.tsv', subject_full_id, session_dirs(j).name, task_name);
        events_json_filename = sprintf('%s_%s_task-%s_events.json', subject_full_id, session_dirs(j).name, task_name);
        filenames{1} = events_tsv_filename;
        filenames{2} = events_json_filename;
        
        beh_json_filename = sprintf('%s_%s_task-%s_beh.json', subject_full_id, session_dirs(j).name, task_name);
        filenames{3} = beh_json_filename;
        
        % Check if any required file is missing in the session directory
        if checkFileMiss(beh_path, filenames)
            warning('Missing files in %s. Skipping session.', beh_path);
            continue
        end
        
        % --- Handle Data for Session ---
        % Read event data --> event_data_struct
        events_tsv_filepath = fullfile(beh_path, events_tsv_filename);
        [event_data, event_data_headings] = read_event_data(events_tsv_filepath);
        event_data_struct = struct();
        for event_heading_ind = 1:numel(event_data_headings)
            field = event_data_headings{event_heading_ind};
            event_data_struct.(field) = event_data{event_heading_ind};
        end

        % --- Get event infos (json) --- 
   
        events_json_filepath = fullfile(beh_path, events_json_filename);
        event_info_struct = jsondecode(fileread(events_json_filepath));  % change name
        
        % WHAT IS WITH '*_beh.*'

        % --- Get data from physio   ---
        
        physio_path = fullfile(ses_path,'physio');
        libpath = pspm_path('bids_importer','lib'); % move 
        addpath(libpath); % move 

        [physio_data_cell, recording_duration, physio_info_data] = get_physio_data(subject_full_id, session_id, task_name, physio_path);
        
        rmpath(libpath); % move 


        

    
    end
    
    % Save participant (cogent) file once per subject
    cogent_file_name = sprintf('%s_cogent.mat', subject_full_id);
    cogent_filepath = fullfile(save_path, cogent_file_name);
    saveCogent(participant, cogent_filepath);
    outfile{end+1} = cogent_file_name;
end

sts = 1;
end

%% 4. Subfunctions ---------------------------------------------------------

function fileFound = isFileInDirectory(folderPath, fileName)
    items = dir(folderPath);
    fileFound = any(strcmp({items.name}, fileName));
end

function dataset_description = read_dataset_description(dataset_path)
    dataset_description_filepath = fullfile(dataset_path, 'dataset_description.json');
    dataset_description = jsondecode(fileread(dataset_description_filepath));
end

function files_missing = checkFileMiss(folderPath, filenames)
    files_missing = false;
    for i = 1:numel(filenames)
        if ~isFileInDirectory(folderPath, filenames{i})
            fprintf('%s not found in %s\n', filenames{i}, folderPath);
            files_missing = true;
        end
    end
    if ~files_missing
        disp('All required files found in the session directory.')
    end
end

function [participants_data, column_headings] = read_participants_data(dataset_path)
    participants_tsv_filepath = fullfile(dataset_path, 'participants.tsv');
    fileID = fopen(participants_tsv_filepath, 'r');
    header_line = fgetl(fileID);
    column_headings = strsplit(header_line, '\t');
    num_columns = numel(column_headings);
    format_spec = repmat('%s', 1, num_columns);
    participants_data = textscan(fileID, format_spec, 'Delimiter', '\t');
    fclose(fileID);
end

function eyetrack_data = read_eyetrack_data(eyetrack_tsv_filepath)
    % Reads TSV data (assumes numeric data without header line)
    eyetrack_data = readmatrix(eyetrack_tsv_filepath, 'FileType', 'text', 'Delimiter', '\t');
end

function sts = save_eyetrack_data(eyetrack_data, eyetrack_json, event_data_struct, pupil_filepath)
    sts = -1;
    data_columns = eyetrack_json.data.Columns;
    num_channels = length(data_columns) + 1;
    pdata = cell(num_channels, 1);
    
    % Loop over each eyetracking channel defined in the JSON
    for i = 1:length(data_columns)
        chan = struct();
        chan.header = struct();
        chan.header.chan_type = data_columns{i};
        % Note: if the JSON uses "SamplingFrequency" (per CALINET recommendations),
        % adjust the field name accordingly.
        if isfield(eyetrack_json.data.(data_columns{i}), 'SamplingRate')
            chan.header.sr = eyetrack_json.data.(data_columns{i}).SamplingRate;
        elseif isfield(eyetrack_json.data.(data_columns{i}), 'SamplingFrequency')
            chan.header.sr = eyetrack_json.data.(data_columns{i}).SamplingFrequency;
        else
            chan.header.sr = NaN;
        end
        chan.header.units = eyetrack_json.data.(data_columns{i}).Units;
        chan.data = eyetrack_data(:, i);
        pdata{i+1} = chan;
    end
    
    % Build marker channel from event data
    pdata{1} = build_marker_channel(event_data_struct);
    
    data = pdata;
    infos = struct();
    infos.duration = 800;  % TODO: update with actual duration if available
    infos.durationInfo = 'Duration in seconds'; % true?
    infos.source = struct();
    infos.source.elcl_proc = eyetrack_json.ElclProc;
    infos.source.best_eye = eyetrack_json.BestEye;
    infos.source.eyesObservered = eyetrack_json.RecordedEye;
    infos.eyetrackingGeometry = struct();
    infos.eyetrackingGeometry.measurements = eyetrack_json.EyetrackingGeometry.distances;
    infos.eyetrackingGeometry.units = eyetrack_json.EyetrackingGeometry.distanceUnits;
    
    save(pupil_filepath, 'data', 'infos');
    fprintf('Saved processed pupil data to %s\n', pupil_filepath);
    sts = 1;
end

function [event_data, event_data_headings] = read_event_data(event_tsv_filepath)
    fileID = fopen(event_tsv_filepath, 'r');
    header_line = fgetl(fileID);
    event_data_headings = strsplit(header_line, '\t');
    num_columns = numel(event_data_headings);
    format_spec = repmat('%s', 1, num_columns);
    event_data = textscan(fileID, format_spec, 'Delimiter', '\t');
    fclose(fileID);
end

function marker_channel = build_marker_channel(event_data_struct)
    marker_channel = struct();
    time_delta = 3.0;  % TODO: update time delta if needed
    num_events = numel(event_data_struct.onset);
    marker_data = cell(num_events, 1);
    for i = 1:num_events
        marker_data{i} = str2double(event_data_struct.onset{i}) + time_delta;
    end
    marker_channel.data = marker_data;
    
    marker_channel.markerinfo = struct();
    marker_channel.markerinfo.duration = event_data_struct.duration;
    marker_channel.markerinfo.value = event_data_struct.trial_type;
    marker_channel.markerinfo.name = event_data_struct.identifier;
    
    marker_channel.header = struct();
    marker_channel.header.chantype = 'marker';
    marker_channel.header.sr = 1;
    marker_channel.header.units = 'events';
end

function saveCogent(participantData, cogent_filepath)
    subject = participantData;
    save(cogent_filepath, 'subject');
    fprintf('Saved cogent file to %s\n', cogent_filepath);
end
