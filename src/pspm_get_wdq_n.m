function [sts, import, sourceinfo]  = pspm_get_wdq_n(datafile, import)
% ● Description
%   pspm_get_wdq_n is a function to import of Dataq/Windaq files
% ● Format
%   [sts, import, sourceinfo] = pspm_get_wdq_n(datafile, import);
% ● Arguments
%     datafile:
%       import:
% ● Outputs
%          sts:
%       import:
%   sourceinfo:
% ● Developer's Notes
%   This function does not use the ActiveX control elements provided by
%   Dataq developers. Instead it reads the binary file according to the
%   documentation published by dataq 
%   (http://www.dataq.com/resources/techinfo/ff.htm).
%   The current called routine nReadDataq.m may not provide as many data
%   (check the commented header of the routine nReadDataq for more
%   information) as the ActiveX control elements do, but the function is
%   independent of cpu architecture. Which means it does not require a 32-bit
%   Matlab-Version.
% ● Introduced In
%   PsPM 3.0
% ● Written By
%   (C) 2012 - 2015 Tobias Moser (University of Zurich)
% ● Maintained By
%   2022 Teddy Chao (UCL)

%% initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];
addpath(pspm_path('Import','nwdq'));

% get external file, using Dataq functions
% -------------------------------------------------------------------------
[inputinfo, inputdata] = nReadDataq(datafile);

% extract individual channels
% -------------------------------------------------------------------------
% loop through import jobs
for k = 1:numel(import)
  chan = import{k}.channel;
  if chan > size(inputdata, 2)
    warning('ID:channel_not_contained_in_file', 'Channel %1.0f does not exist in data file', chan); return;
  end;
  import{k}.sr = inputinfo.sampleRatePerChannel; % sample rate per channel
  import{k}.data = inputdata{chan};     % data per channel
  import{k}.units = inputinfo.engineeringUnitsTag(chan, :);
  sourceinfo.chan{k, 1} = sprintf('Channel %02.0f', chan);
  if strcmpi(settings.chantypes(import{k}.typeno).data, 'events')
    import{k}.marker = 'continuous';
  end;
end;

% clear path and return
% -------------------------------------------------------------------------
rmpath(pspm_path('Import','nwdq'));
sts = 1;
return