function marker_data = get_marker_data(events_json_filepath, events_tsv_filepath, noColumnField)

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

    % marker_json.Columns{5}(1)
    
    % --------- onsets (data) ---------

    onsets = zeros(size(marker_tsv_data_table.onset));

    % Iterate through each element in the onsets cell array
    for i = 1:numel(marker_tsv_data_table.onset)
        onsets(i) = marker_tsv_data_table.onset(i); 
    end
    marker_data.data = onsets;
    % Should the start and end blocks be remove??


    % --------- markerinfo from  tsv ---------


    % the format is needed for pspm_check_data it isalso under markerinfo
    % under the duration event_type
    names = marker_tsv_data_table.event_type;
    marker_data.markerinfo.name  = names;
    [~,~,idxnames] = unique(names,'stable');
    marker_data.markerinfo.value = idxnames;


    % marker_data.duration = onset(end) - onset(1); %  duration of the EVENTS (onset)


    % --------- marker header ---------
    marker_data.header.chantype = 'marker';
    marker_data.header.units = 'events';
    marker_data.header.sr = 1; % is needed for pspm_check_data
    marker_data.header.StartTime = marker_data.data(1); % onset /
    % including start block  not really needed 

end