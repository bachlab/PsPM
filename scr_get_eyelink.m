function [sts, import, sourceinfo] = scr_get_eyelink(datafile, import)
% scr_get_eyelink is the main function for import of SR Research Eyelink 1000
% files. 
%
% FORMAT: [sts, import, sourceinfo] = scr_get_eyelink(datafile, import);
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Tobias Moser (University of Zurich)

% $Id: scr_get_eyelink.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
sourceinfo = []; sts = -1;
% add specific import path for specific import function
addpath([settings.path, 'Import', filesep, 'eyelink']);

% load data with specific function
% -------------------------------------------------------------------------
data = import_eyelink(datafile);

% iterate through data and fill up channel list as long as there is no
% marker channel. if there is any marker channel, the settings accordingly
% markerinfos, markers and marker type.
% -------------------------------------------------------------------------
for k = 1:numel(import)
    if strcmpi(import{k}.type, 'marker')
        import{k}.marker = 'continuous';
        import{k}.sr     = data.sampleRate;
        import{k}.data   = data.markers;
        % marker info is read and set (in this instance) but
        % imported data cannot be read at the moment (in later instances)
        import{k}.markerinfo = data.markerinfos;
    else
        chan = import{k}.channel;
        if chan > size(data.channels, 2), warning('ID:channel_not_contained_in_file', 'Column %02.0f not contained in file %s.\n', chan, datafile); return; end;
        import{k}.sr = data.sampleRate;
        import{k}.data = data.channels(:, chan);
        import{k}.units = data.units{import{k}.channel};
        sourceinfo.chan{k, 1} = sprintf('Column %02.0f', chan);
    end;
end;

% extract record time and date
sourceinfo.date = data.record_date;
sourceinfo.time = data.record_time;

% remove specific import path
rmpath([settings.path, 'Import', filesep, 'eyelink']);

sts = 1;
return;

