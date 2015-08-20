function [sts, outdata] = scr_cfg_change_field(indata, change)
% SCR_CFG_CHANGE_FIELD loads the given path in the given indata (matlab cfg
% struct) and sets the given field to the given value.
% 
% scr_cfg_change_field(indata, change)
% 
%   indata: matlab cfg struct
%   change: change struct or cell array of change structs
%
%   change struct:
%       path: path in the config object to the desired field
%       field: field to change
%       value: new field value
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;

sts = -1;
outdata = {};

% try to determine wheter to work in batch mode or not
if iscell(change)
    nfields = numel(change);
elseif isstruct(change)
    nfields = 1;
    change = {change};
else
    warning('ID:invalid_input', 'Incoming data is not uniquely formatted. Don''t know what to do.');
    return;
end;

% load path
for i=1:nfields
    c = change{i};
    
    p = c.path;  
    lvl = numel(p);
    
    if isa(indata, 'cfg_branch')
        v = 'val';
    else
        v = 'values';
    end;
    
    if lvl == 0
        % try to set field        
        if any(ismember(fieldnames(indata), c.field))
            % changed field
            indata.(c.field) = c.value;
        else
            warning('ID:invalid_input', 'No field %s in tag %s found.', [c.field, indata.tag]);
        end;
        
    elseif lvl >= 1
        % try to get field and recursively pass again to this function
        
        % find lvl field from path in data
        if any(ismember(fieldnames(indata), v))
            % find fieldtag in values
            tag = cellfun(@(field) strcmpi(field.tag, p{1}), indata.(v));
            
            if sum(tag) == 1
                % remove first field from path
                c.path(1) = [];
                [sts, indata.(v){tag}] = scr_cfg_change_field(indata.(v){tag}, c);
            else
                warning('ID:invalid_input', 'No or more than one tag %s in %s found.', [p{1}, indata.tag]);
                return;
            end;
            
        else
            warning('ID:invalid_input', 'Path ''%i'' is longer than actual data.', i);
            return;
        end;
        
    end;
end;

outdata = indata;