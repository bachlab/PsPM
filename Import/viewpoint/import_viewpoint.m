function [data] = import_viewpoint(filepath)
    % import_viewpoint is the function for importing raw ViewPoint (.txt) files to
    % usual PsPM structure.
    %
    % FORMAT: [data] = import_viewpoint(filepath)
    %             filepath: Path to the file which contains the recorded ViewPoint
    %                       data in ASCII format.
    %
    %             data: Output cell array of structures. Each entry in the cell array
    %                   corresponds to one recording session (trial) in the datafile.
    %                   Each of these structures have the following entries:
    %
    %                       dataraw: Cell array containing raw data columns.
    %                       dataraw_header: Column headers of each raw data column.
    %                       channels: Matrix (timestep x n_cols) of relevant PsPM columns.
    %                       channels_header: Column headers of each channels column.
    %                       channels_units: Units of each channels column.
    %                       eyesObserved: Either A or AB, denoting observed eyes in datafile.
    %                       ViewingDistance: Viewing distance in milimeters.
    %                       screenSize: Structure with fields
    %                           - xmin: x coordinate of top left corner of screen in milimeters.
    %                           - ymin: y coordinate of top left corner of screen in milimeters.
    %                           - xmax: x coordinate of bottom right corner of screen in milimeters.
    %                           - ymax: y coordinate of bottom right corner of screen in milimeters.
    %                       marker: Structure with fields
    %                           - names: Cell array of marker names.
    %                           - pos: Indices of markers in time column.
    %                           - times: Seconds of markers.
    %                           - mod: Marker mod (sync or async)
    %                       record_date: Recording date
    %                       record_time: Recording time
    %
    %__________________________________________________________________________
    %
    % (C) 2019 Laure Ciernik
    % Function inspired by GazeAlyze ©.

    % check for the existence of file
    if ~exist(filepath,'file')
        warning('ID:invalid_input', 'Passed file does not exist.'); return;
    end

    %% open sample_file
    fID = fopen(filepath);
    fline = fgetl(fID);
    %% get header
    headr_ctr = 1;
    max_len=0;
    idx_max=0;
    while ~startsWith(fline,'10') || headr_ctr<24
        str = strsplit(fline,'\t');
        if length(str)>max_len && ~startsWith(str{1},'10')
            max_len=length(str);
            idx_max=headr_ctr;
        end
        headr_ctr = headr_ctr + 1;
        fline = fgetl(fID);
    end
    headr_ctr=headr_ctr-1;
    formatSpec = repmat('%s',1,max_len);
    frewind(fID);
    header = textscan(fID,formatSpec,headr_ctr);
    header=[header{:}];
    %% process header (insert in data struct later)
    % Date
    [idx,idy] = find(cell2mat(cellfun(@(x) strncmpi(x,'TimeValues',10),header,'UniformOutput',0)));
    record_date =[header(idx,idy+3),header(idx,idy+2),header(idx,idy+1)];
    record_date = cellfun(@(x) [x,'.'],record_date,'UniformOutput', false);
    record_date{end}=record_date{end}(1:4);
    record_date = [record_date{:}];
    % Time
    record_time =header{idx+1,idy+5};
    % gaze information
    [idx,idy] = find(cell2mat(cellfun(@(x) strncmpi(x,'ScreenSize',10),header,'UniformOutput',0)));
    screenSize.xmin=0;
    screenSize.ymin=0;
    screenSize.xmax= str2double(header{idx,idy+1});
    screenSize.ymax= str2double(header{idx,idy+2});

    % eyetracker distance
    [idx,idy] = find(cell2mat(cellfun(@(x) strncmpi(x,'ViewingDistance',15),header,'UniformOutput',0)));
    ViewingDistance = str2double(header{idx,idy+1});

    % eyes observed and fix order of getting data
    columns= header(idx_max,2:end);
    Eye_A = cell2mat(cellfun(@(x)startsWith(x,'A'),columns,'UniformOutput',false));
    Eye_B = cell2mat(cellfun(@(x)startsWith(x,'B'),columns,'UniformOutput',false));
    if any(Eye_A)&& any(Eye_B)
        eyesObserved = 'AB';
        col_idx =[2,3,7,16,4,5,13,14];
        channels_header = {'Time','pupil_A','pupil_B','gaze_x_A','gaze_y_A','gaze_x_B','gaze_y_B'};
        channels_units = {'seconds','ratio','ratio','ratio','ratio','ratio','ratio'};
    else
        eyesObserved = 'A';
        col_idx = [2,3,7,4,5];
        channels_header = {'Time','pupil_A','gaze_x_A','gaze_y_A'};
        channels_units = {'seconds','ratio','ratio','ratio'};
    end
    %% get data columns
    % remember position where data recording start
    pos = ftell(fID);
    % get type and total time columns
    type_time = textscan(fID, '%d8%f32%*[^\n]');
    tag_type = type_time{1};
    tot_time = type_time{1,2};

    % look for asynchronous marker
    async_mrk = tag_type==12;
    async_sn = tag_type==2;
    % get 3rd column for potential asynchronous marker
    fseek(fID,pos,'bof');
    markval = textscan(fID, '%*d8%*f32%s%*[^\n]');

    % set file pointer back to beginning of data
    fseek(fID,pos,'bof');
    %% find nr.of columns and specify their units
    data_format ='%f';
    for i=1:numel(columns)
        tmp = columns{i};
        if contains(tmp,{'RI','STR','MRK'})
            data_format = [data_format ' %s'];

        else
            data_format = [data_format ' %f'];
        end
    end

    %% distinguish reading method based on synchronous or asynchronous methods.
    % In the asynchronous setting no existance of MRK column
    % session starts are indicated by '+' and session  stop by '='
    % for each method we have to separate the sessions:
    % - synchronous: session indicator are stored in the MRK channel.
    % - asynchronous: session indicator are stored in data lines with tag 2
    % First need to find the session, then iterate over session and save the data
    if isempty(find(async_mrk,1))
        % get whole data
        datastr = textscan(fID, data_format);
        data_len = size(datastr{1,3},1);
        % get marker column to split the sessions
        mrk = find(cell2mat(cellfun(@(x) strncmpi(x,'MRK',3),columns,'UniformOutput',0)));
        mrk=mrk+1;
        marker_col = datastr(mrk);
        marker_col= [marker_col{:}];
        % set file pointer back to beginning of data
        fseek(fID,pos,'bof');
        % get onsets
        idx_onsets = cell2mat(cellfun(@(x)contains(x,'+'), marker_col,'uniformoutput',0));
        % get offsets
        idx_offsets = cell2mat(cellfun(@(x)contains(x,'='), marker_col,'uniformoutput',0));
        on_offsets = get_onsets_offset_pair(idx_onsets,idx_offsets);
        nr_sn = size(on_offsets,1);
        data = cell(nr_sn,1);
        % iterate over sessions and read in data
        for sn = 1:nr_sn
            % fix maker mode
            data{sn}.marker.mod = 'sync';
            % add header information to data
            data{sn}.record_date      = record_date;
            data{sn}.record_time      = record_time;
            data{sn}.screenSize       = screenSize;
            data{sn}.ViewingDistance  = ViewingDistance;
            data{sn}.eyesObserved     = eyesObserved;
            data{sn}.channels_header  = channels_header;
            data{sn}.channels_units   = channels_units;

            % get start and stop
            onset  = on_offsets(sn,1);
            offset = on_offsets(sn,2);

            % save the raw data (all columns) in the data struct
            data{sn}.dataraw = cell(size(datastr));
            for k=1:length(datastr)
                data{sn}.dataraw{k} = datastr{k}(onset:offset,:);
            end
            sn_length = size(data{sn}.dataraw{1},1);
            data{sn}.dataraw_header = header(idx_max+1,2:end);

            % get pupil and gaze data channels (time channels included)
            channels = data{sn}.dataraw(:,col_idx);
            data{sn}.channels=[channels{:}];
            idx_0 = find(data{sn}.channels(:,1)==0);
            if ~isempty(idx_0)
                idx_0(idx_0==1) = [];
                data{sn}.channels(idx_0,1) = data{sn}.channels(idx_0-1,1) + (data{sn}.channels(idx_0-1,2)/1000);
            end
            data{sn}.channels(:,2)=[];
            col_idx(2) = [];
            col_idx = col_idx - 1;
            data{sn}.channel_indices = col_idx;
            % Find all markers in marker column and save the value, the occurence
            % time and the the positions
            MRK=[];
            for l=mrk:size(data{sn}.dataraw,2)
                MRK = strcat(MRK,data{sn}.dataraw{1,l}(1:sn_length));
            end
            markIndxall = find(~strcmp(MRK,''));
            data{sn}.marker.names=MRK(markIndxall);
            names=unique(data{sn}.marker.names);
            % only take valid markers, i.e., markers without starting/ending
            % value
            % 0 in values  marker, includes starting or ending
            val_names = cell2mat(cellfun(@(x)~any(contains(x,{'=','+'})),names,'uniformoutput',false));
            val_names=names(val_names);
            data{sn}.marker.values=zeros(length(data{sn}.marker.names),1);
            for k=1:length(val_names)
                for l=1:length(markIndxall)
                    if strcmpi(val_names{k},data{sn}.marker.names{l})
                        data{sn}.marker.values(l)=k;
                    end
                end
            end
            data{sn}.marker.pos = markIndxall;
            %timepoints of all markers
            data{sn}.marker.times = data{sn}.channels(markIndxall,1);
            % delete type column of dataraw
            data{sn}.dataraw(1)=[];
        end
    else
        % safe asynchronous marker values and times. The values are saved in
        % the third column of the data
        marker_col=markval{1};
        % get onsets
        idx_onsets = cell2mat(cellfun(@(x)contains(x,'+'), marker_col,'uniformoutput',0));
        % get offsets
        idx_offsets = cell2mat(cellfun(@(x)contains(x,'='), marker_col,'uniformoutput',0));
        on_offsets = get_onsets_offset_pair(idx_onsets,idx_offsets);
        nr_sn = size(on_offsets,1);
        data = cell(nr_sn,1);

        for sn=1:nr_sn
            % helper row counter for textscan
            row_counter = 0;
            % fix maker mode
            data{sn}.marker.mod = 'async';
            % add header information to data
            data{sn}.record_date      = record_date;
            data{sn}.record_time      = record_time;
            data{sn}.screenSize       = screenSize;
            data{sn}.ViewingDistance  = ViewingDistance;
            data{sn}.eyesObserved     = eyesObserved;
            data{sn}.channels_header  = channels_header;
            data{sn}.channels_units   = channels_units;

            % get start and stop
            onset  = on_offsets(sn,1);
            offset = on_offsets(sn,2);
            sn_length = offset-onset +1;

            % create mask for valid marker in this session
            val_data = zeros(length(marker_col),1);
            val_data(onset:offset)=1;
            val_mrk = (async_mrk | async_sn) & val_data;
            data{sn}.marker.names  = marker_col(val_mrk);
            data{sn}.marker.times  = tot_time(val_mrk);
            data{sn}.marker.pos    = val_mrk;
            % set for each valid marker an ID
            names=unique(data{sn}.marker.names);
            val_names = cell2mat(cellfun(@(x)~any(contains(x,{'=','+'})),names,'uniformoutput',false));
            val_names=names(val_names);
            data{sn}.marker.values=zeros(length(data{sn}.marker.names),1);
            for k=1:length(val_names)
                for l=1:length(data{sn}.marker.names)
                    if strcmpi(val_names{k},data{sn}.marker.names{l})
                        data{sn}.marker.values(l)=k;
                    end
                end
            end
            % find data sections between asynchronous markers in this session
            good_mrk = find(val_mrk);
            datsect=diff(good_mrk);
            % set file pointer to correct location, i.e. to beginning of
            % session
            textscan(fID,data_format,onset-1);
            % scipping onset marker
            textscan(fID, '%*[^\n]',1);
            % get first data segment
            datastr = textscan(fID,data_format,datsect(1)-1);
            % scipping marker
            textscan(fID, '%*[^\n]',1);
            for i=2:length(datsect)
                helper  = textscan(fID, data_format,datsect(i)-1);
                for j = 1:length(datastr)
                    datastr{:,j} = [datastr{:,j};helper{:,j}];
                end
                textscan(fID, '%*[^\n]',1);
            end
            % save the raw data (all columns) in the data struct
            data{sn}.dataraw = datastr;
            data{sn}.dataraw_header = header(idx_max+1,2:end);
            channels = data{sn}.dataraw(:,col_idx);
            % get pupil and gaze data channels (time channels included)
            data{sn}.channels=[channels{:}];
            idx_0 = find(data{sn}.channels(:,1)==0);
            if ~isempty(idx_0)
                idx_0(idx_0==1) = [];
                data{sn}.channels(idx_0,1) = data{sn}.channels(idx_0-1,1) + (data{sn}.channels(idx_0-1,2)/1000);
            end
            data{sn}.channels(:,2)=[];
            col_idx(2) = [];
            col_idx = col_idx - 1;
            data{sn}.channel_indices = col_idx;
        end
    end
    fclose(fID);
end

function [idx_on_offsets] = get_onsets_offset_pair(onsets,offsets)
    % input checks
    if ~any(onsets)
        idx_onsets = 1;
    else
        idx_onsets = find(onsets);
    end
    if ~any(offsets)
        idx_offsets = length(offsets);
    else
        idx_offsets = find(offsets);
    end
    idx_on_offsets = zeros(length(idx_onsets),2);
    for i=1:length(idx_onsets)
        idx_on_offsets(i,1) = idx_onsets(i);
        tmp = find(idx_onsets(i)<idx_offsets,1);
        if isempty(tmp)
            idx_on_offsets(i,2) = length(offsets);
            continue
        end
        idx_on_offsets(i,2) = idx_offsets(tmp);
    end
end
