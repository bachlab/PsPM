function [data] = import_eyelink(filename)
% 
% FORMAT:
% data = import_eyelink(filename)
%   filename:   path to the file which contains the recorded eyelink data 
%               in asc file format
%
% (C) Christoph Korn & Tobias Moser (University of Zurich)
%__________________________________________________________________________
% PsPM 3.1
%
% $Id: import_eyelink.m 450 2017-07-03 15:17:02Z tmoser $
% $Rev: 450 $


%% Notes for data structure
% in col 1    : 'SFIX', 'EFIX', 'SSAC', 'ESAC', 'SBLINK', 'EBLINK', 'END', 'INPUT', 'MSG'
% in col 2/3/4: 'L', 'C', 'R', ' .', 'SAMPLES', 'EVENTS' 
% if you have less columns in textscan it will break some very long lines &
% have more lines than there are!


%% open file with all colums as %s to get messages etc

% determine number of header lines
fileID = fopen(filename);
datastr = textscan(fileID, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s', 'delimiter', '\t'); 

%% correct column lengths (sometimes the end not properly ended)
% get lengths
len_s = cellfun(@(x) length(x), datastr);
min_len = min(len_s);
if any(len_s ~= min_len)
    warning(['Data file has different number of columns. ', ...
        'Maybe recording hasn''t been properly ended. ',...
        'The file will be trimmed to the shortest column.']);
end;
for i=1:length(datastr)
    delta = length(datastr{i}) - min_len;
    if delta ~= 0
        warning('Cutting away %i row(s) in column %i.\n', [delta, i]);
    end;
    datastr{i} = datastr{i}(1:min_len);
end;

%% convert to normal cell (not cell of cell)
datastr = [datastr{:}];

%% process file header
% cut away file header
fheader_pos = strncmpi(datastr(:,1), '**', 2);
fheader = datastr(fheader_pos, :);

% remove header from datastr
datastr(fheader_pos, :) = [];

% try to get the record date
datePos = strncmpi(fheader, '** DATE', 6);
dateFields = regexp(fheader{datePos}, '\s+', 'split');
record_date = strtrim(sprintf('%s ', dateFields{[3:5,length(dateFields)]}));
record_time = dateFields{6};

%% try to find out number of recordings / sessions and split
offsets = find(strcmpi(datastr(:,1), 'END'));
if isempty(offsets)
    warning('Cannot find END of file. Assuming last line of file.');
    offsets = length(datastr(:, 1));
end;
onsets = [1; offsets + 1];

data = cell(numel(offsets),1);

for sn = 1:numel(offsets)
    data{sn} = struct(); 
    data{sn}.record_date = record_date;
    data{sn}.record_time = record_time;
       
    sn_data = datastr(onsets(sn):offsets(sn), :);
    % convert data to numeric
    datanum = str2double(sn_data(:, 1:7));
    
    % if NaN in first column put NaN in all others
    datanum(isnan(datanum(:,1)),:) = NaN;
    dataFields = find(~isnan(datanum(:, 1)));

    %% try to read some header information
    % read the PUPIL unit
    pupilPos = strncmpi(sn_data, 'PUPIL', 5);
    pupilUnit = lower(sn_data{pupilPos,2});

    % header stops where the data section starts
    dataStartPos = dataFields(1);
    
    % look for MSG in header section
    headerMsgPos = find(strncmpi(sn_data(1:dataStartPos), 'MSG', 3));
    
    for i=1:length(headerMsgPos)
        headerFields = regexp(sn_data{headerMsgPos(i),2}, '\s+', 'split');
        % the second field contains the field name
        % the first field contains a timestamp
        fieldName = headerFields{2};
        switch fieldName
            case 'RECCFG'
                % this field contains the samplerate #4
                % and whether both eyes or just one have been recorded #7
                % which is either LR or L or R
                data{sn}.sampleRate = str2double(headerFields{4});
                data{sn}.eyesObserved = headerFields{7};
            case 'GAZE_COORDS'
                data{sn}.gaze_coords.xmin = str2double(headerFields{3});
                data{sn}.gaze_coords.ymin = str2double(headerFields{4});
                data{sn}.gaze_coords.xmax = str2double(headerFields{5});
                data{sn}.gaze_coords.ymax = str2double(headerFields{6});
            case 'ELCL_PROC'
                data{sn}.elcl_proc = headerFields{3};
        end;
    end;
    
    % remove MSG headers not to identify them as other MSG
    sn_data(headerMsgPos,:) = [];
    
    %% identify saccades/blinks
    % note: blinks are always surrounded by saccades, therefore use saccades
    % find L and R saccades
    % saccades = {'SSACC L','ESACC L','SSACC R','ESACC R'};
    saccades = {'SBLINK L','EBLINK L','SBLINK R','EBLINK R'};
    str_sacc = zeros(size(sn_data,1),size(saccades,2));
    for j = 1:size(saccades,2)
        str_sacc(:,j) = strncmp(saccades{j}, sn_data(:,1), 8); %% LAST NUMBER GIVES NUMBER OF CHARACTERS
    end
    str_sacc_pos = cell(1,size(saccades,2));
    for h = 1:size(saccades,2)
        str_sacc_pos{h} = find(str_sacc(:,h));
    end

    %% add saccade information as extra colum to relevant data
    blink_offset =  floor( 0.05 * data{sn}.sampleRate ); % possibility to remove more; correponds to 10 points for sr of 500
    
    % cycle through eyes
    for i=1:numel(data{sn}.eyesObserved)
        
        if strcmpi(data{sn}.eyesObserved(i), 'L')
            corr = 0;
            idx = 8;
        else
            corr = 2;
            idx = 9;
        end;
        
        sblink = 1 + corr;
        eblink = 2 + corr;
        
        
        for k = 1:length(str_sacc_pos{sblink})
            if str_sacc_pos{eblink}(k) + blink_offset > size( datanum, 1 ) && str_sacc_pos{sblink}(k) - blink_offset <= 0
                datanum(1 : end, idx) = 1;
            elseif str_sacc_pos{eblink}(k) + blink_offset > size( datanum, 1 )
                datanum(str_sacc_pos{sblink}(k) - blink_offset : end, idx) = 1;
            elseif str_sacc_pos{sblink}(k) - blink_offset <= 0
                datanum(1 : str_sacc_pos{eblink}(k) + blink_offset, idx) = 1;
            else
                datanum(str_sacc_pos{sblink}(k) - blink_offset : str_sacc_pos{eblink}(k) + blink_offset, idx) = 1;
            end
        end;
    end;
    
    %% identify messages
    % translate MSG into double
    % look for general (gen) positions of MSG fields
    % look for specific (spe) MSG text and add it to a additional column to the
    % gen pos
    
    % the MSG text is also translated into double and later translated back
    % into a text. for this purpose messages is used.
    str_gen = strncmp('MSG', sn_data(:,1), 3);
    str_gen_pos = find(str_gen);
    msg_str = sn_data(str_gen_pos,2);
    messages = unique(regexprep(msg_str, '[0-9]+\s(.*)', '$1'));
    
    % we assume each MSG has a specific text message
    str_spe_pos = zeros(length(str_gen_pos), 1);
    for j = 1:size(messages,1)
        for m = 1:size(str_gen_pos,1)
            %s = regexp(datastr{1,2}{str_gen_pos(m,1),1}, ...
            s = regexp(sn_data{str_gen_pos(m,1),2}, ...
                strcat('[0-9]\s',messages(j)), 'once');
            if s{1} > 0
                str_spe_pos(str_gen_pos(m,1),1) = j;
            end;
        end;
    end;
    
    %% add message information as extra colum to relevant data
    % has to be added in next line (which is not a text line --> to do)
    % HERE: correction
    % 1.    check whether elements of vector of messages_plus_1 are also members of
    %       the vector containing NaN
    % 2.    loop (with increasing relevant positions by 1) until there are no members left
    
    str_NaN = find(isnan(datanum(:,1)));
    str_gen_pos_plus = str_gen_pos + 1;
    
    
    lia_sum = 1; % name comes from ismember help
    while lia_sum ~= 0
        lia = ismember(str_gen_pos_plus, str_NaN);
        lia_sum = sum(lia);
        str_gen_pos_plus(lia) = str_gen_pos_plus(lia) + 1;
    end
    
    datanum(str_gen_pos_plus, 10) = 1;
    datanum(str_gen_pos_plus, 11) = str_spe_pos(str_gen_pos,1);
    
    %% remove lines starting with NaN (i.e. pure text lines) so that lines have a time interpretation
    data{sn}.raw = datanum;
    data{sn}.raw(isnan(datanum(:,1)),:) = [];
    % header: 'time_point','x_L','y_L','pupil_L','x_R','y_R','pupil_R','blink_L','blink_R','message_gen','message_spe'
    % channels are pupil L, pupil R, x L, y L, x R, y R, blink L, blink R
    % or pupil, x, y, blink (for just one eye)
    if strcmpi(data{sn}.eyesObserved, 'LR')
        % pupilL, pupilR, xL, yL, xR,yR, blinkL, blinkR
        data{sn}.channels = data{sn}.raw(:, [4,7,2:3,5:6,8:9]);
        data{sn}.units = {pupilUnit, pupilUnit, 'pixel', 'pixel', 'pixel', 'pixel', 'blink', 'blink'};
        % cwk: set blinks to NaN
        data{sn}.channels( data{sn}.channels(:,7) == 1, [1,3:4] ) = NaN; % [4,2:3]
        data{sn}.channels( data{sn}.channels(:,8) == 1, [2,5:6] ) = NaN;
    else
        % pupil, x, y, blink
        data{sn}.channels = [data{sn}.raw(:,[4,2:3,5])];
        data{sn}.units = {pupilUnit, 'pixel', 'pixel', 'blink'};
        % cwk: set blinks to NaN
        data{sn}.channels( data{sn}.channels(:,4) == 1, [1:3] ) = NaN;
    end
    
    % translate makers back into special cell structure
    markers = cell(1,3);
    for i=1:3
        markers{1, i} = cell(length(data{sn}.raw), 1);
    end
    
    markers{1,2}(:) = {'0'};
    markers{1,3} = zeros( length(data{sn}.raw), 1);
    markers{1, 1} = data{sn}.raw(:, 10);
    marker_pos = find(markers{1,1} == 1);
    
    for i=1:length(marker_pos)
        % set to default value as long as there is no title provided
        % in the file
        markers{1, 2}{marker_pos(i)} = messages{data{sn}.raw(marker_pos(i), 11)};
        % there is no actual value
        % value has to be numeric
        markers{1, 3}(marker_pos(i)) = data{sn}.raw(marker_pos(i), 11);
    end
    
    % return markers
    data{sn}.markers = markers{1,1};
    data{sn}.markerinfos.name = markers{1,2};
    data{sn}.markerinfos.value = markers{1,3};
    
end
