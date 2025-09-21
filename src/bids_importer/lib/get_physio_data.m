function [sts , physio_data, physio_infos] = get_physio_data(subject_id, session_id, task_name, physio_path)
% Returns a  cell array where each cell contains a struct with fields header and data (and markerinfo for events)
% Also returns physio_info_data needed to create 'info' struct
% UPDATE HELPTEXT

%% Initialize the physio data cell array
sts = -1;
physio_data = {}; 
physio_infos = {};

physio_signals = {'ecg','ppg', 'scr'};
num_signals = length(physio_signals);

% Initialize variables for infos

chan_names = {}; 
file_paths = {}; 

% Index to keep track of the cell array
cell_index = 0;


%% Process each physio signal
for i = 1:num_signals   

    signal = physio_signals{i};
    
    % Construct filenames
    physio_json_filename = sprintf('%s_ses-%s_recording-%s_physio.json', subject_id, session_id, signal);
    physio_tsv_filename  = sprintf('%s_ses-%s_recording-%s_physio.tsv', subject_id, session_id, signal);

    physio_json_filepath = fullfile(physio_path, physio_json_filename);
    physio_tsv_filepath  = fullfile(physio_path, physio_tsv_filename);



    % Check if files exist 
    % The warning could be confusing 
    if ~isfile(physio_json_filepath); warning('File not found: %s', physio_json_filepath);continue; end
    if ~isfile(physio_tsv_filepath);  warning('File not found: %s', physio_tsv_filepath); continue; end
    
    % index
    cell_index = cell_index +1;
    
    % Collect file paths for infos
    file_paths{cell_index,1} = {physio_json_filepath,physio_tsv_filepath};

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
    physio_data{cell_index,1} = chan;


end

%% Process physio eye event data -> header eyedata maybe somewhere else?
events_json_filename = sprintf('%s_ses-%s_task-%s_physioevents.json', subject_id, session_id, task_name);
events_tsv_filename  = sprintf('%s_ses-%s_task-%s_physioevents.tsv', subject_id, session_id, task_name);
events_json_filepath = fullfile(physio_path, events_json_filename);
events_tsv_filepath  = fullfile(physio_path, events_tsv_filename);

% Checks if files exist
if ~isfile(events_json_filepath) || ~isfile(events_tsv_filepath)
    warning('No physio events for task "%s" in %s. Skipping event processing.', task_name, physio_path); % Change !!!!!!!!!!!
else
    cell_index = cell_index +1; 
    marker_data = get_marker_data(events_json_filepath,events_tsv_filepath,false); % has Columns 

    file_paths{cell_index,1} = {events_json_filepath,events_tsv_filepath}; 
    physio_data{cell_index,1} = marker_data;
end % end of physio marker


%% % Process eye data

[ests , eye_data_cell] = get_eyetrack_data(subject_id, session_id, task_name, physio_path);

if ests == 1

% --- Add the eye data to the channels --- 
n_eyes = length(eye_data_cell);
switch n_eyes
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
            data{2}.data  = gaze_x_r;
            data{2}.header.chantype  = 'gaze_x_r';
            data{3}.data  = gaze_y_r;
            data{3}.header.chantype  = 'gaze_y_r';
    

            warning('Only right eye data available.');
        elseif strcmp(eyeSide, 'left')
            %  
            pupil_l  = eye_data_cell{1}.Columns{:,'pupil_size'};
            gaze_x_l = eye_data_cell{1}.Columns{:,'x_coordinate'};
            gaze_y_l = eye_data_cell{1}.Columns{:,'y_coordinate'};
      
            data{1}.data  = pupil_l;
            data{1}.header.chantype  = 'pupil_l';
            data{2}.data  = gaze_x_l;
            data{2}.header.chantype  = 'gaze_x_l';
            data{3}.data  = gaze_y_l;
            data{3}.header.chantype  = 'gaze_y_l';

            warning('Only left eye data available.');
        else; error('Unknown RecordedEye eye_data_cell.'); % !!! maybe warning?
        end      
    case 2
        eyes = lower({eye_data_cell{1}.RecordedEye, eye_data_cell{2}.RecordedEye}); 
        if strcmp(eyes{1}, eyes{2})
            warning('Both recorded eyes are %s.', eyes{1});
            % Maybe choose the better eye? -> it chooses the better depends
            % on l or eye
        else
            % Correctly assign each cell to the corresponding eye.
            idxRight = find(strcmp(eyes, 'right'), 1);
            idxLeft  = find(strcmp(eyes, 'left'),  1);
            
            if isempty(idxRight) || isempty(idxLeft); warning('...');end % ???

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
%% Add header data for pupil and gaze data
if n_eyes == 1; idxRight = 1; idxLeft  = 1; end % for one eye 

for i = 1:length(data)
    % pupil
    if strcmp(data{i}.header.chantype(1:end-1) , 'pupil_')
        if strcmp(data{i}.header.chantype(end:end) , 'r')
            data{i}.header.Description = eye_data_cell{idxRight}.pupil_size.Description;
            data{i}.header.units =   eye_data_cell{idxRight}.pupil_size.Units;
            data{i}.header.sr    =   eye_data_cell{idxRight}.SamplingFrequency;

        elseif strcmp(data{i}.header.chantype(end:end) , 'l')
            data{i}.header.Description = eye_data_cell{idxLeft}.pupil_size.Description;
            data{i}.header.units =   eye_data_cell{idxLeft}.pupil_size.Units;
            data{i}.header.sr    =   eye_data_cell{idxLeft}.SamplingFrequency;
            
        else; warning('Something went wrong no pupil channel!')  % !!!!!
        end
    % gaze
    elseif strcmp(data{i}.header.chantype(1:end-4) , 'gaze')
        if strcmp(data{i}.header.chantype(6) , 'x')
           if strcmp(data{i}.header.chantype(8) , 'r')
               % gaze_x_r
               % data{i}.header.units =  eye_data_cell{idxRight}.SampleCoordinateUnits;  % "pixel"
               data{i}.header.units =  eye_data_cell{idxRight}.x_coordinate.Units;  % should i add a check that x and y are the same units?
               data{i}.header.sr    =  eye_data_cell{idxRight}.SamplingFrequency;
               data{i}.header.r =  [eye_data_cell{idxRight}.GazeRange.xmin, eye_data_cell{idxRight}.GazeRange.xmax] ;    % e.g. [0 1151]
           elseif strcmp(data{i}.header.chantype(8) , 'l')
              % gaze_x_l
               % data{i}.header.units =   eye_data_cell{idxLeft}.SampleCoordinateUnits;
               data{i}.header.units =   eye_data_cell{idxLeft}.x_coordinate.Units; % 
               data{i}.header.sr   =    eye_data_cell{idxLeft}.SamplingFrequency;
               data{i}.header.range =  [eye_data_cell{idxLeft}.GazeRange.xmin, eye_data_cell{idxLeft}.GazeRange.xmax] ;    % e.g. [0 1151]      
           else; warning('Something went worng with gaze  y channels')
           end

        elseif strcmp(data{i}.header.chantype(6) , 'y')
           if strcmp(data{i}.header.chantype(8) , 'r')
               % gaze_y_r
               % data{i}.header.units =   eye_data_cell{idxRight}.SampleCoordinateUnits; 
               data{i}.header.units =   eye_data_cell{idxRight}.y_coordinate.Units; 
               data{i}.header.sr   =    eye_data_cell{idxRight}.SamplingFrequency;
               data{i}.header.range =  [eye_data_cell{idxRight}.GazeRange.ymin, eye_data_cell{idxRight}.GazeRange.ymax] ;    % e.g. [0 1151]
           
           elseif strcmp(data{i}.header.chantype(8) , 'l')
               % gaze_y_l
               % data{i}.header.units =   eye_data_cell{idxLeft}.SampleCoordinateUnits; %'pixel';
               data{i}.header.units =   eye_data_cell{idxLeft}.y_coordinate.Units; %'pixel';
               data{i}.header.sr    =   eye_data_cell{idxLeft}.SamplingFrequency; 
               data{i}.header.range =  [eye_data_cell{idxLeft}.GazeRange.ymin, eye_data_cell{idxLeft}.GazeRange.ymax] ;    % e.g. [0 1151]
                      
           else ; warning('Something went worng with gaze  y channels')
           end
        end
     end
end

%% --- Build the eye infos.source  ----

physio_infos.source = struct();        

% --- infos.source ---
physio_infos.source.channel = {};% {'Column 02'} {'Column 01'} How to add this ???? from the imported files
% nan_stats 
physio_infos.source.chan_stats = cell(length(data), 1); 
for i = 1:length(data)
    n_data = size(data{i}.data, 1);
    n_inv = sum(isnan(data{i}.data));
    physio_infos.source.chan_stats{i,1} = struct();
    physio_infos.source.chan_stats{i,1}.nan_ratio = n_inv / n_data;
end

% % date and time
% infos.source.date = '01.01.1900'; % no information in json
% infos.source.time = '00:00:00'; % no information in json

% gaze_coords % Is the gaze range for both eyes always the same?
if ~isequal(eye_data_cell{idxRight}.GazeRange, eye_data_cell{idxLeft}.GazeRange); warning("GazeRange is not equal"); end % if single eye data it will be equal
physio_infos.source.gaze_coords = eye_data_cell{idxRight}.GazeRange;
physio_infos.source.elcl_proc = eye_data_cell{idxRight}.PupilFitMethod; % or should it be called PupilFitMethod? lowercase!

% eyesObserved and best_eye
if n_eyes == 2
    physio_infos.source.eyesObserved = 'lr'; 
elseif n_eyes == 1  
    physio_infos.source.eyesObserved =  data{1}.header.chantype(end); 
end  

physio_infos.source.best_eye = eye_with_smaller_nan_ratio(data, physio_infos.source.eyesObserved);
physio_infos.source.type = 'BIDS (json/tsv)' ; % needs a standardized data format type name

cell_index = cell_index + 1;
if n_eyes == 2
    % physio_infos.source.file = [eye_data_cell{1}.source.file, eye_data_cell{2}.source.file] ; %  {1},{2} gives the right order
    file_paths{cell_index,1} = eye_data_cell{1}.source.file; 
    file_paths{cell_index+1,1} = eye_data_cell{2}.source.file; 
else
    file_paths{cell_index,1} = eye_data_cell{1}.source.file ;
end  

% add the eye data
physio_data = [physio_data; data];

end % if ests == 1


% Not good change it !!!
if isempty(physio_data)
    error('No data importated')
else;  sts = 1; 
end


% makes a array of channel names
chan_names = cellfun(@(x) x.header.chantype, physio_data, 'UniformOutput', false);

physio_infos.source.file = file_paths;

physio_infos.chan_names = chan_names; 
% physio_info_data.file_paths = file_paths; % make the eye  filenames in the right orientation if it is not there??
% RecordingDuration (eye data) sanity check?





end
% adapted from in pspm_get_viewpoint and pspm_get_smi
function best_eye = eye_with_smaller_nan_ratio(data, eyes_observed)
    if length(eyes_observed) == 1;
      best_eye = lower(eyes_observed);
    else
      eye_L_max_nan_ratio = 0;
      eye_R_max_nan_ratio = 0;
      for i = 1:numel(data)
        left_data = strcmpi(data{i}.header.chantype(end),'l');      
        right_data = strcmpi(data{i}.header.chantype(end),'r');
        
        if left_data
          eye_L_max_nan_ratio = max(eye_L_max_nan_ratio, sum(isnan(data{i}.data)));
        elseif right_data
          eye_R_max_nan_ratio = max(eye_R_max_nan_ratio, sum(isnan(data{i}.data)));
        end
      end

      if eye_L_max_nan_ratio > eye_R_max_nan_ratio
        best_eye = 'r'; 
      else
        best_eye = 'l'; % if equal set 'l'
      end
    end
end