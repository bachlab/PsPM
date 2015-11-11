function [sts, import, sourceinfo] = scr_get_physlog(datafile, import)
% scr_get_physlog loads data from physlog files
%
% FORMAT: [sts, import, sourceinfo] = scr_get_physlog(datafile, import);
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
sourceinfo = []; sts = -1;
% add specific import path for specific import function
addpath([settings.path, 'Import', filesep, 'physlog']);

% load data with specific function
% -------------------------------------------------------------------------
[sts, out] = import_physlog(datafile);

% iterate through data and fill up channel list as specified in import
% -------------------------------------------------------------------------
for k = 1:numel(import)
    if strcmpi(import{k}.type, 'marker')
        chan = import{k}.channel;
        import{k}.marker = 'continuous';
        import{k}.sr     = out.trigger.sr;
        import{k}.data   = out.trigger.t{:,chan};
    else
        chan = import{k}.channel;
        if chan > size(out.data, 1), warning('ID:channel_not_contained_in_file', 'Column %02.0f not contained in file %s.\n', chan, datafile); return; end;
        import{k}.sr = out.data{chan,1}.header.sr;
        import{k}.data = out.data{chan,1}.data;
        import{k}.units = out.data{chan,1}.header.units;
        sourceinfo.chan{k, 1} = sprintf('Column %02.0f', chan);
    end;
end;

% extract record time and date
sourceinfo.date = out.record_date;
sourceinfo.time = out.record_time;

% remove specific import path
rmpath([settings.path, 'Import', filesep, 'physlog']);

sts = 1;
return;