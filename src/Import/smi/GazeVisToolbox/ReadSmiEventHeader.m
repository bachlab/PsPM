function [params, headers] = ReadSmiEventHeader(filename)

% Read in parameters and sample column names from SMI events file header
%
% INPUTS:
% -filename is a string indicating the SMI events file you want to import.
%
% OUTPUTS:
% -params is a struct including fields and subfelds indicated by the SMI
% file's header.
% -headers is a struct in which each field contains a cell array of strings
% indicating the name of each column in the lines for that event type.
%
% Created 11/19/15 by DJ. 

fprintf('Reading SMI event header from %s...\n',filename)
% open file
fid = fopen(filename);
fseek(fid,0,'eof'); % find end of file
eof = ftell(fid);
fseek(fid,0,'bof'); % rewind to beginning

% Set up
params = struct;
headers = struct;
subfield = '';
% Main Loop
while ftell(fid) < eof % if we haven't reached the end of the text file
    str = fgetl(fid); % read in next line of text file    
    % Add results
    if strncmp(str, 'UserEvent',length('UserEvent')) % first event
        break 
    elseif strncmp(str,'[',1) % params heading
        subfield = str(isstrprop(str,'alphanum'));
    elseif strncmp(str,'Table Header for ',length('Table Header for '));
        eventType = str(length('Table Header for '):end-1);
        eventType = eventType(isstrprop(eventType,'alphanum')); % restrict to alphanum chars
        str = fgetl(fid); % read in next line of text file    
        % Get column names (tab-delimited)
        headers.(eventType) = strsplit(str,'\t');
        for i=1:numel(headers.(eventType))
            headers.(eventType){i} = headers.(eventType){i}(isstrprop(headers.(eventType){i},'alphanum')); % restrict to alphanum chars
        end
    elseif ~isempty(strfind(str,':'));
        iColon = find(str==':',1,'first');
        % separate out field and value
        if ~isempty(iColon)
            field = str(1:iColon-1);
            field = field(isstrprop(field,'alphanum')); % restrict to alpha-numerics, which can be in the field name
            value = str(iColon+2:end); % exclude tab char that follows ':'
            % Add to params struct
            if isempty(subfield)
                params.(field) = value;
            else
                params.(subfield).(field) = value;
            end
        end        
    end
end
fprintf('Done!\n')