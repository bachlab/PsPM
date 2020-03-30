function [sts, import, sourceinfo] = pspm_get_vario(datafile, import)
% pspm_get_vario is the main function for import of VarioPort files
% FORMAT: [sts, import, sourceinfo] = pspm_get_acq(datafile, import);
%
% this function uses the conversion routine getVarioPort.m
% written and maintained by Christoph Berger at the University of Rostock
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id$
% $Rev$

% v003 drb 04.08.2013 3.0 architecture
% v002 drb 11.02.2011 comply with new pspm_import requirements
% v001 drb 6.9.2010

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end;
sourceinfo = []; sts = -1;
addpath(pspm_path('src','Import','vario')); 

% get data
% -------------------------------------------------------------------------
[vario, event] = getVarioport_allChannels(datafile);

% extract individual channels
% -------------------------------------------------------------------------
% loop through import jobs ---
for k = 1:numel(import)
    if ~strcmpi(import{k}.type, 'marker')
        % define channel number ---
        if import{k}.channel > 0
            chan = import{k}.channel;
        else
            chan = pspm_find_channel({vario.channel.name}, import{k}.type);
            if chan < 1, return; end;
        end;    

        if chan > size({vario.channel.name}, 2), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;
        
        sourceinfo.chan{k, 1} = sprintf('Channel %02.0f: %s', chan, vario.channel(chan).name);

        % sample rate
        import{k}.sr = vario.channel(chan).scaled_scan_fac;
        
        % units
        import{k}.units = vario.channel(chan).unit;

        % get data
        import{k}.data =  vario.channel(chan).data(:);

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
rmpath(pspm_path('src','Import','vario')); 
sts = 1;
return;



