function [sts, import, sourceinfo] = pspm_get_txt(datafile, import)
% pspm_get_txt is the main function for import of text files
%
% FORMAT: [sts, import, sourceinfo] = pspm_get_txt(datafile, import);
%       datafile:   a .txt-file containing numerical data (with any
%                   delimiter) and optionally the channel names in the first
%                   line.
%       import:     import job structure
%                   - recommended fields:
%                       .type:
%                           A char array corresponding to a valid PsPM data
%                           type, see `pspm_init.m` for more details.
%                       .channel:
%                           A numeric value representing the column number
%                           of the corresponding numerical data.   
%                   - optional fields:
%                       .delimiter: 
%                           A char array corresponding to the delimiter
%                           used in the datafile to delimit data columns.
%                           To be used it should be specified on the first 
%                           import cell, e.g.: 
%                               import{1}.delimiter == ','
%                           Default: ' ' (white-space).
%                       .header_lines:
%                           A numeric value corresponding to the number of 
%                           header lines. Which means the data start on
%                           line number: "header_lines + 1".
%                           To be used it should be specified on the first 
%                           import cell, e.g.: 
%                               import{1}.header_lines == 3
%                           Default: 0.
%                       .channel_names_line:
%                           A numeric value corresponding to the line
%                           number where the channel names are specified.
%                           To be used it should be specified on the first 
%                           import cell, e.g.: 
%                               import{1}.channel_names_line == 2
%                           Default: 0.
%                       .exclude_columns:
%                           A numeric value corresponding to the number of
%                           columns to exclude starting from the left.
%                           To be used it should be specified on the first 
%                           import cell, e.g.: 
%                               import{1}.exclude_columns == 2
%                           Default: 0.
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id$
% $Rev$

% v005 lr  23.09.2013 added support for channel names
% v004 lr  09.09.2013 removed bugs
% v003 drb 31.07.2013 changed for 3.0 architecture
% v002 drb 11.02.2011 comply with new pspm_import requirements
% v001 drb 16.9.2009


% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end;
sourceinfo = []; sts = -1;

% check import structure options
% -------------------------------------------------------------------------
if ~isfield(import{1}, 'delimiter')
   delim = ' ';
elseif ~ischar(import{1}.delimiter)
   warning('ID:invalid_input','The ''delimiter'' option should be a char array.')
   return;
else
   delim = import{1}.delimiter;
end

if ~isfield(import{1}, 'header_lines')
   header_lines = 0;
elseif ~isnumeric(import{1}.header_lines)
   warning('ID:invalid_input','The ''header_lines'' option should be a numeric value.')
   return;
else
   header_lines = import{1}.header_lines;
end

if ~isfield(import{1}, 'channel_names_line')
   channel_names_line = 0;
elseif ~isnumeric(import{1}.channel_names_line)
   warning('ID:invalid_input','The ''channel_names_line'' option should be a numeric value.')
   return;
else
   channel_names_line = import{1}.channel_names_line;
end

if ~isfield(import{1}, 'exclude_columns')
   exclude_columns = 0;
elseif ~isnumeric(import{1}.exclude_columns)
   warning('ID:invalid_input','The ''exclude_columns'' option should be a numeric value.')
   return;
else
   exclude_columns = import{1}.exclude_columns;
end

% read channel names
% -------------------------------------------------------------------------
fid = fopen(datafile);

% go to the specific line to read the channel names
if channel_names_line ~= 0
    for k=1:channel_names_line-1
      fgetl(fid); % read and dump
    end
end

channel_names = textscan(fgetl(fid), '%s',  'Delimiter', delim);
channel_names = channel_names{1};

fclose(fid);

% load & check data
% -------------------------------------------------------------------------

data = dlmread(datafile, delim, header_lines, exclude_columns);
if isempty(data), warning('An error occured while reading a textfile.\n'); return; end;

% select desired channels
% -------------------------------------------------------------------------
for k = 1:numel(import)
    % define channel number
    if import{k}.channel > 0
        chan = import{k}.channel;
    elseif channel_names_line ~= 0
        chan = pspm_find_channel(channel_names, import{k}.type);
        if chan < 1, return; end;
    else
        warning('ID:invalid_input', ...
                ['Neiter ''channel'' nor ''channel_names_line'' options were specified.', ...
                 ' Not able to import the data.'])
    end
    
    if chan > size(data, 2), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;
    
    import{k}.data = data(:, chan);
    
    typeno = ~cellfun(@isempty,strfind({settings.chantypes.type},import{k}.type));
    if strcmpi(settings.chantypes(typeno).data, 'events')
        import{k}.marker = 'continuous';
    end;
    
    sourceinfo.chan{k} = sprintf('Data column %02.0', chan);
end;

sts = 1;
return;
