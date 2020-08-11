function [sts, import, sourceinfo] = pspm_get_txt(datafile, import, delimiter)
% pspm_get_txt is the main function for import of text files
%
% FORMAT: [sts, import, sourceinfo] = pspm_get_txt(datafile, import);
%       datafile: a .txt-file containing numerical data (with any
%                 delimiter) and optionally the channel names in the first
%                 line.
%       delimiter: optional, if provided will use string as the delimiter for the file read
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

% load & check data
% -------------------------------------------------------------------------
fid = fopen(datafile);
channel_names = textscan(fgetl(fid), '%s');
channel_names = channel_names{1};
fclose(fid);
fline = str2double(channel_names);
if ~any(isnan(fline)) %no headerline
    if nargin == 3;
        data = dlmread(datafile, delimiter);
    else;
        data = dlmread(datafile);
    end;

elseif all(isnan(fline)) %headerline
    fid = fopen(datafile);
    formatSpec = repmat('%f', 1, numel(channel_names))

    % if delimiter provided
    if nargin == 3;
        data = textscan(fid, formatSpec, 'HeaderLines', 1, 'Delimiter', delimiter);
    else;
        data = textscan(fid, formatSpec, 'HeaderLines', 1);
    end;
    data = cell2mat(data);
    fclose(fid);
else
    warning('The format of %s is not supported', datafile); return;
end

if isempty(data), warning('An error occured while reading a textfile.\n'); return; end;

% select desired channels
% -------------------------------------------------------------------------
for k = 1:numel(import)
    % define channel number
    if import{k}.channel > 0
        chan = import{k}.channel;
    else
        chan = pspm_find_channel(channel_names, import{k}.type);
        if chan < 1, return; end;
    end;
    
    if chan > size(data, 2), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;
    
    import{k}.data = data(:, chan);
    
    if strcmpi(settings.chantypes(import{k}.typeno).data, 'events')
        import{k}.marker = 'continuous';
    end;
    
    sourceinfo.chan{k} = sprintf('Data column %02.0', chan);
end;

sts = 1;
return;
