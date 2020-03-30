function [sts, import, sourceinfo] = pspm_get_cnt(datafile, import)
% pspm_get_cnt is the main function for import of NeuroScan cnt files
% FORMAT: [sts, import, sourceinfo] = pspm_get_cnt(datafile, import);
% this function uses fieldtrip fileio functions
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id$
% $Rev$

% v004 drb 14.08.2013 changed for 3.0 architecture
% v003 drb 14.08.2012 added handling of 32 bit data
% v002 drb 07.08.2012 added handling of empty event channel
% v001 drb 31.07.2012

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end;
addpath(pspm_path('src','Import','fieldtrip','fileio')); 
sourceinfo = []; sts = -1;

% get external file, using fieldtrip
% -------------------------------------------------------------------------
% data storage is assumed to be 16 bit by default, see also
% http://fieldtrip.fcdonders.nl/faq/i_have_problems_reading_in_neuroscan_.cnt_files._how_can_i_fix_this
if isfield(import{1}, 'bit') && import{1}.bit == 32
    headerformat = 'ns_cnt32';
else
    headerformat = 'ns_cnt16';
end;

hdr = ft_read_header(datafile, 'headerformat', headerformat);
indata = ft_read_data(datafile, 'headerformat', headerformat, 'dataformat', headerformat);
try mrk = ft_read_event(datafile, 'headerformat', headerformat, 'dataformat', headerformat, 'eventformat', headerformat); catch, mrk = []; end;

% extract individual channels
% -------------------------------------------------------------------------
for k = 1:numel(import)
        
    if strcmpi(settings.chantypes(import{k}.typeno).data, 'wave')
        % channel number --- 
        if import{k}.channel > 0
             chan = import{k}.channel;
         else
             chan = pspm_find_channel(hdr.label, import{k}.type); 
             if chan < 1, return; end;
         end;
    
             sourceinfo.chan{k, 1} = sprintf('Channel %02.0f: %s', chan, hdr.label{chan});

         % sample rate ---
        import{k}.sr = hdr.Fs;
    
        % get data ---
        import{k}.data = indata(chan, :);
    
    else                % event channels
        % time unit
        import{k}.sr = 1./hdr.Fs;
        
        if ~isempty(mrk)
            import{k}.data = [mrk(:).sample];
            import{k}.marker = 'timestamps';
            import{k}.markerinfo.value = [mrk(:).value];
            import{k}.markerinfo.name = {mrk(:).type};
        else
            import{k}.data = [];
            import{k}.markerinfo.value = [];
            import{k}.markerinfo.name = [];
        end;
    end;
    
end;

% clear path and return
% -------------------------------------------------------------------------
rmpath(pspm_path('src','Import','fieldtrip','fileio')); 
sts = 1;
return;



