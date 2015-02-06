function [sts, import, sourceinfo]  = scr_get_wdq(datafile, import)
% scr_get_wdq is the main function for import of Dataq/Windaq files
% FORMAT: [sts, import, sourceinfo] = scr_get_wdq(datafile, import);
%
% this function uses the conversion routine ReadDataq.m provided by Dataq
% developers. ActiveX control elements provided in the file activex.exe
% provided by Dataq must be installed, too.
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_get_wdq.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
sourceinfo = []; sts = -1;
addpath([settings.path, 'Import', filesep, 'wdq']);

% get external file, using Dataq functions
% -------------------------------------------------------------------------
inputdata = ReadDataq(datafile);

% extract individual channels
% -------------------------------------------------------------------------
% loop through import jobs
for k = 1:numel(import)
    chan = import{k}.channel;
    if chan > size(inputdata.Data, 2)
        warning('Channel %1.0f does not exist in data file', chan); return;
    end;
    import{k}.sr = inputdata.SR;            % sample rate per channel
    import{k}.data = inputdata.Data(:, chan);     % data per channel
    import{k}.units = inputdata.Units{chan};
    sourceinfo.chan{k, 1} = sprintf('Channel %02.0f', chan);
    if strcmpi(settings.chantypes(import{k}.typeno).data, 'events')
        import{k}.marker = 'continuous';
    end;
end;

% clear path and return
% -------------------------------------------------------------------------
rmpath([settings.path, 'Import', filesep, 'wdq']);
sts = 1;
return;



