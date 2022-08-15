function [sts, import, sourceinfo]  = pspm_get_wdq(datafile, import)
% ● Description
%   pspm_get_wdq is the main function for import of Dataq/Windaq files
% ● Format
%   [sts, import, sourceinfo] = pspm_get_wdq(datafile, import);
% ● Arguments
%     datafile:
%       import:
% ● Outputs
%          sts:
%       import:
%   sourceinfo:
% ● Developer's Notes
%   this function uses the conversion routine ReadDataq.m provided by Dataq
%   developers. ActiveX control elements provided in the file activex.exe
%   provided by Dataq must be installed, too.
% ● Copyright
%   Introduced in PsPM 3.0
% ● Written By
%   (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
% ● Maintained By
%   2022 Teddy Chao (UCL)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];
addpath(pspm_path('Import','wdq'));

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
rmpath(pspm_path('Import','wdq'));
sts = 1;
return