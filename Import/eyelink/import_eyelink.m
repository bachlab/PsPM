function [data] = import_eyelink(filename)
% 
% FORMAT:
% data = import_eyelink(filename)
%   filename:   path to the file which contains the recorded eyelink data 
%               in asc file format
%
% (C) Christoph Korn & Tobias Moser (University of Zurich)
%__________________________________________________________________________
% PsPM 3.0
%
% $ Id: $
% $ Rev: $


%% Notes for data structure
% in col 1    : 'SFIX', 'EFIX', 'SSAC', 'ESAC', 'SBLINK', 'EBLINK', 'END', 'INPUT', 'MSG'
% in col 2/3/4: 'L', 'C', 'R', ' .', 'SAMPLES', 'EVENTS' 
% if you have less columns in textscan it will break some very long lines &
% have more lines than there are!


%% open file with all colums as %s to get messages etc

% determine number of header lines
numHeader = 0; fileID2 = fopen(filename);
datastr = textscan(fileID2, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s', 'HeaderLines', numHeader, 'delimiter', '\t'); 

%% convert to numeric
for i_col = 1:7
    datanum(:,i_col) = str2double(datastr{1,i_col});
end
% if NaN in first column put NaN in all others
datanum(isnan(datanum(:,1)),:) = NaN;
dataFields = find(~isnan(datanum(:, 1)));

%% try to read some header information
% read the PUPIL unit
pupilPos = strncmpi(datastr{1,1}, 'PUPIL', 5);
pupilUnit = lower(datastr{1,2}{pupilPos});

% try to get the record date
datePos = strncmpi(datastr{1,1}, '** DATE', 6);
dateFields = strsplit(datastr{1,1}{datePos});
data.record_date = strjoin(dateFields(([3:5,length(dateFields)])));
data.record_time = dateFields{6};


% header stops where the data section starts
dataStartPos = dataFields(1);
% look for MSG in header section
headerMsgPos = find(strncmpi(datastr{1,1}(1:dataStartPos), 'MSG', 3));

for i=1:length(headerMsgPos),
    headerFields = strsplit(datastr{1, 2}{headerMsgPos(i)});
    % the second field contains the field name
    % the first field contains a timestamp
    fieldName = headerFields{2};
    switch fieldName
        case 'RECCFG'
            % this field contains the samplerate #4
            % and whether both eyes or just one have been recorded #7
            % which is either LR or L or R
            data.sampleRate = str2double(headerFields{4});
            eyesObserved = headerFields{7};
    end
end

%% remove header in order to avoid interpreting header MSG as "marker" MSG
for i=1:size(datastr, 2),
    for j=1:dataStartPos-1,
        datastr{1,i}{j} = [];
    end
end


%% identify saccades/blinks
% note: blinks are always surrounded by saccades, therefore use saccades
% find L and R saccades 
saccades = {'SSACC L','ESACC L','SSACC R','ESACC R'};
for j = 1:size(saccades,2)
    str_sacc(:,j) = strncmp(saccades{j}, datastr{1, 1}, 7);
end
for h = 1:size(saccades,2)
    str_sacc_pos{h} = find(str_sacc(:,h));
end

% special cases if data collection started or ended with a saccade
% to do


%% add saccade information as extra colum to relevant data
blink_offset = 0; % possibility to remove more
% L
for k = 1:length(str_sacc_pos{1})
    datanum(str_sacc_pos{1}(k) - blink_offset : str_sacc_pos{2}(k) + blink_offset, 8) = 1;
end
% R
for k = 1:length(str_sacc_pos{3})
    datanum(str_sacc_pos{3}(k) - blink_offset : str_sacc_pos{4}(k) + blink_offset, 9) = 1;
end


%% identify messages
% translate MSG into double
% look for general (gen) positions of MSG fields
% look for specific (spe) MSG text and add it to a additional column to the
% gen pos

% the MSG text is also translated into double and later translated back
% into a text. for this purpose messages is used.
str_gen(:,1) = strncmp('MSG', datastr{1, 1}, 3);
str_gen_pos = find(str_gen);
msg_str = datastr{1,2}(str_gen_pos);
messages = unique(regexprep(msg_str, '[0-9]+\s(.*)', '$1'));

% we assume each MSG has a specific text message
str_spe_pos = zeros(length(str_gen_pos), 1);
for j = 1:size(messages,1)
    for m = 1:size(str_gen_pos,1)
        s = regexp(datastr{1,2}{str_gen_pos(m,1),1}, ... 
                strcat('[0-9]\s',messages(j)), 'once');
        if s{1} > 0
            str_spe_pos(str_gen_pos(m,1),1) = j;
        end
    end
end


%% add message information as extra colum to relevant data
% has to be added in next line (which is not a text line --> to do)
% HERE: correction
% 1.    check whether elements of vector of messages_plus_1 are also members of
%       the vector containing NaN
% 2.    loop (with increading relevant positions by 1) until there are no members left

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
data.raw = datanum;
data.raw(isnan(datanum(:,1)),:) = [];
% header: 'time_point','x_L','y_L','pupil_L','x_R','y_R','pupil_R','blink_L','blink_R','message_gen','message_spe'
% channels are pupil L, pupil R, x L, y L, x R, y R, blink L, blink R
% or pupil, x, y, blink (for just one eye)
if strcmpi(eyesObserved, 'LR'),
    % pupilL, pupilR, xL, yL, xR,yR, blinkL, blinkR
    data.channels = data.raw(:, [4,7,2:3,5:6,8:9]);
    data.units = {pupilUnit, pupilUnit, 'pixel', 'pixel', 'pixel', 'pixel', 'blink', 'blink'};
else
    % pupil, x, y, blink, blink
    data.channels = data.raw(:,[4,2:3,5]);
    data.units = {pupilUnit, 'pixel', 'pixel', 'blink'};
end

% translate makers back into special cell structure
markers = cell(1,3);
for i=1:3,
    markers{1, i} = cell(length(data.raw), 1);
end

markers{1,2}(:) = {'0'};
markers{1,3} = zeros( length(data.raw), 1);
markers{1, 1} = data.raw(:, 10);
marker_pos = find(markers{1,1} == 1);

for i=1:length(marker_pos),
    % set to default value as long as there is no title provided
    % in the file
    markers{1, 2}{marker_pos(i)} = messages{data.raw(marker_pos(i), 11)};
    % there is no actual value
    % value has to be numeric
    markers{1, 3}(marker_pos(i)) = data.raw(marker_pos(i), 11);
end

% return markers
data.markers = markers{1,1};
data.markerinfos.name = markers{1,2};
data.markerinfos.value = markers{1,3};

