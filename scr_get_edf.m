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
% disable warning for ft_read_header
w_state = warning('query');
warning('off', 'all'); % unfortunately the warning is not issued with an ID
hdr = ft_read_header(datafile);
indata = ft_read_data(datafile);
warning(w_state.state, w_state.identifier);

% convert 3 dim to 2 dim (collapse all trials into continuous data)
if numel(size(indata)) == 3,
    indata = indata(:,:);
end;

% extract individual channels
% -------------------------------------------------------------------------
% loop through import jobs
for k = 1:numel(import)

    % define channel number ---
    if import{k}.channel > 0
        chan = import{k}.channel;
    else
        chan = scr_find_channel(hdr.label, import{k}.type);
        if chan < 1, return; end;
    end;

    if chan > numel(hdr.label), 
        warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); 
        return; 
    end;

    % data
    import{k}.data = indata(chan, :);     % data per channel
    % sample rate ---
    import{k}.sr = hdr.Fs;
    sourceinfo.chan{k, 1} = sprintf('Channel %02.0f: %s', chan, hdr.label{chan});
    
    if strcmpi(settings.chantypes(import{k}.typeno).data, 'events')
        % marker channels: get the ascending flank of each marker
        sourceinfo.chan{k, 1} = 'Extracted marker recordings';
        import{k}.marker = 'continuous';
        import{k}.flank = 'ascending';
    end;
                   
end;

% clear path and return
% -------------------------------------------------------------------------
rmpath([settings.path, 'Import', filesep, 'fieldtrip']); 
sts = 1;
return;
