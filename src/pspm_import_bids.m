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

    %% Process each session
    subject = {};
    for j = 1:length(session_dirs)
        session_id = session_dirs(j).name(5:end);  % e.g., '01' or '02'
        
        % Map session ID to task name based on CALINET specification
        % May needs to be 
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

        % --- get physio data ---
        physio_path = fullfile(ses_path,'physio');


        libpath = pspm_path('bids_importer','lib'); % move 
        addpath(libpath); % move 

        [physio_data_cell, recording_duration, physio_info_data] = get_physio_data(subject_full_id, session_id, task_name, physio_path);
        

        % --- Get beh data ---

        beh_path = fullfile(ses_path,'beh');

        [infos]  = get_beh_data(subject_full_id, session_id, task_name, beh_path);
        
        

        % --- Build the channels ---
        % Build event channel
        
        subject{1} = infos;
        subject{1} = physio_data_cell;

        % subject.(session_dirs(j).name).infos = infos;
        % subject.(session_dirs(j).name) = physio_data_cell;

    
    end
    
    % Save participant (cogent) file once per subject
    cogent_file_name = sprintf('%s_cogent.mat', subject_full_id);
    cogent_filepath = fullfile(save_path, cogent_file_name);
    saveCogent(participant, cogent_filepath);
    outfile{end+1} = cogent_file_name;
end
rmpath(libpath); % move 
sts = 1;
end

%% 4. Subfunctions ---------------------------------------------------------
function dataset_description = read_dataset_description(dataset_path)
    dataset_description_filepath = fullfile(dataset_path, 'dataset_description.json');
    dataset_description = jsondecode(fileread(dataset_description_filepath));
end

function fileFound = isFileInDirectory(folderPath, fileName)
    items = dir(folderPath);
    fileFound = any(strcmp({items.name}, fileName));
end

function saveCogent(participantData, cogent_filepath)
    % here the right structure will be build for saving
    subject = participantData;
    save(cogent_filepath, 'subject');
    fprintf('Saved cogent file to %s\n', cogent_filepath);
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


% maybe external function
function [infos] = get_beh_data(subject_id, session_id, task_name, beh_path)
% Construct expected filenames
beh_json_filename    = sprintf('%s_ses-%s_beh.json', subject_id, session_id);
events_json_filename = sprintf('%s_ses-%s_task-%s_events.json', subject_id, session_id, task_name);
events_tsv_filename  = sprintf('%s_ses-%s_task-%s_events.tsv', subject_id, session_id, task_name);

% Full file paths
beh_json_filepath    = fullfile(beh_path, beh_json_filename);
events_json_filepath = fullfile(beh_path, events_json_filename);
events_tsv_filepath  = fullfile(beh_path, events_tsv_filename);

% Check file existence
if ~isfile(beh_json_filepath);    error('Behavior sidecar JSON file not found: %s', beh_json_filepath); end
if ~isfile(events_json_filepath); error('Events JSON file not found: %s', events_json_filepath); end
if ~isfile(events_tsv_filepath);  error('Events TSV file not found: %s', events_tsv_filepath); end

% Read behavioral sidecar JSON file
beh_sidecar = extract_json_as_struct(beh_json_filepath);

% Read events JSON metadata
events_infos = extract_json_as_struct(events_json_filepath);

% Read events TSV data

has_headings = true;
col_types = {'double', 'double', 'char', 'char', 'char'};  
evnets_data = read_data_from_tsv(events_tsv_filepath, has_headings, [], col_types);

infos.beh_sidecar = beh_sidecar;
infos.events.events_infos = events_infos;
infos.events.events_data = evnets_data;


end
