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


% checks inputs



if ~(ischar(dataset_path) || isstring(dataset_path))
    error('InvalidInput', 'dataset_path must be a string.');
end
if exist('save_path','var') && ~(ischar(save_path) || isstring(save_path)) || nargin < 2
    warnign('pspm_import_bids:InvalidInput', 'save_path must be a character vector or string.');
    parentDir = fileparts(dataset_path);
    save_path = fullfile(parentDir, 'out');     
end

if nargin > 2;  warning('More than two inputs detected; ignoring additional inputs.' ); end   

%  checks if the paths exist
if ~exist(save_path, 'dir');  mkdir(save_path); end % in case nargin < 2 alread created
fprintf('\nImported files will be saved to:  %s',save_path); % change the text ; maybe different order to display? maybe add that it was created vs 
if ~exist(dataset_path, 'dir'); error('dataset_path has to be a folder'); end

% Adds lib to the path
libpath = pspm_path('bids_importer','lib');
addpath(libpath); 

%% 2. Read meta information ------------------------------------------------


[~, currentFolder] = fileparts(dataset_path); 

% checks if dataset or subject are to be imported

dataset_mode = ~(startsWith(currentFolder, 'sub-') || startsWith(currentFolder, 'ses-')); 
ses_mode = startsWith(currentFolder, 'ses-');  

if ~(startsWith(currentFolder, 'sub-') || startsWith(currentFolder, 'ses-')); dataset_mode = true; end


if dataset_mode
    dataset_description = read_dataset_description(dataset_path); % optional
    [participants_data, participant_data_headings] = read_participants_data(dataset_path); % has to be there
    
    % Store participant information headings in dataset description
    dataset_description.ParticipantInformation = participant_data_headings;
    
    % Get list of subject directories (assumes names start with 'sub-')
    subject_list = dir(fullfile(dataset_path, 'sub-*'));
    subject_list = subject_list([subject_list.isdir]);
else
    if ses_mode
        sub_path = fileparts(dataset_path); 
    else
        sub_path = dataset_path;
    end

    description_path = fileparts(sub_path); % on  level above the subject folder
    dataset_description = read_dataset_description(description_path); % optional!
    [participants_data, participant_data_headings] = read_participants_data(description_path); % NOT optional
   
    % Store participant information headings in dataset description
    dataset_description.ParticipantInformation = participant_data_headings; % maybe just the one that is imported??
       
    [~, subject_list(1).name] = fileparts(sub_path); % only one subject
end






%% 3. Loop over subjects ---------------------------------------------------
for i = 1:length(subject_list)
   
    subject_full_id = subject_list(i).name;  % e.g., 'sub-CalinetBonn01
    sub_idx_str = regexp(subject_full_id, '\d+$', 'match', 'once');
    sub_idx = str2double(sub_idx_str); % e.g. '01' -> 1
    

    % Build participant structure by mapping each field.
    Participant = struct();
    for p_info_ind = 1:numel(participant_data_headings)
        field_name = participant_data_headings{p_info_ind};
        Participant.(field_name) = participants_data{p_info_ind}{sub_idx};
    end
    


    fprintf('\n------------------------------------------------------------');
    fprintf('\n------------------------------------------------------------');
    fprintf('\n\nImporting %s ... \n', subject_full_id);
    

    if dataset_mode 
        sub_path = fullfile(dataset_path, subject_full_id);
    end

    if ses_mode  
        [~, session_dirs(1).name] = fileparts(dataset_path);  
    else 
        session_dirs = dir(fullfile(sub_path,'ses-*'));
        session_dirs = session_dirs([session_dirs.isdir]);    
    end % if session mode !
    % checks if there are Sessions
    if isempty(session_dirs); warning('No session folder  (''ses-%s'') found in %s', sub_idx_str ,sub_path); continue; end


    %% Process each session
    
    for j = 1:length(session_dirs)
        session_id = session_dirs(j).name(5:end);  % e.g., '01' or '02' (could there be more 100 sessions?)
        
        ses_path = fullfile(sub_path ,session_dirs(j).name); 
        beh_dir    = fullfile(ses_path, 'beh');
        physio_dir = fullfile(ses_path, 'physio');


        %% Extract task name

        % Look for any event JSON
        pattern = sprintf('%s_ses-%s_task-*_events.*', subject_full_id, session_id);
        beh_files = dir(fullfile(beh_dir, pattern));        % If no beh JSON, look for physio files with task tag
        physio_files = dir(fullfile(physio_dir, sprintf('%s_ses-%s_task-*_events.tsv', subject_full_id, session_id)));

        if ~isempty(beh_files)
            fname = beh_files(1).name;
        elseif ~isempty(physio_files)
            fname = physio_files(1).name;
        else
            warning('No BIDS event or physio files for %s session %s', subject_full_id, session_id);
            continue;
        end
        % Extract the token after 'task-' and before the next underscore
        tk = regexp(fname, '_task-([^_]+)_', 'tokens', 'once');
        task_name = tk{1};

        %% Processing start

        fprintf('\n------------------------------------------------------------');
        fprintf('\n\n  Processing session %s with task %s ...\n\n', session_dirs(j).name, task_name);

        % --- get physio data ---
        physio_path = fullfile(ses_path,'physio');
        [physio_data_cell, physio_info_data] = get_physio_data(subject_full_id, session_id, task_name, physio_path);
        

        %% --- Get beh data ---

        beh_path = fullfile(ses_path,'beh');
        
        % Marker channel 
        events_json_filename = sprintf('%s_ses-%s_task-%s_events.json', subject_full_id, session_id, task_name);
        events_tsv_filename  = sprintf('%s_ses-%s_task-%s_events.tsv', subject_full_id, session_id, task_name);
        events_json_filepath = fullfile(beh_path, events_json_filename);
        events_tsv_filepath  = fullfile(beh_path, events_tsv_filename);
        if ~isfile(events_json_filepath); error('File not found: %s', events_json_filepath); end
        if ~isfile(events_tsv_filepath);  error('File not found: %s', events_tsv_filepath);  end

        marker_chan = get_marker_data(events_json_filepath, events_tsv_filepath);

        %% --- Build the file structure  ---

        % Build infos
        infos  = get_beh_data(subject_full_id, session_id, beh_path);
        infos.PhysioInfos =  physio_info_data ; % maybe wrong needs better structure
        infos.DatasetDescription = dataset_description;
        infos.Participant = Participant;
        
        % --- save per ses 
        %session.infos = infos;
        session.data = {};
        session.data{end+1} = marker_chan;
        session.data = [session.data ; physio_data_cell];
        
        % aligne all channels
        [session.data, infos.duration] = align_channels(session.data);
        
        % update duration after alignment
        infos.Physio.duration  = infos.duration;

        % Save session (cogent) file once per subject
        cogent_ses_file_name = sprintf('pspm_%s_ses-%s_cogent.mat', subject_full_id,session_id);
        cogent_ses_filepath = fullfile(save_path, cogent_ses_file_name);
        outfile{end+1} = cogent_ses_filepath;
    
        % Check the pspm strucutre
        fn.infos = infos;
        fn.data = session.data;

        [sts, ~, ~, ~] = pspm_load_data(fn);
        if sts < 1
            warning('The file struture has a problem'); % better warning text
            contiue; 
        end

        % add overwrite ?
        data = session.data;
        save(cogent_ses_filepath,'infos', 'data');
        fprintf('\n\nSaved cogent file to %s\n', cogent_ses_filepath);

    end

end
rmpath(libpath); % What if the function breaks at anothe parth
sts = 1;
end

%% 4. Sub-functions ---------------------------------------------------------

function dataset_description = read_dataset_description(dataset_path)
    dataset_description_filepath = fullfile(dataset_path, 'dataset_description.json');

    if ~exist(dataset_description_filepath, 'file')
        warning('read_dataset_description:MissingFile', ...
            'dataset_description.json is missing in the specified path: %s', dataset_path);
        dataset_description = struct();
        return;
    end

    % Read and decode the JSON file
    try
        dataset_description = jsondecode(fileread(dataset_description_filepath));
    catch ME
        error('read_dataset_description:ReadError', ...
            'Failed to read or parse dataset_description.json: %s', ME.message);
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

function [infos] = get_beh_data(subject_id, session_id, beh_path) 
beh_json_filename    = sprintf('%s_ses-%s_beh.json', subject_id, session_id);
beh_json_filepath    = fullfile(beh_path, beh_json_filename);

if ~isfile(beh_json_filepath);    error('Behavior sidecar JSON file not found: %s', beh_json_filepath); end

beh_sidecar = extract_json_as_struct(beh_json_filepath);
infos = beh_sidecar;
end

function [data, new_duration] = align_channels(data)

num_channels = length(data);
startTimes = zeros(num_channels,1);

% Determine start time for each channel (assume 0 if missing)
for i = 1:num_channels
    if isfield(data{i}.header, 'StartTime')
        startTimes(i) = data{i}.header.StartTime;
    else
        startTimes(i) = 0;
        data{i}.header.StartTime = 0; % sure? now everything has a StartTime if marker
    end
end

global_min = min(startTimes);
finalLengths = zeros(num_channels,1);

for i = 1:num_channels        
    shift_sec = data{i}.header.StartTime - global_min;
    
    % Check if this channel is an event channel.
    if isfield(data{i}, 'markerinfo')
        data{i}.data = data{i}.data + shift_sec;
        rmfield(data{i}.header,'StartTime');
    else
        if ~isfield(data{i}.header, 'sr')
            warning('Channel %d is missing sampling rate (sr) in its header.', i);
        end
        sr = data{i}.header.sr;
        numPad = round(shift_sec * sr);
        
        % Prepend zeros to the data vector. Do not trim any original samples.
        data{i}.data = [zeros(numPad, 1); data{i}.data];
        
        % Record the new length.
        finalLengths(i) = length(data{i}.data);
        data{i}.header.StartTime = 0;
    end    
end


% Padding at the end
[sts, data, new_duration] = pspm_align_channels(data); % can the fprint be turned off?
% [~, data, new_duration, sts] = evalc('[sts, data, new_duration] = pspm_align_channels(data);'); % turns of fprint

if sts ~= 1 % if all are the same size does it give en error?
    error('Channel alignment failed.');
end

end


