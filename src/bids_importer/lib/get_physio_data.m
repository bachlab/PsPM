function [physio_data_cell, recording_duration, physio_info_data] = get_physio_data(subject_id, session_id, task_name, physio_path)
% Returns a 4x1 cell array where each cell contains a struct with fields header and data (and markerinfo for events)
% Also returns physio_info_data needed to create 'info' struct
% UPDATE HELPTEXT

%% Initialize the physio data cell array
physio_signals = { 'ecg','ppg', 'scr'}; %  'event'
num_signals = length(physio_signals);
physio_data_cell = cell(num_signals, 1);  % Preallocate cell array
pyhsio_main_struct = struct();


% Initialize variables for infos
chan_names = cell(num_signals, 1);
file_paths = cell(num_signals, 1);

% Index to keep track of the cell array
cell_index = 1;


%% Process each physio signal
for i = 1:num_signals   
    signal = physio_signals{i};
    
    % Construct filenames
    physio_json_filename = sprintf('%s_ses-%s_recording-%s_physio.json', subject_id, session_id, signal);
    physio_tsv_filename  = sprintf('%s_ses-%s_recording-%s_physio.tsv', subject_id, session_id, signal);

    physio_json_filepath = fullfile(physio_path, physio_json_filename);
    physio_tsv_filepath = fullfile(physio_path, physio_tsv_filename);

    % Collect file paths for infos
    file_paths{cell_index} = physio_tsv_filepath;

    % Check if files exist
    if ~isfile(physio_json_filepath); error('File not found: %s', physio_json_filepath); end
    if ~isfile(physio_tsv_filepath);  error('File not found: %s', physio_tsv_filepath);  end

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
    physio_data_cell{cell_index} = chan;

    % Collect channel names for info
    chan_names{cell_index} = signal;


    cell_index = cell_index +1; 
end

%% Process physio event data -> header eyedata maybe somewhere else?


events_json_filename = sprintf('%s_ses-%s_task-%s_physioevents.json', subject_id, session_id, task_name);
events_tsv_filename  = sprintf('%s_ses-%s_task-%s_physioevents.tsv', subject_id, session_id, task_name);
events_json_filepath = fullfile(physio_path, events_json_filename);
events_tsv_filepath  = fullfile(physio_path, events_tsv_filename);

% Checks if files exist
if ~isfile(events_json_filepath); error('File not found: %s', events_json_filepath); end
if ~isfile(events_tsv_filepath);  error('File not found: %s', events_tsv_filepath);  end

% Append the file paths
file_paths{cell_index} = events_tsv_filepath;

% Read JSON metadata
events_json = extract_json_as_struct(events_json_filepath);

% Read events TSV
has_headings = true;
col_types = {'double', 'double', 'char', 'char', 'char'};
events_table = read_data_from_tsv(events_tsv_filepath, has_headings, [], col_types);

% Check if 'trial_type' exists in the table columns 
events_json.Columns = regexprep(events_json.Columns,'^trial_type$','event_type');% can be take out with the new data !!
headings = events_json.Columns;  
events_json.Columns = struct();

% Add the tsv tabel to  evnents_json
for i = 1:length(headings)
    events_json.Columns.(headings{i}) = events_table.(headings{i});
end

% Get duration: last value of event time info
duration = events_table.onset(end) - events_table.onset(1); %  duration of the EVENTS (onset)
events_json.duration = duration;

% events_json will be added to physio_info_data at the end of the funciton




%% Process eye data


[eye_data_cell] = get_eyetrack_data(subject_id, session_id, task_name, physio_path);


% --- Add the eye data to the channels --- 
switch length(eye_data_cell)
    case 0; warning('No eye data available.');        
    case 1
        % Only one eye recorded; assign based on the eye type and warn the user.
        eyeSide = lower(eye_data_cell{1}.RecordedEye);
        if strcmp(eyeSide, 'right')
            pupil_r  = eye_data_cell{1}.Columns{:,'pupil_size'};
            gaze_x_r = eye_data_cell{1}.Columns{:,'x_coordinate'};
            gaze_y_r = eye_data_cell{1}.Columns{:,'y_coordinate'};

            data{1}.data  = pupil_r;
            data{1}.header.chantype  = 'pupil_r';
            data{end+1}.data  = gaze_x_r;
            data{end+1}.header.chantype  = 'gaze_x_r';
            data{end+1}.data  = gaze_y_r;
            data{end+1}.header.chantype  = 'gaze_y_r';
    

            warning('Only right eye data available.');
        elseif strcmp(eyeSide, 'left')
            %  
            pupil_l  = eye_data_cell{1}.Columns{:,'pupil_size'};
            gaze_x_l = eye_data_cell{1}.Columns{:,'x_coordinate'};
            gaze_y_l = eye_data_cell{1}.Columns{:,'y_coordinate'};
      
            data{1}.data  = pupil_l;
            data{1}.header.chantype  = 'pupil_l';
            data{end+1}.data  = gaze_x_l;
            data{end+1}.header.chantype  = 'gaze_x_l';
            data{end+1}.data  = gaze_y_l;
            data{end+1}.header.chantype  = 'gaze_y_l';

            warning('Only left eye data available.');
        else; error('Unknown RecordedEye eye_data_cell.'); end % !!! maybe warning?     
    case 2
        eyes = lower({eye_data_cell{1}.RecordedEye, eye_data_cell{2}.RecordedEye}); 
        if strcmp(eyes{1}, eyes{2})
            warning('Both recorded eyes are %s.', eyes{1});
            % Maybe choose the better eye?
        else
            % Correctly assign each cell to the corresponding eye.
            idxRight = find(strcmp(eyes, 'right'), 1);
            idxLeft  = find(strcmp(eyes, 'left'),  1);
            
            if isempty(idxRight) || isempty(idxLeft); warning('...');end 

            pupil_r  = eye_data_cell{idxRight}.Columns{:,'pupil_size'};
            gaze_x_r = eye_data_cell{idxRight}.Columns{:,'x_coordinate'};
            gaze_y_r = eye_data_cell{idxRight}.Columns{:,'y_coordinate'};
           
            pupil_l  = eye_data_cell{idxLeft}.Columns{:,'pupil_size'};
            gaze_x_l = eye_data_cell{idxLeft}.Columns{:,'x_coordinate'};
            gaze_y_l = eye_data_cell{idxLeft}.Columns{:,'y_coordinate'};
            
            % right eye channels
            data{1}.header.chantype  = 'pupil_r';
            data{1}.data  = pupil_r;
            
            data{2}.header.chantype  = 'gaze_x_r';
            data{2}.data  = gaze_x_r;
            data{3}.header.chantype  = 'gaze_y_r';
            data{3}.data  = gaze_y_r;

            % left eye channels
            data{4}.header.chantype  = 'pupil_l';
            data{4}.data  = pupil_l;
            data{5}.header.chantype  = 'gaze_x_l';
            data{5}.data  = gaze_x_l;
            data{6}.header.chantype  = 'gaze_y_l';
            data{6}.data  = gaze_y_l;
        
        end
        
    otherwise; error('Unexpected number of eye data cells.'); 
end

data = data';
% Add header data for pupil and gaze data
for i = 1:length(data)
    if strcmp(data{i}.header.chantype(1:end-1) , 'pupil_')
        if strcmp(data{i}.header.chantype(end:end) , 'r')
            data{i}.header.Description = eye_data_cell{idxRight}.pupil_size.Description;
            data{i}.header.units =    eye_data_cell{idxRight}.pupil_size.Units;
            data{i}.header.sr   =    eye_data_cell{idxRight}.SamplingRate;

        elseif strcmp(data{i}.header.chantype(end:end) , 'l')
            data{i}.header.Description = eye_data_cell{idxLeft}.pupil_size.Description;
            data{i}.header.units =    eye_data_cell{idxLeft}.pupil_size.Units;
            data{i}.header.sr   =    eye_data_cell{idxLeft}.SamplingRate;
            
        else; warning('Something went wrong no pupil channel!')  % !!!!!
        end

    elseif strcmp(data{i}.header.chantype(1:end-4) , 'gaze')
        if strcmp(data{i}.header.chantype(6) , 'x')
           if strcmp(data{i}.header.chantype(8) , 'r')
               % gaze_x_r
               data{i}.header.Description = eye_data_cell{idxRight}.pupil_size.Description; %
               data{i}.header.units =    eye_data_cell{idxRight}.SampleCoordinateUnits;
               data{i}.header.sr   =    eye_data_cell{idxRight}.SamplingRate;
               data{i}.header.range =  [eye_data_cell{idxRight}.GazeRange.xmin, eye_data_cell{idxRight}.GazeRange.xmax] ;    % e.g. [0 1151]
           elseif strcmp(data{i}.header.chantype(8) , 'l')
              % gaze_x_l
               data{i}.header.Description = eye_data_cell{idxLeft}.pupil_size.Description; % 
               data{i}.header.units =    eye_data_cell{idxLeft}.SampleCoordinateUnits;
               data{i}.header.sr   =    eye_data_cell{idxLeft}.SamplingRate;
               data{i}.header.range =  [eye_data_cell{idxLeft}.GazeRange.xmin, eye_data_cell{idxLeft}.GazeRange.xmax] ;    % e.g. [0 1151]
               
           else; warning('Something went worng with gaze  y channels')
           end

        elseif strcmp(data{i}.header.chantype(6) , 'y')
           if strcmp(data{i}.header.chantype(8) , 'r')
               % gaze_y_r
               data{i}.header.Description = eye_data_cell{idxRight}.pupil_size.Description; %
               data{i}.header.units =    eye_data_cell{idxRight}.SampleCoordinateUnits;
               data{i}.header.sr   =    eye_data_cell{idxRight}.SamplingRate;
               data{i}.header.range =  [eye_data_cell{idxRight}.GazeRange.ymin, eye_data_cell{idxRight}.GazeRange.ymax] ;    % e.g. [0 1151]
           
           elseif strcmp(data{i}.header.chantype(8) , 'l')
               % gaze_y_l
               data{i}.header.Description = eye_data_cell{idxLeft}.pupil_size.Description; %
               data{i}.header.units =    eye_data_cell{idxLeft}.SampleCoordinateUnits;
               data{i}.header.sr   =    eye_data_cell{idxLeft}.SamplingRate; % delelt with the new data
               data{i}.header.range =  [eye_data_cell{idxLeft}.GazeRange.ymin, eye_data_cell{idxLeft}.GazeRange.ymax] ;    % e.g. [0 1151]
                      
           else ; warning('Something went worng with gaze  y channels')
           end
        end
     end
end

% --- Make the infos struct --

% Check that all fields are the same except of ->
eye1_struct = eye_data_cell{1};
eye2_struct = eye_data_cell{2};

% Define the fields to ignore 
% Assumtion this are all the fields that could be different
ignoreFields = {'MaximalCalibrationError', 'MaximalCalibrationError','Columns'};

% Remove these fields from both structs
eye1Reduced = rmfield(eye1_struct, ignoreFields);
eye2Reduced = rmfield(eye2_struct, ignoreFields);

% Compare the remaining fields
if isequal(eye1Reduced, eye2Reduced);    disp('The structures are equal except for the ignored fields.'); %
else;    disp('The structures differ in some non-ignored fields.'); % maybe show diff. fields
end


% --- Build the infosstruct ----

infos = struct();
infos.importdate =  datestr(date, 'dd-mmm-yyyy');
infos.duration = eye_data_cell{1}.RecordingDuration;
infos.durationinfo = 'Recording duration in seconds'; % where in eye_data_cell ???

% --- infos.source ---
infos.source.channel = {};% {'Column 02'} {'Column 01'} ????

%
infos.source.chan_stats = cell(length(data), 1); % use size??
for i = 1:length(data)
    n_data = size(data{i}.data, 1);
    n_inv = sum(isnan(data{i}.data));
    infos.source.chan_stats{i,1} = struct();
    infos.source.chan_stats{i,1}.nan_ratio = n_inv / n_data;
end


infos.source.date = '01.01.1900'; % no information in jsons
infos.source.time = '00:00:00'; % no information in jsons

if ~isequal(eye_data_cell{idxRight}.GazeRange,eye_data_cell{idxLeft}.GazeRange); warning("GazeRange is not equal") % already checked???
end

infos.source.gaze_coords = eye_data_cell{idxRight}.GazeRange;
infos.source.PupilFitMethod = eye_data_cell{idxRight}.PupilFitMethod ; % why not eye_data_cell{idxRight}.ELCL_PROC
infos.source.eyesObserved = 'lr';
infos.source.best_eye = 'l' ;

% infos.source.elcl_proc = eye_data_cell{idxRight}.
infos.source.type = 'Bids (jason/tsv)' ; % exact name??
infos.source.file = [eye_data_cell{idxRight}.source.file, eye_data_cell{idxRight}.source.file] ;% different orientation?


% infos.importfile =  'ImportTestData/eyelink/pspm_S114_s2.mat' % late the end the file that will be produced look in the manual
infos.history = {' Output channel ID: #08 -- added on 06-Mar-20'}; % what sould be here??

% Maybe put in different order
infos.source.SampleCoordinateSystem = eye_data_cell{idxRight}.SampleCoordinateSystem;
infos.source.EnvironmentCoordinates = eye_data_cell{idxRight}.EnvironmentCoordinates;
infos.source.Manufacturer = eye_data_cell{idxRight}.EnvironmentCoordinates;
infos.source.ManufacturersModelName = eye_data_cell{idxRight}.ManufacturersModelName;
infos.source.SoftwareVersion = eye_data_cell{idxRight}.ManufacturersModelName;
infos.source.MaximalCalibrationError = eye_data_cell{idxRight}.MaximalCalibrationError;
infos.source.AverageCalibrationError = eye_data_cell{idxRight}.AverageCalibrationError;
infos.source.EyeTrackerDistance = eye_data_cell{idxRight}.EyeTrackerDistance;

chan_names{end+1} = 'eye'; % should it have a different name?
file_paths{end+1} = infos.source.file;

physio_data_cell = [physio_data_cell; data];

%% Prepare physio_info_data ??

% Add the eye channel names
for i = 1:length(data)
    chan_names{cell_index+i} = data{i}.header.chantype;
end

physio_info_data = infos;
physio_info_data.chan_names = chan_names; % add the name of all eye channels!!
physio_info_data.file_paths = file_paths; % make the eye  filenames in the right orientation
physio_info_data.duration   = duration; 
physio_info_data.events_infos = events_json;


%%




recording_duration = length(physio_data_cell{1}.data) / physio_data_cell{1}.header.sr;  

end