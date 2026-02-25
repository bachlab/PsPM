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
%   Example supported layout (tasks split per session, no 'task' ID, eyetracker data only):
%
%       sub-<sub>/
%       └── ses-01
%           └── beh
%              ├── sub-<sub>_ses-01_events.json
%              ├── sub-<sub>_ses-01_events.tsv
%              ├── sub-<sub>_ses-01_recording-eye1_physio.json
%              ├── sub-<sub>_ses-01_recording-eye1_physio.tsv
%              ├── sub-<sub>_ses-01_recording-eye2_physio.json
%              └── sub-<sub>_ses-01_recording-eye2_physio.tsv
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
%   Written in 2024 by  Sourav Koulkarni,
%                       Dominik R. Bach,
%                       Bernhard A. von Raußendorf (University of Bonn)
%
%   05.12.2025: 
%       - Overall updates on logic and flow
%       - Addded support for multiple tasks within a single session.
%       - Abstracted away some logic in separate functions
%       - Updated handling of 'save_path' argument
%       - Prettify interface
%
%   16.02.2026: 
%       - Update to support BEP020
%           - No specific 'beh'-folder -> events are linked by task/run
%           - tsv.gz files instead of tsv
%           - 
%       - Extra support for run-specific inputs
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
dataset_mode = exist(fullfile(dataset_path, 'dataset_description.json'), 'file') == 2;
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
       
    [~, subject_list(1).name] = fileparts(sub_path); % only one subject
end

% imports dataset description 
dataset_description = read_dataset_description(dataset_path); 

% checks if there are subject
if isempty(subject_list)
    error('ID:nonexistent_folder','No subject folders found.');
end

% output folder (save_path)
if nargin<2 || ~(isstring(save_path) || ischar(save_path))
    % save_path = [dataset_path, filesep, 'out'];
    save_path = fullfile(dataset_path, "out");
    disp(save_path);
    % warning("ID:nonexistent_folder","No or invalid save path specified; using '%s' instead.", save_path);
    warning("ID:nonexistent_folder: No or invalid save path specified; using '%s' instead.", save_path);
end
      
%% Start message
pspm_bids_importer_header(dataset_path, length(subject_list), save_path)
if ~exist(save_path, 'dir')
    mkdir(save_path);
end

nSubjects = 0;
nSessions = 0;
nRuns = 0;
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
        ses_path   = fullfile(sub_path,session_dirs(j).name);

        % eye-tracking files can live in 'beh', 'physio', or any modality they have been acquired in
        % concurrently (e.g., 'func' during fMRI) [BEP020].
        % SCR and other data will live in 'physio' [BEP045]
        eye_search_dirs = { ...
            fullfile(ses_path,'beh'), ...
            fullfile(ses_path,'physio'), ...
            fullfile(ses_path,'func') ...
        };

        % keep only those that exist
        eye_search_dirs = eye_search_dirs(cellfun(@isfolder, eye_search_dirs));

        fprintf('\n--------------------------------------------------------------------------------\n');

        %% Extract task name
        % Look for any event JSON in the beh and physio folders
        task_ids = get_bids_task_ids(eye_search_dirs);
       
        % loop over tasks
        for t = 1:numel(task_ids)

            %% Build file patterns depending on task_id
            task_id = task_ids{t};

            % Detect runs for this task (if any)
            run_ids = get_bids_run_ids( ...
                eye_search_dirs, ...
                subject_full_id, ...
                session_id, ...
                task_id ...
            );
            
            if isempty(run_ids)
                run_ids = {''}; % placeholder: “no run”
                n_runs = 1;
            else
                n_runs = length(run_ids);
            end

            % If none found → process the session once without a task name
            if isempty(task_ids)
                task_ids = {''};   % placeholder for “no task”
                fprintf('Processing %s\n [%d run(s)]', session_dirs(j).name, n_runs);
            else
                task_list_str = strjoin(task_ids, ', ');
                fprintf('Processing %s with %d task(s): %s [%d run(s)]\n', ...
                        session_dirs(j).name, length(task_ids), task_list_str, n_runs);
            end
            
            % loop over runs
            for r = 1:numel(run_ids)

                run_id = run_ids{r};
                
                %% Processing start         
                % read in physio data
                physio_path = fullfile(ses_path, 'physio');
                [~, physio_data, physio_infos] = get_physio_data( ...
                    physio_path, ...
                    subject_full_id, ...
                    session_id, ...
                    task_id, ...
                    run_id ...
                );
                
                % read in eye-tracking data
                [~, physio_eye_data, physio_eye_infos] = get_physio_eye_data( ...
                    eye_search_dirs, ...
                    subject_full_id, ...
                    session_id, ...
                    task_id, ...
                    run_id ...
                );
                
                %% Get events
                % *events file can be in 'beh' or 'physio' folder | prioritize
                % 'beh'
                [events_tsv_filepath, events_json_filepath] = find_bids_file( ...
                    ses_path, ...
                    'events.tsv', ...
                    task_id, ...
                    run_id ...
                );
            
                % read events
                if isfile(events_json_filepath) && isfile(events_tsv_filepath)
                    fprintf('Events:\t%s\n', events_tsv_filepath);
                    marker_chan{1} = get_marker_data( ...
                        events_json_filepath, ...
                        events_tsv_filepath, ...
                        true ...
                    );
                else
                    marker_chan = [ ];
                    warning('ID:nonexistent_file','File not found: %s', events_json_filepath); 
                    warning('ID:nonexistent_file','File not found: %s', events_tsv_filepath);  
                end
    
                % events_json_filepath contains relevant info about stimulus presentation;
                event_json = extract_json_as_struct(events_json_filepath);
                
                %% Build the file structure
                dt = datetime('now'); 
                ses.infos.importdate = sprintf('%.2d.%.2d.%.2d', dt.Day, dt.Month, dt.Year); % same as import_eyelink and importviewpoint; 
        
                % infos.source
                ses.infos.source = physio_eye_infos.source;
                ses.infos.source.file = [physio_infos.source.file; physio_eye_infos.source.file];
                ses.infos.source.type = 'BIDS (json/tsv)'; % physio_infos.infos;
                
                if ~isempty(dataset_description); infos.DatasetDescription = dataset_description; end
                
                % data
                ses.data = {};
                
                % Ensure column cell arrays
                marker_chan      = marker_chan(:);
                physio_data      = physio_data(:);
                physio_eye_data  = physio_eye_data(:);
                
                ses.data = [marker_chan; physio_data; physio_eye_data];
    
                % Calculates the nan_ratio for all channels
                fprintf("Calculate the nan_ratio for all channels\n");
                ses = pspm_update_nan_stats(ses);
    
                % populate fields from json
                fprintf("Adding info from %s to channel headers\n", events_json_filepath);
                fn = fieldnames(event_json);
                for ii = 1:numel(fn)
                    ses.infos.(fn{ii}) = event_json.(fn{ii});
                end
                    
                % Aligns all channels
                fprintf("Aligning all channels in temporal domain\n");
                [asts, ses.data, ses.infos.duration] = align_channels(ses.data);
                if asts ~= 1; continue; end
                
                %% Build output file
                % Save session
                if isempty(task_id) || length(task_ids) == 1
                    ses_filename = sprintf('pspm_%s_ses-%s', subject_full_id, session_id);
                else
                    ses_filename = sprintf('pspm_%s_ses-%s_task-%s', subject_full_id, session_id, task_id);
                end

                if ~isempty(run_id)
                    ses_filename = sprintf('%s_run-%s', ses_filename, run_id);
                end

                ses_filename = sprintf('%s.mat', ses_filename);
                   
                ses_filepath            = fullfile(save_path, ses_filename);
                outfile{end+1}          = char(ses_filepath); 
                ses.infos.importfile    = char(ses_filepath); 
                
                %% Verify output structure
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

            end % close run loop
            nRuns = nRuns + 1;
        end % close task loop
        nSessions = nSessions + 1;
    end % close ses loop
    nSubjects = nSubjects + 1;
end % close subj loop

rmpath(libpath); % What if the function breaks at another path
sts = 1;

%% footer
pspm_bids_importer_footer( ...
    nSubjects, ...
    nSessions, ...
    nRuns, ...
    save_path ...
)
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

function task_ids = get_bids_task_ids(search_dirs)
    task_ids = {};
    for k = 1:numel(search_dirs)
        d = search_dirs{k};
        if ~isfolder(d), continue; end
        
        % grab anything with task-... in the filename (events, eyetrack, physio)
        files = dir(fullfile(d, '*task-*_*.tsv*'));
        names = {files.name};
        for i = 1:numel(names)
            tok = regexp(names{i}, 'task-([A-Za-z0-9]+)', 'tokens', 'once');
            if ~isempty(tok)
                task_ids{end+1} = tok{1}; %#ok<AGROW>
            end
        end
    end
    task_ids = unique(task_ids, 'stable');
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

function pspm_bids_importer_footer(nSubjects, nSessions, nRuns, output_dir)

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

if nargin >= 3 && ~isempty(nRuns)
    fprintf('  Runs processed     : %d\n', nRuns);
end

if nargin >= 4 && ~isempty(output_dir)
    fprintf('  Output directory   : %s\n', output_dir);
end

fprintf('  Finished at        : %s\n', timestamp);
fprintf('================================================================================\n\n');

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

function run_ids = get_bids_run_ids(search_dirs, subject_full_id, session_id, task_id)
% Returns cell array of run strings like {'01','02'} or {} if none.

run_ids = {};

% Build stem up to task (if any)
if isempty(task_id)
    stem = sprintf('%s_ses-%s_', subject_full_id, session_id);
else
    stem = sprintf('%s_ses-%s_task-%s_', subject_full_id, session_id, task_id);
end

for k = 1:numel(search_dirs)
    d = search_dirs{k};
    if ~isfolder(d), continue; end

    % look for any run-XX entity after stem
    files = dir(fullfile(d, [stem 'run-*_*.tsv*']));
    names = {files.name};

    for i = 1:numel(names)
        tok = regexp(names{i}, 'run-([0-9]+)', 'tokens', 'once');
        if ~isempty(tok)
            run_ids{end+1} = tok{1}; %#ok<AGROW>
        end
    end
end

run_ids = unique(run_ids, 'stable');
end
