function [sts, outfile] = pspm_import_bids(dataset_path, save_path)
% ● Description
%   pspm_import_bids reads a BIDS formatted dataset for a set of 
%   participants from a given data path and stores data as PsPM file(s).
% ● Format
%   [sts, outfile] = pspm_import_bids(dataset_path, save_path)
% ● Arguments
%    dataset_path:  path to the data set / subject / session  folder
%       save_path:  path to save the PsPM files / if non mention one level
%                   above dataset_path in the folder out
% ● Output
%         outfile:  cell array of generated PsPM file names
% ● History
%   Introduced in PsPM 7.0
%   Written in 2024 by Sourav Koulkarni & Dominik R Bach & Bernhard A. von Raußendorf (Uni Bonn)

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
if nargin < 2
    save_path = 0;
elseif ~(ischar(save_path) || isstring(save_path)) 
    save_path = 0;
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
if ~save_path 
    save_path = [dataset_path, filesep, 'out'];  
    warning("ID:nonexistent_folder","No or invalid save path specified; using '%s' instead.", save_path);
end 

if ~exist(save_path, 'dir');  mkdir(save_path); end
fprintf('\nImported files will be saved to:  %s\n',save_path);




%% 3. Loop over subjects ---------------------------------------------------
for i = 1:length(subject_list)
   
    subject_full_id = subject_list(i).name;  % e.g., 'sub-CalinetBonn01
    sub_idx_str = regexp(subject_full_id, '\d+$', 'match', 'once');

    
    fprintf('\n------------------------------------------------------------------------------------------------------------------------');
    fprintf('\n------------------------------------------------------------------------------------------------------------------------');
    fprintf('\n\nImporting %s ... \n', subject_full_id);
    
    if dataset_mode 
        % current subject path
        sub_path = fullfile(dataset_path, subject_full_id); 
    end

    if ses_mode  
        [~, session_dirs(1).name] = fileparts(ses_path);
    else % subject mode or dataset_mode
        session_dirs = dir(fullfile(sub_path,'ses-*'));
        session_dirs = session_dirs([session_dirs.isdir]);    
    end 

    % checks if there are sessions
    if isempty(session_dirs); warning('ID:nonexistent_folder','No session folder  (''ses-%s'') found in %s', sub_idx_str ,sub_path); continue; end


    %% Process each session    
    for j = 1:length(session_dirs)
        session_id = session_dirs(j).name(5:end);  % e.g., '01' or '02' (could there be more 100 sessions?)        
        ses_path   = fullfile(sub_path,session_dirs(j).name); % if it is ses_mode it will be overwriten but that is okay
        beh_dir    = fullfile(ses_path,'beh');
        physio_dir = fullfile(ses_path,'physio');


        %% Extract task name
        % Look for any event JSON in the beh and physio folders
        pattern_beh = sprintf('%s_ses-%s_task-*_events.*', subject_full_id, session_id); % both json and tsv
        beh_files = dir(fullfile(beh_dir, pattern_beh));        
        pattern_physio = sprintf('%s_ses-%s_task-*_physioevents.*', subject_full_id, session_id);
        physio_files = dir(fullfile(physio_dir, pattern_physio));
        
        if ~isempty(beh_files) && length(beh_files) == 2
            fname = beh_files(1).name;
        elseif ~isempty(physio_files) && length(physio_files) == 2
            fname = physio_files(1).name;
        else
            warning('ID:nonexistent_file','No BIDS event or physio files for %s session %s', subject_full_id, session_id);
            continue;
        end
        % Extract the token after 'task-' and before the next underscore
        tk = regexp(fname, '_task-([^_]+)_', 'tokens', 'once');
        task_name = tk{1};

        %% Processing start

        fprintf('\n------------------------------------------------------------------------------------------------------------------------');
        fprintf('\n\n  Processing session %s with task %s ...\n\n', session_dirs(j).name, task_name);

        % --- get physio data ---
        physio_path = fullfile(ses_path,'physio');
        [psts, physio_data, physio_infos] = get_physio_data(subject_full_id, session_id, task_name, physio_path);
        [pests, physio_eye_data, physio_eye_infos] = get_physio_eye_data(subject_full_id, session_id, task_name, physio_path);
        
        if psts  < 1; warning('ID:no_import','No physiology data were imported.'); end %
        if pests < 1; warning('ID:no_import','No physiology eye data were imported.'); end %

        %% --- Get beh data ---

        beh_path = fullfile(ses_path,'beh');
        
        % Marker beh channel 
        events_json_filename = sprintf('%s_ses-%s_task-%s_events.json', subject_full_id, session_id, task_name);
        events_tsv_filename  = sprintf('%s_ses-%s_task-%s_events.tsv',  subject_full_id, session_id, task_name);
        events_json_filepath = fullfile(beh_path, events_json_filename);
        events_tsv_filepath  = fullfile(beh_path, events_tsv_filename);
        
       
        if isfile(events_json_filepath) && isfile(events_tsv_filepath)
            marker_chan{1} = get_marker_data(events_json_filepath, events_tsv_filepath, true);
        else
            marker_chan = [ ];
            warning('ID:nonexistent_file','File not found: %s', events_json_filepath); 
            warning('ID:nonexistent_file','File not found: %s', events_tsv_filepath);  
        end

        % get behave json  
        beh_json  = get_beh_json(subject_full_id, session_id, task_name, beh_path);

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
        ses.data = [marker_chan ; physio_data; physio_eye_data]; 
        
        % Calculates the nan_ratio for all channels
        for r = 1:length(ses.data)
            n_data = size(ses.data{r}.data, 1);
            n_inv = sum(isnan(ses.data{r}.data));
            ses.infos.source.chan_stats{r,1} = struct();
            ses.infos.source.chan_stats{r,1}.nan_ratio = n_inv / n_data;
        end


        % Aligns all channels
        [asts, ses.data, ses.infos.duration] = align_channels(ses.data);
        if asts ~= 1; continue; end

        % Save session
        ses_filename = sprintf('pspm_%s_ses-%s.mat', subject_full_id,session_id);
        ses_filepath = fullfile(save_path, ses_filename);
        outfile{end+1} = ses_filepath; 

        ses.infos.importfile = ses_filepath; 
        
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
        fprintf('\n\nSaved cogent file to ''%s''\n', ses_filepath);

    end

end
rmpath(libpath); % What if the function breaks at another path
sts = 1;
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

function [infos] = get_beh_json(subject_id, session_id, task_name, beh_path) 
infos = struct();
beh_json_filename    = sprintf('%s_ses-%s_task-%s_beh.json', subject_id, session_id, task_name);
%beh_json_filename    = sprintf('%s_ses-%s_beh.json', subject_id, session_id);
beh_json_filepath    = fullfile(beh_path, beh_json_filename);

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
[sts, data, new_duration] = pspm_align_channels(data); % can the fprint be turned off?

if sts ~= 1 % if all are the same size does it give en error?
    warning('ID:channel_alignment_failed','Channel alignment failed.');  
    return
end


end

