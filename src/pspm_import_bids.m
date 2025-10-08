function [sts, outfile] = pspm_import_bids(dataset_path, save_path)
% ● Description
%   pspm_import_bids reads a BIDS-PP formatted dataset for a set of 
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
currentParticipant = struct();

% checks inputs
if ~(ischar(dataset_path) || isstring(dataset_path))
    error('PsPM:InvalidInput', 'dataset_path must be a string.');
end
if nargin < 2
    parentDir = fileparts(dataset_path);
    save_path = 0;

elseif ~(ischar(save_path) || isstring(save_path)) 
    warning('InvalidInput', 'save_path must be a character vector or string.'); %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parentDir = fileparts(dataset_path);
    save_path = 0;
end

if nargin > 2;  warning('More than two inputs detected; ignoring additional inputs.' ); end   

% checks if the path exist
if ~exist(dataset_path, 'dir');  error( 'PsPM:InvalidPath','dataset_path has to be a folder'); end



% Adds libs to the path
libpath = pspm_path('bids_importer','lib');
addpath(libpath); 

%% 2. Read meta information & Add paths to the right variables ------------------------------------------------

[~, currentFolder] = fileparts(dataset_path); 
% problems with path that are written like /path/fold/ with "/" at the end
% under linux -> needs to be tests under mac and windows !!
if isempty(currentFolder)
    dataset_path = dataset_path(1:end-1);
    [~, currentFolder] = fileparts(dataset_path); 
end

% checks if dataset is to be imported
dataset_mode = ~(startsWith(currentFolder, 'sub-') || startsWith(currentFolder, 'ses-'));  % if not sub or not ses -> dataset
% if ~(startsWith(currentFolder, 'sub-') || startsWith(currentFolder, 'ses-')); dataset_mode = true; end % if not sub or not ses -> dataset
ses_mode = startsWith(currentFolder, 'ses-');  

% dataset mode
if dataset_mode
    % imports dataset description and participant information if available
    % dataset_description = read_dataset_description(dataset_path); 
    [Participants.data, Participants.headings]  = read_participants_data(dataset_path);

    % Get list of subject directories (assumes names start with 'sub-')
    subject_list = dir(fullfile(dataset_path, 'sub-*'));
    subject_list = subject_list([subject_list.isdir]);

% sub or ses to be imported 
else
   % subject or session mode
    if ses_mode
        sub_path = fileparts(dataset_path); % one level above ses-*
        ses_path = dataset_path;
    else % if not dataset and not ses -> sub
        sub_path = dataset_path; % subject path
    end

    % dataset_path now becomes the real dataset level path 
    dataset_path = fileparts(sub_path); % on  level above the subject folder -> dataset What if there is no dataset folder ??
  
    % % imports dataset description and participant information if available
    dataset_description = read_dataset_description(dataset_path); 
    [Participants.data, Participants.headings] = read_participants_data(dataset_path);

    % Store participant information headings in dataset description
       
    [~, subject_list(1).name] = fileparts(sub_path); % only one subject
end

% Output folder (save_path)
if ~save_path 
    % warning('No save path');  
    save_path = [dataset_path, filesep, 'out'];  % fullfile
end % if there is no save_path or there was an error not char or string = 0
if ~exist(save_path, 'dir');  mkdir(save_path); end
fprintf('\nImported files will be saved to:  %s\n',save_path);

%% 3. Loop over subjects ---------------------------------------------------
for i = 1:length(subject_list)
   
    subject_full_id = subject_list(i).name;  % e.g., 'sub-CalinetBonn01
    sub_idx_str = regexp(subject_full_id, '\d+$', 'match', 'once');
    sub_idx = str2double(sub_idx_str); % e.g. '01' -> 1
    
    % get current Participant
    % if ~isempty(Participants.headings) && ~isempty(Participants.data)
    %     indx = find(contains(dataset_description.Participants.data{1}, subject_full_id));
    %     % name
    %     currentParticipant.(dataset_description.Participants.headings{1}) = ...
    %     dataset_description.Participants.data{1}{indx};
    %     % age
    %     currentParticipant.(dataset_description.Participants.headings{2}) = ...
    %     dataset_description.Participants.data{2}{indx};
    %     % sex
    %     currentParticipant.(dataset_description.Participants.headings{3}) = ...
    %     dataset_description.Participants.data{3}{indx};
    %     % handedness
    %     currentParticipant.(dataset_description.Participants.headings{4}) = ...
    %     dataset_description.Participants.data{4}{indx};
    % end
    % 
    fprintf('\n------------------------------------------------------------------------------------------------------------------------');
    fprintf('\n------------------------------------------------------------------------------------------------------------------------');
    fprintf('\n\nImporting %s ... \n', subject_full_id);
    

    if dataset_mode 
        sub_path = fullfile(dataset_path, subject_full_id); 
    end

    if ses_mode  
        [~, session_dirs(1).name] = fileparts(ses_path);

    else % subject mode
        session_dirs = dir(fullfile(sub_path,'ses-*'));
        session_dirs = session_dirs([session_dirs.isdir]);    
    end 

    % checks if there are sessions
    if isempty(session_dirs); warning('PsPM:NoSessions','No session folder  (''ses-%s'') found in %s', sub_idx_str ,sub_path); continue; end


    %% Process each session    
    for j = 1:length(session_dirs)
        session_id = session_dirs(j).name(5:end);  % e.g., '01' or '02' (could there be more 100 sessions?)        
        ses_path   = fullfile(sub_path ,session_dirs(j).name); % if it is ses_mode it will be overwriten but that is okay
        beh_dir    = fullfile(ses_path, 'beh');
        physio_dir = fullfile(ses_path, 'physio');


        %% Extract task name
        % Look for any event JSON
        pattern_beh = sprintf('%s_ses-%s_task-*_events.*', subject_full_id, session_id); % both json and tsv
        beh_files = dir(fullfile(beh_dir, pattern_beh));        
        pattern_physio = sprintf('%s_ses-%s_task-*_physioevents.*', subject_full_id, session_id);
        physio_files = dir(fullfile(physio_dir, pattern_physio));

        if ~isempty(beh_files) && length(beh_files) == 2
            fname = beh_files(1).name;
        elseif ~isempty(physio_files) && length(physio_files) == 2
            fname = physio_files(1).name;
        else
            warning('PsPM:NoFiles','No BIDS event or physio files for %s session %s', subject_full_id, session_id);
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
        
        if psts < 1; warning('No Physio data'); end % Fix

        %% --- Get beh data ---

        beh_path = fullfile(ses_path,'beh');
        
        % Marker beh channel 
        events_json_filename = sprintf('%s_ses-%s_task-%s_events.json', subject_full_id, session_id, task_name);
        events_tsv_filename  = sprintf('%s_ses-%s_task-%s_events.tsv', subject_full_id, session_id, task_name);
        events_json_filepath = fullfile(beh_path, events_json_filename);
        events_tsv_filepath  = fullfile(beh_path, events_tsv_filename);

        if ~isfile(events_json_filepath); error('PsPM:NoEvent','File not found: %s', events_json_filepath); end
        if ~isfile(events_tsv_filepath);  error('PsPM:NoEvent','File not found: %s', events_tsv_filepath);  end

        %  what is with the column fields?
        marker_chan = get_marker_data(events_json_filepath, events_tsv_filepath,false);
        % get behave json (not the marker)
        beh_json  = get_beh_json(subject_full_id, session_id, task_name, beh_path);

        %% --- Build the file structure  ---
        % Build sessions infos
       

        % ses.infos.duration - will be added after alignment
        ses.infos.sourcefile = 1; % add the source files !
        % infos.importfile - will be added before saving
        dt = datetime('now'); 
        ses.infos.importdate = sprintf('%.2d.%.2d.%.2d', dt.Day, dt.Month, dt.Year); % same as import_eyelink and importviewpoint; 
        ses.infos.sourcetype = 'BIDS (json/tsv)'; % physio_infos.infos;
        % ses.infos.recdate - no information;
        % ses.info.rectime - no information;

       % if infos.source
        ses.infos.source = physio_infos.source;
        if ~isempty(dataset_description); infos.DatasetDescription = dataset_description; end
        if ~isempty(fieldnames(currentParticipant)); infos.Participant = currentParticipant; end

        %  save per session
    
        ses.data = {};
        ses.data{1} = marker_chan;
        ses.data = [ses.data ; physio_data]; % Marker channel first
        
        % align all channels
        [ses.data, ses.infos.duration] = align_channels(ses.data);
        


        % Save session (cogent) file once per subject
        cogent_ses_file_name = sprintf('pspm_%s_ses-%s.mat', subject_full_id,session_id);
        cogent_ses_filepath = fullfile(save_path, cogent_ses_file_name);
        outfile{end+1} = cogent_ses_filepath;

        ses.infos.importfile = cogent_ses_filepath; 
        
        % Check the pspm structure
        fn.infos = ses.infos;
        fn.data = ses.data;

        [lsts, ~, ~, ~] = pspm_load_data(fn);
        if lsts < 1
            warning('The file struture has a problem'); % better warning text
            continue; 
        end

        %  overwrite 
        data = ses.data;
        infos = fn.infos;
        save(cogent_ses_filepath,'infos', 'data');
        fprintf('\n\nSaved cogent file to %s\n', cogent_ses_filepath);

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
        warning('read_dataset_description:MissingFile', ...
            'dataset_description.json is missing in the specified path: %s', dataset_path);
        dataset_description = [];
        return;
    end

    % Read and decode the JSON file
    try
        dataset_description = jsondecode(fileread(dataset_description_filepath));
    catch ME
        warning('read_dataset_description:ReadError', ...
            'Failed to read or parse dataset_description.json: %s', ME.message);
        dataset_description = [];
    end
end

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

beh_json_filename    = sprintf('%s_ses-%s_task-%s_beh.json', subject_id, session_id, task_name);
%beh_json_filename    = sprintf('%s_ses-%s_beh.json', subject_id, session_id);
beh_json_filepath    = fullfile(beh_path, beh_json_filename);

if ~isfile(beh_json_filepath);    error('Behavior sidecar JSON file not found: %s', beh_json_filepath); end

beh_sidecar = extract_json_as_struct(beh_json_filepath);
infos = beh_sidecar;
end

function [data, new_duration] = align_channels(data)

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
            warning('Channel %d is missing sampling rate (sr) in its header. This will lead to probelms later.', i);
            continue;
        end
        sr = data{i}.header.sr;
        numPad = round(shift_sec * sr);

        % Prepadded zeros to the data vector. 
        data{i}.data = [zeros(numPad, 1); data{i}.data];

        % Record the new length.
        finalLengths(i) = length(data{i}.data);
        data{i}.header.StartTime = 0;
    end    
end


%!!!!!!!!!!!!!!!!!!!!
display(finalLengths(:)  )


% Padding at the end
[sts, data, new_duration] = pspm_align_channels(data); % can the fprint be turned off?
% [~, data, new_duration, sts] = evalc('[sts, data, new_duration] = pspm_align_channels(data);'); % turns of fprint

if sts ~= 1 % if all are the same size does it give en error?
    error('Channel alignment failed.');
end

end

