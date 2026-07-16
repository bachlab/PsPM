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
%       └── ses-<ses>
%           └── physio
%               ├── sub-<subID>_ses-<ses>_task-Acquisition_events.json
%               ├── sub-<subID>_ses-<ses>_task-Acquisition_events.tsv
%               ├── sub-<subID>_ses-<ses>_task-Acquisition_physioevents.json
%               ├── sub-<subID>_ses-<ses>_task-Acquisition_physioevents.tsv.gz
%               ├── sub-<subID>_ses-<ses>_task-Acquisition_recording-ecg_physio.json
%               ├── sub-<subID>_ses-<ses>_task-Acquisition_recording-ecg_physio.tsv.gz
%               ├── sub-<subID>_ses-<ses>_task-Acquisition_recording-eye1_physio.json
%               ├── sub-<subID>_ses-<ses>_task-Acquisition_recording-eye1_physio.tsv.gz
%               ├── sub-<subID>_ses-<ses>_task-Acquisition_recording-eye2_physio.json
%               ├── sub-<subID>_ses-<ses>_task-Acquisition_recording-eye2_physio.tsv.gz
%               ├── sub-<subID>_ses-<ses>_task-Acquisition_recording-scr_physio.json
%               ├── sub-<subID>_ses-<ses>_task-Acquisition_recording-scr_physio.tsv.gz
%               ├── sub-<subID>_ses-<ses>_task-Extinction_... (same pattern)
%               ├── sub-<subID>_ses-<ses>_task-Habituation_... (same pattern)
%
%   Example supported layout (tasks split per session, no 'task' ID, eyetracker data only):
%
%       sub-<sub>/
%       └── ses-01
%           └── beh
%              ├── sub-<subID>_ses-<ses>_events.json
%              ├── sub-<subID>_ses-<ses>_events.tsv
%              ├── sub-<subID>_ses-<ses>_recording-eye1_physio.json
%              ├── sub-<subID>_ses-<ses>_recording-eye1_physio.tsv.gz
%              ├── sub-<subID>_ses-<ses>_recording-eye2_physio.json
%              └── sub-<subID>_ses-<ses>_recording-eye2_physio.tsv.gz
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
%   05.12.2025 (Jurjen Heij): 
%       - Overall updates on logic and flow
%       - Addded support for multiple tasks within a single session.
%       - Abstracted away some logic in separate functions
%       - Updated handling of 'save_path' argument
%       - Prettify interface
%
%   16.02.2026 (Jurjen Heij):
%       - Update to support BEP020
%           - No specific 'beh'-folder -> events are linked by task/run
%           - tsv.gz files instead of tsv
%           - 
%       - Extra support for run-specific inputs
%
%   23.03.2026 (Jurjen Heij): 
%       - Update for BEP045
%       - Assume channels are aligned already, just clip to shortest dura-
%         tion. This avoids the scenario where already-aligned channels are
%         separated in time if the number of samples do not align.
%
%% 1. Initialize
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
nTasks = 0;
nRuns = 0;

%% 3. Loop over subjects
for i = 1:length(subject_list)
   
    subject_full_id = subject_list(i).name;  % e.g., 'sub-CalinetBonn01
    sub_idx_str = regexp(subject_full_id, '\d+$', 'match', 'once');

    fprintf('Importing %s\n', subject_full_id);

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
        
        if isempty(session_dirs)
            % Treat subject folder as a single "session"
            session_dirs = struct('name', '');  % empty name signals no ses level
        end
    end 

    % checks if there are sessions
    if isempty(session_dirs); warning('ID:nonexistent_folder','No session folder  (''ses-%s'') found in %s', sub_idx_str ,sub_path); continue; end

    %% Process each session
    for j = 1:length(session_dirs)

        if isempty(session_dirs(j).name)
            % No session folders → operate directly in subject folder
            session_id = '';  
            ses_path   = sub_path;
        else
            session_id = session_dirs(j).name(5:end);  % e.g., '01'
            ses_path   = fullfile(sub_path, session_dirs(j).name);
        end

        % eye-tracking files can live in 'beh', 'physio', or any modality they have been acquired in
        % concurrently (e.g., 'func' during fMRI) [BEP020].
        % SCR and other data will live in 'physio' [BEP045]
        physio_search_dirs = { ...
            fullfile(ses_path, 'beh'), ...
            fullfile(ses_path, 'physio'), ...
            fullfile(ses_path, 'func') ...
        };

        % keep only those that exist
        physio_search_dirs = physio_search_dirs(cellfun(@isfolder, physio_search_dirs));
        
        fprintf('\n--------------------------------------------------------------------------------\n');

        if isempty(session_id)
            fprintf('Subject-level import (no session folder)\n');
        else
            fprintf('Session: ses-%s\n', session_id);
        end
        %% Extract task name
        % Look for any event JSON in the beh and physio folders
        task_ids = get_bids_task_ids(physio_search_dirs);
       
        if isempty(task_ids)
            task_ids = {''};
        end

        % loop over tasks
        for t = 1:numel(task_ids)

            %% Build file patterns depending on task_id
            task_id = task_ids{t};

            % Detect runs for this task (if any)
            run_ids = get_bids_run_ids( ...
                physio_search_dirs, ...
                subject_full_id, ...
                session_id, ...
                task_id ...
            );
            
            if isempty(run_ids)
                run_ids = {''}; % placeholder: “no run”
            end

            % If none found → process the session once without a task name
            if ~isempty(task_id) % always true!
                fprintf('Task:\t%s\n', task_id);
            end
            % loop over runs
            for r = 1:numel(run_ids)

                run_id = run_ids{r};
                if ~isempty(run_id)
                    fprintf('Run:\trun-%s\n', run_id);
                end

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
                    physio_search_dirs, ...
                    subject_full_id, ...
                    session_id, ...
                    task_id, ...
                    run_id ...
                );

                %% Get events
                % *events.tsv (not *physioevents.tsv.gz) file can be in 'beh' or 'physio' folder | prioritize
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
                    marker_chan = get_marker_data( ...
                        events_json_filepath, ...
                        events_tsv_filepath, ...
                        false ... % it has a column
                    );
                else
                    marker_chan = [ ];
                    warning('ID:nonexistent_file','File not found: %s', events_json_filepath); 
                    warning('ID:nonexistent_file','File not found: %s', events_tsv_filepath);  
                end
    
                % events_json_filepath contains relevant info about stimulus presentation;
                event_json = extract_json_as_struct(events_json_filepath);
                
                evsts = check_stimulus_presentation_fields(event_json);
                if evsts < 1
                    warning('ID:missing_stimulus_presentation', ...
                        ['Required StimulusPresentation fields are missing in:\n%s\n' ...
                        'Please check the events JSON file.'], events_json_filepath );
                    %continue
                end

                %% Build the file structure
                ses = struct();
                dt = datetime('now'); 
                ses.infos.importdate = sprintf('%.2d.%.2d.%.2d', dt.Day, dt.Month, dt.Year); % same as import_eyelink and importviewpoint; 
        
                % infos.source

                ses.infos.source = struct();
                ses.infos.source.type = 'BIDS (json/tsv)';
                ses.infos.source.file = {};
                
                if exist('physio_infos', 'var') && ~isempty(physio_infos) && ...
                        isfield(physio_infos, 'source') && isfield(physio_infos.source, 'file') && ...
                        ~isempty(physio_infos.source.file)
                    ses.infos.source.file = [ses.infos.source.file; physio_infos.source.file];
                end
                
                if exist('physio_eye_infos', 'var') && ~isempty(physio_eye_infos) && ...
                        isfield(physio_eye_infos, 'source') && isfield(physio_eye_infos.source, 'file') && ...
                        ~isempty(physio_eye_infos.source.file)
                    ses.infos.source.file = [ses.infos.source.file; physio_eye_infos.source.file];
                end
                
                % Dataset description if available
                if ~isempty(dataset_description); ses.infos.DatasetDescription = dataset_description; end
                
                % Data
                ses.data = {};
                
                % Ensure column cell arrays
                if ~isempty(marker_chan)
                    marker_chan  = {marker_chan(:)};                    
                end
                
                physio_data      = physio_data(:);
                physio_eye_data  = physio_eye_data(:);
                
                ses.data = [marker_chan; physio_data; physio_eye_data];
    
                % Calculates the nan_ratio for all channels
                fprintf("\nCalculate the nan_ratio for all channels\n");
                ses = pspm_update_nan_stats(ses);
    
                % populate fields from json
                fprintf("Adding info from %s to channel headers\n", events_json_filepath);
                fn = fieldnames(event_json);
                for ii = 1:numel(fn)
                    ses.infos.(fn{ii}) = event_json.(fn{ii});
                end
                    
                % % Aligns all channels
                % fprintf("Clip to shortest duration\n");
                % [asts, ses.data, duration] = pspm_clip_channels_to_shortest(ses.data); % needs the duration!

                [asts, ses.data, duration] = align_channels(ses.data);
                if asts ~= 1; continue; end

                fprintf("New duration: %.2f seconds\n", duration);
                ses.infos.duration = duration;

                %% Build output file
                parts = {sprintf('pspm_%s', char(subject_full_id))};
                
                if ~isempty(session_id)
                    parts{end+1} = sprintf('ses-%s', char(session_id)); %#ok<AGROW>
                end
                
                if ~isempty(task_id) && numel(task_ids) > 1
                    parts{end+1} = sprintf('task-%s', char(task_id)); %#ok<AGROW>
                end
                
                if ~isempty(run_id) && numel(run_ids) > 1
                    parts{end+1} = sprintf('run-%s', run_id); %#ok<AGROW>
                end
                
                ses_filename = [strjoin(parts, '_') '.mat'];
                                   
                ses_filepath            = fullfile(save_path, ses_filename);
                outfile{end+1}          = char(ses_filepath); %#ok<AGROW>
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
                fprintf('Saved PsPM-file to ''%s''\n', ses_filepath);
                fprintf('\n--------------------------------------------------------------------------------\n');

                nRuns = nRuns + 1;
                
            end % close run loop
            nTasks = nTasks + 1;
        end % close task loop
        nSessions = nSessions + 1;
    end % close ses loop
    nSubjects = nSubjects + 1;
end % close subj loop

rmpath(libpath); 
sts = 1;

%% footer
pspm_bids_importer_footer( ...
    nSubjects, ...
    nSessions, ...
    nRuns, ...
    nTasks, ...
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
function [participants_data, column_headings] = read_participants_data(dataset_path) % not used?
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


function [sts, data, duration] = pspm_clip_channels_to_shortest(data, induration)
% Clip continuous channels to the shortest common duration.
% Optionally also clip to induration if provided (>0).

    sts = -1;

    if nargin < 2 || isempty(induration)
        induration = 0;
    end

    if ~(isnumeric(induration) && isscalar(induration))
        warning('ID:invalid_input', 'induration must be a numeric scalar');
        duration = [];
        return
    end

    n = numel(data);
    is_event = false(1, n);
    durations = nan(1, n);

    for k = 1:n
        units = "";
        if isfield(data{k}, 'header') && isfield(data{k}.header, 'units') && ~isempty(data{k}.header.units)
            units = string(data{k}.header.units);
        end

        is_event(k) = strcmpi(units, "events");

        if is_event(k)
            % event channels do not define the target duration
            durations(k) = NaN;
        else
            if ~isfield(data{k}.header, 'sr') || isempty(data{k}.header.sr) || data{k}.header.sr <= 0
                warning('Channel %d (%s) has invalid sampling rate.', k, data{k}.header.chantype);
                duration = [];
                return
            end
            durations(k) = numel(data{k}.data) / double(data{k}.header.sr);
        end
    end

    cont_durations = durations(~isnan(durations));
    if isempty(cont_durations)
        warning('No continuous channels found.');
        duration = [];
        return
    end

    duration = min(cont_durations);
    if induration > 0
        duration = min(duration, induration);
    end

    for k = 1:n
        if is_event(k)
            if ~isempty(data{k}.data)
                data{k}.data = data{k}.data(data{k}.data <= duration);
            end
        else
            sr = double(data{k}.header.sr);
            n_keep = floor(duration * sr);
            n_keep = min(n_keep, numel(data{k}.data));
    
            data{k}.data = data{k}.data(1:n_keep);
    
            % update header
            data{k}.header.duration = duration;
            data{k}.header.nsamples = n_keep;
            data{k}.header.StartTime = 0;
        end
    end

    sts = 1;
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
try
    pspm_ver = string(pspm_version);
catch
    pspm_ver = "unknown";
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


function pspm_bids_importer_footer(nSubjects, nSessions, nRuns, nTasks, output_dir)

timestamp = string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
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

if nargin >= 4 && ~isempty(nTasks)
    fprintf('  Tasks processed    : %d\n', nTasks);
end

if nargin >= 5 && ~isempty(output_dir)
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
%
% Works for both:
%   sub-01/ses-01/physio/sub-01_ses-01_task-X_run-01_*.tsv*
%   sub-01/physio/sub-01_task-X_run-01_*.tsv*
%
% Also supports missing task_id:
%   sub-01_run-01_*.tsv*
%   sub-01_ses-01_run-01_*.tsv*

run_ids = {};
entities = {char(subject_full_id)};

if ~isempty(session_id)
    entities{end+1} = sprintf('ses-%s', char(session_id)); %#ok<AGROW>
end

if ~isempty(task_id)
    entities{end+1} = sprintf('task-%s', char(task_id)); %#ok<AGROW>
end

stem = [strjoin(entities, '_') '_'];

for k = 1:numel(search_dirs)
    d = search_dirs{k};
    if ~isfolder(d), continue; end

    % Look for any run-XX entity after the subject/session/task stem
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
            warning('ID:non_existent_field','Channel %d is missing sampling rate (sr) in its header. This will lead to probelms later.', i);
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
[sts, data, new_duration] = pspm_align_channels(data); 

if sts ~= 1 % if all are the same size does it give en error?
    warning('ID:channel_alignment_failed','Channel alignment failed.');  
    return
end


end


