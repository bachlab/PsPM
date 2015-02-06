function [sts, import, sourceinfo] = scr_get_txt(datafile, import)
% scr_get_txt is the main function for import of text files
%
% FORMAT: [sts, import, sourceinfo] = scr_get_txt(datafile, import);
%       datafile: a .txt-file containing numerical data (with any
%                 delimiter) and optionally the channel names in the first
%                 line.
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_get_txt.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% v005 lr  23.09.2013 added support for channel names
% v004 lr  09.09.2013 removed bugs
% v003 drb 31.07.2013 changed for 3.0 architecture
% v002 drb 11.02.2011 comply with new scr_import requirements
% v001 drb 16.9.2009


% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
sourceinfo = []; sts = -1;

% load & check data
% -------------------------------------------------------------------------
fid = fopen(datafile);
channel_names = textscan(fgetl(fid), '%s');
channel_names = channel_names{1};
fclose(fid);

fline = str2double(channel_names);
if ~any(isnan(fline)) %no headerline
    data = dlmread(datafile);
elseif all(isnan(fline)) %headerline
    fid = fopen(datafile);
    formatSpec = '';
    for i=1:numel(channel_names)
        formatSpec = [formatSpec '%f'];
    end
    data = textscan(fid, formatSpec, 'HeaderLines', 1);
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
        chan = scr_find_channel(channel_names, import{k}.type);
        if chan < 1, return; end;
    end;
    
    if chan > size(data, 2), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;
    
    import{k}.data = data(:, chan);
    sourceinfo.chan{k} = sprintf('Data column %02.0', chan);
end;

sts = 1;
return;
