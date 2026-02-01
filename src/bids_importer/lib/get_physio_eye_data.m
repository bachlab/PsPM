function [sts , data, infos] = get_physio_eye_data(subject_id, session_id, task_name, physio_eye_path)
sts = -1;
data = {}; 
infos = struct();
infos.source = struct();
infos.source.file = struct();
file_paths  = {};

%% % Process eye data

[ests , eye_data_cell] = get_eyetrack_data(subject_id, session_id, task_name, physio_eye_path);

if ests == 1
    
%% --- Add the eye data to the channels --- 
num_eyes = length(eye_data_cell);
switch num_eyes
    case 0; warning('No eye data available.');        
    case 1
        eyeSide = lower(eye_data_cell{1}.RecordedEye);
        warning('Only %s eye data available.', eyeSide);  

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
    
        elseif strcmp(eyeSide, 'left')
            pupil_l  = eye_data_cell{1}.Columns{:,'pupil_size'};
            gaze_x_l = eye_data_cell{1}.Columns{:,'x_coordinate'};
            gaze_y_l = eye_data_cell{1}.Columns{:,'y_coordinate'};
      
            data{1}.data  = pupil_l;
            data{1}.header.chantype  = 'pupil_l';
            data{2}.data  = gaze_x_l;
            data{2}.header.chantype  = 'gaze_x_l';
            data{3}.data  = gaze_y_l;
            data{3}.header.chantype  = 'gaze_y_l';

        else 
            warning('Unknown RecordedEye eye_data_cell.'); 
            return
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

% For one eye 
if num_eyes == 1; idxRight = 1; idxLeft  = 1; end 

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
            
        else 
            warning('No valid pupil channel found.');
        end
    % gaze
    elseif strcmp(data{i}.header.chantype(1:end-4) , 'gaze')
        if strcmp(data{i}.header.chantype(6) , 'x')
           if strcmp(data{i}.header.chantype(8) , 'r')
               % gaze_x_r
               if  any(strcmp(fieldnames(eye_data_cell{idxRight}),'SampleCoordinateUnits'))
                   data{i}.header.units =  eye_data_cell{idxRight}.SampleCoordinateUnits;  % "pixel"
               elseif  any(strcmp(fieldnames(eye_data_cell{idxRight}),'x_coordinate'))
                   data{i}.header.units =  eye_data_cell{idxRight}.x_coordinate.Units;  
               else
                   warning('ID:missing_units', 'Units could not be determined for gaze_x_r channel.');
               end

               data{i}.header.sr    =  eye_data_cell{idxRight}.SamplingFrequency;
               data{i}.header.range =  [eye_data_cell{idxRight}.GazeRange.xmin, eye_data_cell{idxRight}.GazeRange.xmax] ;    % e.g. [0 1151]
           elseif strcmp(data{i}.header.chantype(8) , 'l')
               % gaze_x_l     
               if  any(strcmp(fieldnames(eye_data_cell{idxLeft}),'SampleCoordinateUnits'))
                   data{i}.header.units =  eye_data_cell{idxLeft}.SampleCoordinateUnits;  % "pixel"
               elseif  any(strcmp(fieldnames(eye_data_cell{idxLeft}),'x_coordinate'))
                   data{i}.header.units =  eye_data_cell{idxLeft}.x_coordinate.Units;  
               else
                   warning('ID:missing_units', 'Units could not be determined for gaze_x_l channel.');
               end   

               data{i}.header.sr   =    eye_data_cell{idxLeft}.SamplingFrequency;
               data{i}.header.range =  [eye_data_cell{idxLeft}.GazeRange.xmin, eye_data_cell{idxLeft}.GazeRange.xmax] ;    % e.g. [0 1151]      
           else
               warning('Something went worng with gaze  x channels')
           end

        elseif strcmp(data{i}.header.chantype(6) , 'y')
           if strcmp(data{i}.header.chantype(8) , 'r')
               % gaze_y_r
              if  any(strcmp(fieldnames(eye_data_cell{idxRight}),'SampleCoordinateUnits'))
                   data{i}.header.units =  eye_data_cell{idxRight}.SampleCoordinateUnits;  % "pixel"
              elseif  any(strcmp(fieldnames(eye_data_cell{idxRight}),'y_coordinate'))
                   data{i}.header.units =  eye_data_cell{idxRight}.y_coordinate.Units; 
              else
                   warning('ID:missing_units', 'Units could not be determined for gaze_y_r channel.');
              end
              data{i}.header.sr   =    eye_data_cell{idxRight}.SamplingFrequency;
              data{i}.header.range =  [eye_data_cell{idxRight}.GazeRange.ymin, eye_data_cell{idxRight}.GazeRange.ymax] ;    % e.g. [0 1151]
           
           elseif strcmp(data{i}.header.chantype(8) , 'l')
               % gaze_y_l
              if  any(strcmp(fieldnames(eye_data_cell{idxLeft}),'SampleCoordinateUnits'))
                   data{i}.header.units =  eye_data_cell{idxLeft}.SampleCoordinateUnits;  % "pixel"
              elseif  any(strcmp(fieldnames(eye_data_cell{idxLeft}),'y_coordinate'))
                   data{i}.header.units =  eye_data_cell{idxLeft}.y_coordinate.Units;  % should i add a check that x and y are the same units?
              else
                   warning('ID:missing_units', 'Units could not be determined for gaze_y_l channel.');
              end

              data{i}.header.sr    =   eye_data_cell{idxLeft}.SamplingFrequency; 
              data{i}.header.range =  [eye_data_cell{idxLeft}.GazeRange.ymin, eye_data_cell{idxLeft}.GazeRange.ymax] ;    % e.g. [0 1151]
                      
           else 
               warning('Something went worng with gaze  y channels')
           end
        end
     end
end

%% --- Build the eye infos.source  ----
 
% --- infos.source ---
infos.source = struct();  
infos.source.chan = {} ;% {'Column 02'} {'Column 01'}?
infos.source.chan_stats = cell(length(data), 1); % nan_stats 

% Calculating the nan ratio
for i = 1:length(data)
    n_data = size(data{i}.data, 1);
    n_inv = sum(isnan(data{i}.data));
    infos.source.chan_stats{i,1} = struct();
    infos.source.chan_stats{i,1}.nan_ratio = n_inv / n_data;
end

if ~isequal(eye_data_cell{idxRight}.GazeRange, eye_data_cell{idxLeft}.GazeRange)
    warning("GazeRange is not equal"); 
end 

infos.source.gaze_coords = eye_data_cell{idxRight}.GazeRange; 
                 
if  any(strcmp(fieldnames(eye_data_cell{idxRight}),'PupilFitMethod'))
    infos.source.elcl_proc = lower(eye_data_cell{idxRight}.PupilFitMethod); % or should it be called PupilFitMethod? lowercase!
elseif  any(strcmp(fieldnames(eye_data_cell{idxRight}),'ElclProc'))
    infos.source.elcl_proc = lower(eye_data_cell{idxRight}.ElclProc); % like in the Calinet dataset
end

% eyesObserved and best_eye
if num_eyes == 2
    infos.source.eyesObserved = 'lr'; 
elseif num_eyes == 1  
    infos.source.eyesObserved =  data{1}.header.chantype(end); 
end  

infos.source.best_eye = eye_with_smaller_nan_ratio(data, infos.source.eyesObserved);
infos.source.type = 'BIDS (json/tsv)' ;


if num_eyes == 2
    % physio_infos.source.file = [eye_data_cell{1}.source.file, eye_data_cell{2}.source.file] ; %  {1},{2} gives the right order
    file_paths{1,1} = eye_data_cell{1}.source.file; 
    file_paths{2,1} = eye_data_cell{2}.source.file; 
else
    file_paths{1,1} = eye_data_cell{1}.source.file ;
end  



% Check if the first data has the StartTime field
if isfield(data{1}.header, 'StartTime')
    % Check if all StartTimes are the same
    start_times = cellfun(@(x) x.header.StartTime, data, 'UniformOutput', false);
    if ~isequal(start_times{:}) ; warning('Not all data have the same StartTime. Please check the input data.');  end
else 
    % If there is no StartTime field start time will set to 0
    for i = 1:length(data); data{i}.header.StartTime = 0; end 
end

else
    warning('No data for physio eye data was imported.');
end % if ests == 1






%% Process physio eye event data -> header eyedata maybe somewhere else?

events_json_filename = sprintf('%s_ses-%s_task-%s_physioevents.json', subject_id, session_id, task_name);
events_tsv_filename  = sprintf('%s_ses-%s_task-%s_physioevents.tsv', subject_id, session_id, task_name);
events_json_filepath = fullfile(physio_eye_path, events_json_filename);
events_tsv_filepath  = fullfile(physio_eye_path, events_tsv_filename);

% Checks if the event files exist
if ~isfile(events_json_filepath) || ~isfile(events_tsv_filepath)
    warning('No physio events for task "%s" in %s. Skipping event processing.', task_name, physio_eye_path); 
else
    % Imports the eye event data
    data_events = get_physio_events_data(events_json_filepath,events_tsv_filepath,false); % has ColumnField
    
    % Gives the events the StartTime time as the eye data
    if ~isempty(data) % if there are eye data but eye_events 
        for i = 1:length(data_events);  data_events{i}.header.StartTime = data{1}.header.StartTime; end
    end
    file_paths{end+1,1} = {events_json_filepath,events_tsv_filepath}; 
    data = [ data; data_events];
end %

%%

if isempty(data)
    warning('No physio eye event data has been imported.');
    return
end

sts = 1; 
infos.source.file = file_paths;
return


end

% adapted from in pspm_get_viewpoint and pspm_get_smi
function best_eye = eye_with_smaller_nan_ratio(data, eyes_observed)
    if length(eyes_observed) == 1
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

function data = get_physio_events_data(events_json_filepath, events_tsv_filepath, noColumnField)
sr = 1; % default
has_headings = true;
% better way?
data{1,1}.data.header = struct();
data{2,1}.data.header = struct();
data{3,1}.data.header = struct();

col_types = {'double', 'double', 'char', 'char', 'char'};
    
% Get the event json
event_json = extract_json_as_struct(events_json_filepath);

if noColumnField 
    headings = fieldnames(event_json).';
elseif isfield(event_json, 'Columns')
    headings = event_json.Columns;
else
    headings = [];
end

% Get marker tsv data
marker_tsv_data_table = read_data_from_tsv(events_tsv_filepath, has_headings, headings, col_types );


% Checks if it is a proper physio eye event data
if ~any(ismember(marker_tsv_data_table.Properties.VariableNames, {'blink','message'}))   
    warining('No physio events')
    data = -1;
    return ;
end


idx_header = strcmp(marker_tsv_data_table.event_type, 'n/a') & ~strcmp(marker_tsv_data_table.message, 'CS'); 

idx_data = ~idx_header; 


% Find Record Configuration
indices_reccfg = find(contains(marker_tsv_data_table.message, 'RECCFG')); % find Record Configuration
reccfg = split(marker_tsv_data_table.message(indices_reccfg));
sr = str2double(reccfg{3});
eyes = reccfg{6}; % could be used in the future to choose the rigth blink channel


% Set first measurment to zero
onsets = marker_tsv_data_table.onset(idx_data); 
onsets = (onsets - onsets(1));  % shifting onset times
duration = marker_tsv_data_table.duration(idx_data);
event_type = marker_tsv_data_table.event_type(idx_data); % including CS (NaN) will be excluted later

signal = {'blink','saccade','fixation'};
singal_chan = {'blink_c','saccade_c','fixation_c'};

for s = 1:numel(signal)

% Index of the onsets of the signal
idx_signal = find(strcmp(event_type, signal{1})); % excludes NaNs

% get onset start to onset end(onset+duration)
starts = onsets(idx_signal);
ends  = onsets(idx_signal) + duration(idx_signal);

all_indices = [];
for i = 1:length(starts);  all_indices = [all_indices, starts(i):ends(i)]; end 

idx_signal = unique(all_indices); %  removes overlaps 
data_signal  = zeros(idx_signal(end),1); 

for i = 1:length(idx_signal); data_signal(idx_signal(i),1) = 1; end % Map values to these indices (set them to 1)
if ~(sum(data_signal) == length(idx_signal)); warning('Not same length.'); return; end % sanitiy check




% assign pupil data
data{s,1}.data = data_signal; 
% add header
data{s,1}.header.chantype = singal_chan{s}; 
data{s,1}.header.units = signal{s};
data{s,1}.header.sr = sr;
data{s,1}.header.StartTime = onsets(1)/sr; % to get it in secondes


end
end