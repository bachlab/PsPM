function marker_data = get_marker_data(events_json_filepath, events_tsv_filepath, noColumnField)
sr = 1; % default
has_headings = true;
marker_data.header = struct();

col_types = {'double', 'double', 'char', 'char', 'char'};
    
% Get the marker json
marker_json = extract_json_as_struct(events_json_filepath);

if noColumnField 
    headings = fieldnames(marker_json).';
elseif isfield(marker_json, 'Columns')
    headings = marker_json.Columns;
else
    headings = []; % should not happen what happens later the??
end




% Get marker tsv data
marker_tsv_data_table = read_data_from_tsv(events_tsv_filepath, has_headings, headings, col_types );

% onsets = zeros(size(marker_tsv_data_table.onset)); % needed?




% If physioevents sr needs to be extracted
if any(ismember(marker_tsv_data_table.Properties.VariableNames, {'blink','message'}))   % only if pyhsioevents
      
       
      idx_header = strcmp(marker_tsv_data_table.event_type, 'n/a') & ~strcmp(marker_tsv_data_table.message, 'CS');

      idx_marker = ~idx_header; % marker without header but with CS
      % indices_CS = setdiff(indices , indices_na);   % what is CS?

      % find Record Configuration
      indices_reccfg = find(contains(marker_tsv_data_table.message, 'RECCFG')); % find Record Configuration
      reccfg = split(marker_tsv_data_table.message(indices_reccfg));
      sr = str2double(reccfg{3});


      onsets = marker_tsv_data_table.onset(idx_marker); 
      onsets = (onsets - onsets(1)) / sr; % addjust SR????
      names = marker_tsv_data_table.event_type(idx_marker); % including CS
else

    onsets = marker_tsv_data_table.onset(2:end-1); % fix
    names = marker_tsv_data_table.event_type(2:end-1);

end








% --------- markerinfo from  tsv ---------


% the format is needed for pspm_check_data it isalso under markerinfo
% under the duration event_type
marker_data.data = onsets;
marker_data.markerinfo.name  = names;
[~,~,idxnames] = unique(names,'stable');
marker_data.markerinfo.value = idxnames;


% marker_data.duration = onset(end) - onset(1); %  duration of the EVENTS (onset)


% --------- marker header ---------
marker_data.header.chantype = 'marker';
marker_data.header.units = 'events';

marker_data.header.sr = 1; % allways 1 bc the onsets/sr

marker_data.header.StartTime = marker_data.data(1); % onset /
% including start block  not really needed 

end