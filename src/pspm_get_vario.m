function [sts, import, sourceinfo] = pspm_get_vario(datafile, import)
% ● Description
%   pspm_get_vario is the main function for import of VarioPort files
%   this function uses the conversion routine getVarioPort.m
%   written and maintained by Christoph Berger at the University of Rostock
% ● Format
%   [sts, import, sourceinfo] = pspm_get_acq(datafile, import);
% ● Arguments
%     datafile:
%       import:
% ● Outputs
%          sts:
%       import:
%   sourceinfo:
% ● Copyright
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Maintained in 2022 by Teddy Chao (UCL)

% initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];
addpath(pspm_path('Import','vario'));

% get data
% -------------------------------------------------------------------------
[vario, event] = getVarioport_allChannels(datafile);

% extract individual channels
% -------------------------------------------------------------------------
% loop through import jobs ---
for k = 1:numel(import)
  if ~strcmpi(import{k}.type, 'marker')
    % define channel number ---
    if import{k}.chan > 0
      chan = import{k}.chan;
    else
      chan = pspm_find_channel({vario.chan.name}, import{k}.type);
      if chan < 1, return; end;
    end;

    if chan > size({vario.chan.name}, 2), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;

    sourceinfo.chan{k, 1} = sprintf('Channel %02.0f: %s', chan, vario.chan(chan).name);

    % sample rate
    import{k}.sr = vario.chan(chan).scaled_scan_fac;

    % units
    import{k}.units = vario.chan(chan).unit;

    % get data
    import{k}.data =  vario.chan(chan).data(:);

  else
    import{k}.sr = 1; % converted to seconds in getVarioport_allChannels.m
    import{k}.data = [event.time];
    import{k}.marker = 'timestamp';
    import{k}.markerinfo.name = {event.name};
    import{k}.markerinfo.value = {event.name};
  end;
end;

% clear path and return
% -------------------------------------------------------------------------
rmpath(pspm_path('Import','vario'));
sts = 1;
return