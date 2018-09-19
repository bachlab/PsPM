function [sts, import, sourceinfo] = pspm_get_physlog(datafile, import)
% DESCRIPTION:
%   pspm_get_physlog loads data from physlog files using the
%   import_physlog() function. It maps the output of the called function
%   according to the settings passed in the 'import' parameter.
%   
%   Special about this function is that channel numbers for event/marker 
%   channels correspond to the different event types scanphyslog files.
%   Possible event types are:
%
%           Chan-Nr:   Type:
%           --------   -----
%                 1    Trigger ECG
%                 2    Trigger PPU
%                 3    Trigger Respiration
%                 4    Measurement ('slice onset')
%                 5    start of scan sequence
%                 6    end of scan sequence
%                 7    Trigger external
%                 8    Calibration
%                 9    Manual start
%                 10   Reference ECG Trigger
%    
%   Channel types are:
%           Chan-Nr:   Type:
%           --------   -----
%                1-4   ECG channel
%                  5   PPU channel
%                  6   Resp channel
%
% FORMAT: [sts, import, sourceinfo] = pspm_get_physlog(datafile, import);
%__________________________________________________________________________
% PsPM 3.1
% (C) 2008-2015 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end;
sourceinfo = []; sts = -1;
% add specific import path for specific import function
addpath([settings.path, 'Import', filesep, 'physlog']);

% load data with specific function
% -------------------------------------------------------------------------
[bsts, out] = import_physlog(datafile);
if bsts ~= 1
    warning('ID:invalid_input', 'Physlog import was not successfull');
    return;
end;

% iterate through data and fill up channel list as specified in import
% -------------------------------------------------------------------------
for k = 1:numel(import)
    if strcmpi(import{k}.type, 'marker')        
        chan = import{k}.channel;
        if chan > size(out.trigger.t, 2), warning('ID:channel_not_contained_in_file', 'Column %02.0f not contained in file %s.\n', chan, datafile); return; end;
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