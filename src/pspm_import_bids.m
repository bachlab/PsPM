function [sts, outfile] = pspm_import_bids(dataset_path, save_path)
% ● Description
%   pspm_import_bids reads a BIDS-formatted dataset (BEP020/BEP045) containing
%   physiology and/or eye-tracking recordings for one or more participants.
%   The function detects available tasks, sessions, and modalities, imports
%   all BIDS-compliant JSON/TSV files, and stores the result as PsPM .mat files.
%
%   The importer supports datasets with:
%     • multiple tasks per session (e.g., Acquisition, Extinction, Habituation)
%     • separate beh/ and physio/ folders
%     • optional task- entities (task-<name>) in filenames
%     • sessions with or without behavioral events
%
%   Example supported layout (multi-task session, no 'beh' folder):
%
%       sub-<subID>/
%       └── <ses>
%           └── physio
%               ├── sub-<subID>_<ses>_task-Acquisition_events.json
%               ├── sub-<subID>_<ses>_task-Acquisition_events.tsv
%               ├── sub-<subID>_<ses>_task-Acquisition_physioevents.json
%               ├── sub-<subID>_<ses>_task-Acquisition_physioevents.tsv
%               ├── sub-<subID>_<ses>_task-Acquisition_recording-ecg_physio.json
%               ├── sub-<subID>_<ses>_task-Acquisition_recording-ecg_physio.tsv
%               ├── sub-<subID>_<ses>_task-Acquisition_recording-eye1_physio.json
%               ├── sub-<subID>_<ses>_task-Acquisition_recording-eye1_physio.tsv
%               ├── sub-<subID>_<ses>_task-Acquisition_recording-eye2_physio.json
%               ├── sub-<subID>_<ses>_task-Acquisition_recording-eye2_physio.tsv
%               ├── sub-<subID>_<ses>_task-Acquisition_recording-scr_physio.json
%               ├── sub-<subID>_<ses>_task-Acquisition_recording-scr_physio.tsv
%               ├── sub-<subID>_<ses>_task-Extinction_... (same pattern)
%               ├── sub-<subID>_<ses>_task-Habituation_... (same pattern)
%
%   Example supported layout (tasks split per session, no 'task' ID):
%
%       sub-<sub>/
%       ├── ses-01
%       │   ├── beh
%       │   │   ├── sub-<sub>_ses-01_beh.json
%       │   │   ├── sub-<sub>_ses-01_events.json
%       │   │   └── sub-<sub>_ses-01_events.tsv
%       │   └── physio
%       │       ├── sub-<sub>_ses-01_recording-ecg_physio.json
%       │       ├── sub-<sub>_ses-01_recording-ecg_physio.tsv
%       │       ├── sub-<sub>_ses-01_recording-eye1_physio.json
%       │       ├── sub-<sub>_ses-01_recording-eye1_physio.tsv
%       │       ├── sub-<sub>_ses-01_recording-eye2_physio.json
%       │       ├── sub-<sub>_ses-01_recording-eye2_physio.tsv
%       │       ├── sub-<sub>_ses-01_recording-ppg_physio.json
%       │       ├── sub-<sub>_ses-01_recording-ppg_physio.tsv
%       │       ├── sub-<sub>_ses-01_recording-scr_physio.json
%       │       └── sub-<sub>_ses-01_recording-scr_physio.tsv
%       └── ses-02
%           ├── beh
%           └── physio
%
% ● Format
%   [sts, outfile] = pspm_import_bids(dataset_path, save_path)
%
% ● Arguments
%       dataset_path:  path to the dataset, subject, or session folder
%          save_path:  path where PsPM .mat files will be written.
%                      If omitted, files are stored in ./out one level
%                      above dataset_path.
%
% ● Output
%            outfile:  cell array of full paths to generated PsPM .mat files
%                sts:  status flag (1 = success, 0 = failure)
%
% ● History
%   Introduced in PsPM 7.0
%   Written in 2024 by Sourav Koulkarni,
%                    Dominik R. Bach,
%                    Bernhard A. von Raußendorf (University of Bonn)
%
%   05.12.2025: 
%       - Overall updates on logic and flow
%       - Addded support for multiple tasks within a single session.
%       - Abstracted away some logic in separate functions
%       - Updated handling of 'save_path' argument
%       - Prettify interface
%
%% 1. Initialize -----------------------------------------------------------
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;  
outfile = {};
dataset_description = struct();

% checks inputs
% check data set path
if ~(ischar(dataset_path) || isstring(dataset_path))
    error('ID:invalid_input', 'dataset_path must be a string.');
elseif ~exist(dataset_path, 'dir')
    error('ID:invalid_input','dataset_path has to be a folder'); 
end

if nargin > 2;  warning('More than two inputs have been provided; any additional inputs will be ignored.' ); end   


% Adds libs to the path
libpath = pspm_path('bids_importer','lib');
addpath(libpath); 


%% 2. Read meta information & Add paths to the right variables ------------------------------------------------

[~, currentFolder] = fileparts(dataset_path); 
% so that path can end with "/" e.g. /home/
if isempty(currentFolder)
    dataset_path = dataset_path(1:end-1);
    [~, currentFolder] = fileparts(dataset_path); 
end

% checks if what needs to be imported
dataset_mode = ~(startsWith(currentFolder, 'sub-') || startsWith(currentFolder, 'ses-')); 
ses_mode = startsWith(currentFolder, 'ses-');  
sub_mode = startsWith(currentFolder, 'sub-');  

% dataset mode
if dataset_mode
    % Get list of subject directories (assumes names start with 'sub-')
    subject_list = dir(fullfile(dataset_path, 'sub-*'));
    subject_list = subject_list([subject_list.isdir]);

% sub or ses to be imported 
else
   % subject or session mode
    if ses_mode
        sub_path = fileparts(dataset_path); % one level above ses-*
        ses_path = dataset_path;
    elseif sub_mode 
        sub_path = dataset_path; 
    end

    % dataset_path now becomes the real dataset path 
    dataset_path = fileparts(sub_path); 
  
    % imports dataset description 
    dataset_description = read_dataset_description(dataset_path); 
       
    [~, subject_list(1).name] = fileparts(sub_path); % only one subject
end

% checks if there are subject
if isempty(subject_list)
    error('ID:nonexistent_folder','No subject folders found.');
end

% output folder (save_path)
if ~isstring(save_path) 
    % save_path = [dataset_path, filesep, 'out'];
    save_path = fullfile(dataset_path, "out");
    disp(save_path);
    % warning("ID:nonexistent_folder","No or invalid save path specified; using '%s' instead.", save_path);
    warning(sprintf("ID:nonexistent_folder: No or invalid save path specified; using '%s' instead.", save_path));
end
      
%% Start message
pspm_bids_importer_header(dataset_path, length(subject_list), save_path)
if ~exist(save_path, 'dir')
    mkdir(save_path);
end

nSubjects = 0;
nSessions = 0;
%% 3. Loop over subjects ---------------------------------------------------
for i = 1:length(subject_list)
   
    subject_full_id = subject_list(i).name;  % e.g., 'sub-CalinetBonn01
    sub_idx_str = regexp(subject_full_id, '\d+$', 'match', 'once');

    fprintf('Importing %s ... \n', subject_full_id);
    
    if dataset_mode 
        % current subject path
        sub_path = fullfile(dataset_path, subject_full_id); 
    end

    if ses_mode  
        [~, session_dirs(1).name] = fileparts(ses_path);
    else % subject mode or dataset_mode
        session_dirs = dir(fullfile(sub_path,'ses-*'));
        session_dirs = session_dirs([session_dirs.isdir]);
        session_dirs = session_dirs(~ismember({session_dirs.name}, {'.','..'}));
    end 

    % checks if there are sessions
    if isempty(session_dirs); warning('ID:nonexistent_folder','No session folder  (''ses-%s'') found in %s', sub_idx_str ,sub_path); continue; end


    %% Process each session
    for j = 1:length(session_dirs)
        session_id = session_dirs(j).name(5:end);  % e.g., '01' or '02' (could there be more 100 sessions?)        
        ses_path   = fullfile(sub_path,session_dirs(j).name); % if it is ses_mode it will be overwriten but that is okay
        physio_dir = fullfile(ses_path, 'physio');
        
        fprintf('\n--------------------------------------------------------------------------------\n');

        %% Extract task name
        % Look for any event JSON in the beh and physio folders
        task_ids = get_bids_task_ids(physio_dir);
        
        % If none found → process the session once without a task name
        if isempty(task_ids)
            task_ids = {''};   % placeholder for “no task”
            fprintf('Processing %s\n', session_dirs(j).name);
        else
            task_list_str = strjoin(task_ids, ', ');
            fprintf('Processing %s with %d task(s): %s\n', ...
                    session_dirs(j).name, length(task_ids), task_list_str);
        end

        % loop over tasks
        for t = 1:numel(task_ids)

            %% Build file patterns depending on task_name
            task_name = task_ids{t};
            if isempty(task_name)
                fprintf("\nReading data\n");
                beh_base = sprintf('%s_ses-%s_', subject_full_id, session_id);
            else
                fprintf("\nReading data from task-%s\n", task_name);
                beh_base = sprintf('%s_ses-%s_task-%s_', subject_full_id, session_id, task_name);
            end            
            %% Processing start         
            % read in data
            physio_path                             = fullfile(ses_path, 'physio');
            [~, physio_data, physio_infos]          = get_physio_data(subject_full_id, session_id, task_name, physio_path);
            [~, physio_eye_data, physio_eye_infos]  = get_physio_eye_data(subject_full_id, session_id, task_name, physio_path);
            
            %% Get beh data ---    
            % *events file can be in 'beh' or 'physio' folder | prioritize
            % 'beh'
            [events_json_filepath, events_tsv_filepath, beh_json_filepath, ~, ~] = bids_find_events(ses_path, beh_base, task_name);
            
            if isfile(events_json_filepath) && isfile(events_tsv_filepath)
                marker_chan{1} = get_marker_data(events_json_filepath, events_tsv_filepath, true);
            else
                marker_chan = [ ];
                warning('ID:nonexistent_file','File not found: %s', events_json_filepath); 
                warning('ID:nonexistent_file','File not found: %s', events_tsv_filepath);  
            end

            % beh-file contains relevant info about stimulus presentation;
            % required for eye-data 
            if ~isfile(beh_json_filepath)
                beh_json_filepath = events_json_filepath;
                warning('ID:nonexistent_file','File not found: %s. Attempting to use %s, but may result in issues downstream', beh_json_filepath, events_json_filepath); 
            end            
    
            % get behave json  
            beh_json = get_beh_json(beh_json_filepath);
    
            %% --- Build the file structure  ---
            % Build sessions infos
           
    
            % ses.infos.duration - will be added after alignment
    
            % infos.importfile - will be added before saving
            dt = datetime('now'); 
            ses.infos.importdate = sprintf('%.2d.%.2d.%.2d', dt.Day, dt.Month, dt.Year); % same as import_eyelink and importviewpoint; 
            % durationinfo = 'Recording duration in seconds';
            % ses.infos.recdate - no information;
            % ses.infos.rectime - no information;
    
            % infos.source
            % ses.infos.source = struct();
            ses.infos.source = physio_eye_infos.source;
            ses.infos.source.file = [physio_infos.source.file; physio_eye_infos.source.file];
            ses.infos.source.type = 'BIDS (json/tsv)'; % physio_infos.infos;
            % ses.infos.source.chan_stats - will be calculted later
    
            if ~isempty(dataset_description); infos.DatasetDescription = dataset_description; end
            % if ~isempty(fieldnames(currentParticipant)); infos.Participant = currentParticipant; end
    
            % data
            ses.data = {};
            ses.data = [marker_chan; physio_data; physio_eye_data]; 
            
            % Calculates the nan_ratio for all channels
            fprintf("Calculate the nan_ratio for all channels\n");
            ses = pspm_update_nan_stats(ses);

            % populate fields from json
            fprintf("Adding info from %s to channel headers\n", events_json_filepath);
            fn = fieldnames(beh_json);
            for ii = 1:numel(fn)
                ses.infos.(fn{ii}) = beh_json.(fn{ii});
            end
    
            % Aligns all channels
            [asts, ses.data, ses.infos.duration] = align_channels(ses.data);
            if asts ~= 1; continue; end
            
            % Save session
            if isempty(task_name) || length(task_ids) == 1
                ses_filename = sprintf('pspm_%s_ses-%s.mat', subject_full_id, session_id);
            else
                ses_filename = sprintf('pspm_%s_ses-%s_task-%s.mat', subject_full_id, session_id, task_name);
            end
    
            ses_filepath            = fullfile(save_path, ses_filename);
            outfile{end+1}          = ses_filepath; 
            ses.infos.importfile    = ses_filepath; 
    
            % Check the pspm structure
            [lsts, ~, ~, ~] = pspm_load_data(ses);
            if lsts < 1
                warning('ID:could_not_be_saved','The file struture has a problem'); % better warning text
                continue; 
            end
    
            %  saves as pspm file (overwrite)
            data  = ses.data;
            infos = ses.infos;
            save(ses_filepath,'infos', 'data');
            fprintf('\nSaved PsPM-file to ''%s''\n', ses_filepath);

        end % close task loop
        nSessions = nSessions + 1;
    end % close ses loop
    nSubjects = nSubjects + 1;
end % close subj loop

rmpath(libpath); % What if the function breaks at another path
sts = 1;

%% footer
pspm_bids_importer_footer(nSubjects, nSessions, save_path)
end

%% 4. Sub-functions ---------------------------------------------------------

function dataset_description = read_dataset_description(dataset_path)
% returns [] if dataset_description.json does not exist
    dataset_description_filepath = fullfile(dataset_path, 'dataset_description.json');

    if ~exist(dataset_description_filepath, 'file')
        warning("ID:non_existent_file","'dataset_description.json' is missing in folder: %s", dataset_path);
        dataset_description = [];
        return;
    end

    % Read and decode the JSON file
    try
        dataset_description = jsondecode(fileread(dataset_description_filepath));
    catch ME
        warning('ID:non_existent_file', ...
            'Failed to read or parse dataset_description.json: %s', ME.message);
        dataset_description = [];
    end
end

% Could be implemented in the future  
function [participants_data, column_headings] = read_participants_data(dataset_path)
    % Imports the participant data from participants.tsv (independent the participiants.json)   
    participants_data = {};
    column_headings = {};
    participants_tsv_filepath = fullfile(dataset_path, 'participants.tsv');
    
    if exist(participants_tsv_filepath,'file')
        fileID = fopen(participants_tsv_filepath, 'r');
        header_line = fgetl(fileID);
        column_headings = strsplit(header_line, '\t');
        num_columns = numel(column_headings);
        format_spec = repmat('%s', 1, num_columns);
        participants_data = textscan(fileID, format_spec, 'Delimiter', '\t');
        fclose(fileID);
    end
end

function [infos] = get_beh_json(beh_json_filepath) 

infos = struct();
if ~isfile(beh_json_filepath) 
    warning('ID:non_existent_file','Behavior sidecar JSON file not found: %s', beh_json_filepath); 
    return
else
    infos = extract_json_as_struct(beh_json_filepath);
end
end

function [sts, data, new_duration] = align_channels(data)
sts = -1;
num_channels = length(data); % the marker channels have to be taken away
startTimes = zeros(num_channels,1);

% Determine start time for each channel (assume 0 if missing)
for i = 1:num_channels
    if isfield(data{i}.header, 'StartTime')
        startTimes(i) = data{i}.header.StartTime; %  assuming seconds
    else
        startTimes(i) = 0;
        data{i}.header.StartTime = 0;
    end
end

global_min = min(startTimes(~isnan(startTimes))); % excludes marker
finalLengths = zeros(num_channels,1);

for i = 1:num_channels        
    shift_sec = data{i}.header.StartTime - global_min;

    % Check if this channel is an event channel.
    if isfield(data{i}, 'markerinfo')
        data{i}.data = data{i}.data - global_min; 
        data{i}.header.StartTime = data{i}.data(1); 
    else
        if ~isfield(data{i}.header, 'sr')
            warning('ID:non_existent_field','Channel %d is missing sampling rate (sr) in its header. This will lead to problems later.', i);
            continue;
        end
        sr = data{i}.header.sr;
        numPad = round(shift_sec * sr);

        % Prepadded zeros to the data vector. 
        data{i}.data = [zeros(numPad, 1); data{i}.data];

        % Record the new length.
        finalLengths(i) = length(data{i}.data)/sr;
        data{i}.header.StartTime = 0;
    end    
end

% Padding at the end
[sts, data, new_duration] = pspm_align_channels(data); % can the fprint be turned off?
if sts ~= 1 % if all are the same size does it give en error?
    warning('ID:channel_alignment_failed','Channel alignment failed.');  
    return
end

end

function task_ids = get_bids_task_ids(physio_dir)

    files = dir(fullfile(physio_dir, '*.json'));   % look at metadata files
    task_ids = {};

    % regexp pattern for `_task-<taskid>`
    expr = '(?<=_task-)[a-zA-Z0-9]+';

    for i = 1:numel(files)
        tokens = regexp(files(i).name, expr, 'match');
        if ~isempty(tokens)
            task_ids{end+1} = tokens{1};
        end
    end

    % return uniques (preserve order)
    if ~isempty(task_ids)
        task_ids = unique(task_ids, 'stable');
    end
end

function pspm_bids_importer_header(dataset_path, nSubjects, save_path)

% Detect PsPM version if available
pspm_ver = "unknown";
try
    pspm_ver = string(pspm_version);
end

timestamp = string(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));

fprintf('\n');
fprintf('================================================================================\n');
fprintf('  PsPM BIDS Importer\n');
fprintf('--------------------------------------------------------------------------------\n');
fprintf('  Version     : %s\n', pspm_ver);
fprintf('  Started     : %s\n', timestamp);
fprintf('  Description : Import BIDS-compliant (BEP020/BEP045) eye tracking & physiology\n');
fprintf('                data into PsPM format.\n');
fprintf('  BIDS path   : %s\n', dataset_path);
fprintf('  Output path : %s\n', save_path);
fprintf('  N subjects  : %d\n', nSubjects);
fprintf('================================================================================\n\n');

end

function pspm_bids_importer_footer(nSubjects, nSessions, output_dir)

timestamp = string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
fprintf('\n');
fprintf('================================================================================\n');
fprintf('  BIDS Import Completed Successfully\n');
fprintf('--------------------------------------------------------------------------------\n');

if nargin >= 1 && ~isempty(nSubjects)
    fprintf('  Subjects processed : %d\n', nSubjects);
end

if nargin >= 2 && ~isempty(nSessions)
    fprintf('  Sessions processed : %d\n', nSessions);
end

if nargin >= 3 && ~isempty(output_dir)
    fprintf('  Output directory   : %s\n', output_dir);
end

fprintf('  Finished at        : %s\n', timestamp);
fprintf('================================================================================\n\n');

end

function [json_path, tsv_path, beh_path, source_dir, status] = bids_find_events(ses_path, beh_base, task_name)
% BIDS_FIND_EVENTS  Locate behavioral/physio event files for a PsPM session.
%
%   [json_path, tsv_path, beh_path, source_dir, status] = bids_find_events(ses_path, beh_base, task_name)
%
%   - Searches in priority order:  "beh" → "physio"
%   - beh_base is the filename prefix (including task- if applicable)
%   - task_name may be '' for sessions without tasks
%
%   Returns:
%      json_path   Full path to events.json
%      tsv_path    Full path to events.tsv
%      beh_path    Full path to beh.json
%      source_dir  Directory used ('beh' or 'physio')
%      status      1 if found, 0 otherwise

    json_path  = "";
    tsv_path   = "";
    beh_path   = "";
    source_dir = "";
    status     = 0;

    event_dirs = ["beh", "physio"];  % priority order

    for d = event_dirs
        candidate_dir = fullfile(ses_path, d);

        % Build patterns
        pattern_json = beh_base + "events.json";
        pattern_tsv  = beh_base + "events.tsv";
        pattern_beh  = beh_base + "beh.json";

        % Search using dir()
        json_files = dir(fullfile(candidate_dir, pattern_json));
        tsv_files  = dir(fullfile(candidate_dir, pattern_tsv));
        beh_files  = dir(fullfile(candidate_dir, pattern_beh));

        if ~isempty(json_files) && ~isempty(tsv_files)
            % Found matching pair
            json_path  = fullfile(candidate_dir, json_files(1).name);
            tsv_path   = fullfile(candidate_dir, tsv_files(1).name);
            source_dir = d;
            status     = 1;
        end

        if ~isempty(beh_files)
            % Found matching pair
            beh_path = fullfile(candidate_dir, beh_files(1).name);
        end
        return;
    end

    % No match found
    if isempty(task_name)
        warning('No event files found in %s (no task).', ses_path);
    else
        warning('No event files found for task "%s" in %s.', task_name, ses_path);
    end

end

function ses = pspm_update_nan_stats(ses)
% PSPM_UPDATE_NAN_STATS
%   Computes NaN ratios for each channel in ses.data
%   and inserts them into ses.infos.source.chan_stats.
%
%   INPUT:
%       ses : PsPM session struct with fields:
%               - ses.data   (cell array of channel structs)
%               - ses.infos.source (struct)
%
%   OUTPUT:
%       ses : same struct, but with:
%               ses.infos.source.chan_stats  updated

    data_cells = ses.data;
    nChannels = numel(data_cells);

    chan_stats = cell(nChannels, 1);

    for r = 1:nChannels
        chan = data_cells{r}.data;

        if isnumeric(chan)
            % Numeric channel → compute NaN ratio
            n_data = numel(chan);
            n_inv  = sum(isnan(chan), 'all'); % count all NaNs
            nan_ratio = n_inv / n_data;
        else
            % Non-numeric channel (e.g., event markers) → no NaN concept
            nan_ratio = NaN;
        end

        chan_stats{r} = struct( ...
            'nan_ratio', nan_ratio ...
        );
    end

    % Insert into ses
    ses.infos.source.chan_stats = chan_stats;
end

