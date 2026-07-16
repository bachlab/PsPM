function marker_data = get_marker_data(events_json_filepath, events_tsv_filepath, noColumnField)

has_headings = true;
marker_data.header = struct();

col_types = {'double', 'double', 'char', 'char', 'char'};
    
% Get the marker json
marker_json = extract_json_as_struct(events_json_filepath);

sts = check_stimulus_presentation_fields(marker_json);
if sts < 1
    marker_data = [];
    return
end

if ~noColumnField 
    headings = fieldnames(marker_json).';
elseif isfield(marker_json, 'Columns')
    headings = marker_json.Columns;
else
    headings = []; 
end

% Get marker tsv data
marker_tsv_data_table = read_data_from_tsv( ...
    events_tsv_filepath, ...
    has_headings, ...
    headings, ...
    col_types ...
);

% --------- markerinfo from  tsv ---------
marker_data.data = marker_tsv_data_table.onset;
names = marker_tsv_data_table.event_type;
marker_data.markerinfo.name  = names;
[~,~,idxnames] = unique(names,'stable');
marker_data.markerinfo.value = idxnames;

% Imports task_names if available
if any(ismember(marker_tsv_data_table.Properties.VariableNames, {'task_name'}))
    marker_data.markerinfo.task_name = marker_tsv_data_table.task_name;
end


% --------- marker header ---------
marker_data.header.chantype = 'marker';
marker_data.header.units = 'events';
marker_data.header.sr = 1; % allways 1 
marker_data.header.StartTime = marker_data.data(1); 




end