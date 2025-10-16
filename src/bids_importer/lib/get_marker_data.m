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


% logical indexing for not block start and not block end
idx_block = (strcmp(marker_tsv_data_table.event_type, 'block_start') | strcmp(marker_tsv_data_table.event_type, 'block_end'));
% logical indexing for not task_name = 'habituation'
idx_habit = (strcmp(marker_tsv_data_table.task_name, 'habituation'));
idx =  logical(1 - (idx_block | idx_habit));

% onsets, names, and tastnames
onsets = marker_tsv_data_table.onset;
onsets = onsets(idx);
names = marker_tsv_data_table.event_type(idx);


% --------- markerinfo from  tsv ---------


% the format is needed for pspm_check_data it is also under markerinfo
% under the duration event_type
marker_data.data = onsets;
marker_data.markerinfo.name  = names;
[~,~,idxnames] = unique(names,'stable');
marker_data.markerinfo.value = idxnames;

if any(ismember(marker_tsv_data_table.Properties.VariableNames, {'task_name'}))
    marker_data.markerinfo.task_name = marker_tsv_data_table.task_name(idx);
end
% marker_data.duration = onset(end) - onset(1); %  duration of the EVENTS (onset)


% --------- marker header ---------
marker_data.header.chantype = 'marker';
marker_data.header.units = 'events';
marker_data.header.sr = 1; % allways 1 
marker_data.header.StartTime = marker_data.data(1); % onset /
% including start block  not really needed 

end