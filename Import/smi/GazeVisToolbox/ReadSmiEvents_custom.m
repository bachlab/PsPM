function [events, params] = ReadSmiEvents_custom(filename,headers)

% [events, params] = ReadSmiEvents_custom(filename,headers)
%
% INPUTS:
% -filename is a string indicating the name of the SMI events file.
% -headers is a struct in which each field name is a type of event and
% headers.(field) is a cell array of the parameters in the rows for that
% event type. 
%
% OUTPUTS:
% -events is a struct with the same field as headers (one for each event
% type. events.(field) will have subfields for all of the parameters
% listed in headers.(field), and each will contain n elements for the n
% events of that type that were recorded.
% -params is a struct of acquisition parameters created from the header
% using ReadSmiEventHeader (only if input headers is not provided).
%
% Created 5/6/15 by DJ.
% Updated 8/11/15 by DJ - changed last %*c to %*s to accommodate multiple dots.
% Updated 11/19/15 by DJ - changed to 'custom' version where file header
% text determines event struct fields.

if ~exist('headers','var') || isempty(headers)
    [params,headers] = ReadSmiEventHeader(filename);
else
    params = struct; % create empty struct for output
end
fprintf('Reading SMI samples from %s...\n',filename)
% open file
fid = fopen(filename);
fseek(fid,0,'eof'); % find end of file
eof = ftell(fid);
fseek(fid,0,'bof'); % rewind to beginning

keywords = fieldnames(headers);

for i=1:numel(keywords)    
    eventColStr = '';
    colNames = headers.(keywords{i});
    for j=1:numel(colNames);
        switch colNames{j}
            case {'EventType','Description'}
                eventColStr = [eventColStr ' %s'];
            case {'N/A'}
                eventColStr = [eventColStr ' %*s'];
            case {'Trial', 'Number'}               
                eventColStr = [eventColStr ' %d'];
            otherwise
                eventColStr = [eventColStr ' %f'];
        end
    eventCols.(keywords{i}) = eventColStr;
    % Remove N/As
    headers.(keywords{i})(strcmp(headers.(keywords{i}),'N/A')) = [];
    end
end

% Set up
iEvent = ones(1,numel(keywords));
eventMat = struct;
for i=1:numel(keywords)
    eventMat.(keywords{i}) = cell(0,numel(headers.(keywords{i})));
end

% Read in events
while ftell(fid) < eof % if we haven't reached the end of the text file
    str = fgetl(fid); % read in next line of text file
    % Check for keywords
    for i=1:numel(keywords)
        if strncmp(str,keywords{i},length(keywords{i})-1) % exclude final s
            eventMat.(keywords{i})(iEvent(i),:) = textscan(str,eventCols.(keywords{i}),'delimiter','\t');
            iEvent(i) = iEvent(i) + 1; % increment event number
            break % end for loop to save time
        end
    end
end

% Convert results into structs
fprintf('converting to struct...\n')
for i=1:numel(keywords)
    for j=1:numel(headers.(keywords{i}))
        field = headers.(keywords{i}){j};
        events.(keywords{i}).(field) = cat(1,eventMat.(keywords{i}){:,j});
    end
end
fprintf('Done!\n');

