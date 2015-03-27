function [sts, import, sourceinfo] = scr_get_edf(datafile, import)
% scr_get_edf is the main function for import of EDF files
% FORMAT: [sts, import, sourceinfo] = scr_get_edf(datafile, import);
% this function uses fieldtrip fileio functions
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
addpath([settings.path, 'Import', filesep, 'fieldtrip']); 

% get data
% -------------------------------------------------------------------------
hdr = ft_read_header(datafile);
indata = ft_read_data(datafile);
try mrk = ft_read_event(datafile); catch, mrk = []; end;

% convert 3 dim to 2 dim (summarize all trials)
if numel(size(indata)) == 3,
    indata = indata(:,:);
end;

% extract individual channels
% -------------------------------------------------------------------------
% loop through import jobs
for k = 1:numel(import)

    if strcmpi(settings.chantypes(import{k}.typeno).data, 'wave')
        % channel number ---
        if import{k}.channel > 0
            chan = import{k}.channel;
        else
            chan = scr_find_channel(hdr.label, import{k}.type);
            if chan < 1, return; end;
        end;
        
        if chan > size(indata, 1), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;
        
        sourceinfo.chan{k, 1} = sprintf('Channel %02.0f: %s', chan, hdr.label{chan});
        
        % sample rate ---
        import{k}.sr = hdr.Fs;
        
        % get data ---
        import{k}.data = indata(chan);
        
    else                % event channels
        % time unit
        import{k}.sr = 1./hdr.Fs;
        sourceinfo.chan{k, 1} = 'Automatically extracted marker recordings';
        if ~isempty(mrk)
            import{k}.data = [mrk(:).sample];
            import{k}.marker = 'timestamps';
            import{k}.markerinfo.value = [mrk(:).value];
            import{k}.markerinfo.name = {mrk(:).type};
        else
            import{k}.data = [];
            import{k}.marker = '';
            import{k}.markerinfo.value = [];
            import{k}.markerinfo.name = [];
        end;
    end;
               
end;

% clear path and return
% -------------------------------------------------------------------------
rmpath([settings.path, 'Import', filesep, 'fieldtrip']); 
sts = 1;
return;
