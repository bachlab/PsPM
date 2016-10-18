function [sts, import, sourceinfo] = scr_get_acq_bioread(datafile, import)
% scr_get_acq_bioread is the main function for import of converted
% biopac/acknowledge files (any version). It requires the files to be
% converted to .mat files using the bioread[1] tool acq2mat.exe.
%
% FORMAT: [sts, import, sourceinfo] = scr_get_acq_bioread(datafile, import);
%
% This function is based on sample files, not on proper documentation of the
% file format. Always check your imported data before using it.
%
% [1] https://github.com/njvack/bioread
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
sourceinfo = []; sts = -1;

% load data
% -------------------------------------------------------------------------
inputdata = load(datafile);


% extract individual channels
% -------------------------------------------------------------------------
for k = 1:numel(import)
    channel_labels = cellfun(@(x) x.name, inputdata.channels, 'UniformOutput', 0);
    % define channel number ---
    if import{k}.channel > 0
        chan = import{k}.channel;
    else
        chan = scr_find_channel(channel_labels, import{k}.type);
        if chan < 1, return; end;
    end;
    
    if chan > size(channel_labels, 1), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;

    sourceinfo.chan{k, 1} = sprintf('Channel %02.0f: %s', chan, channel_labels{chan});
    
    % define sample rate ---
    import{k}.sr = inputdata.channels{chan}.samples_per_second;
   
    % get data & data units
    import{k}.data = double(inputdata.channels{chan}.data);
    import{k}.units = inputdata.channels{chan}.units;
    
    if strcmpi(settings.chantypes(import{k}.typeno).data, 'events')
        import{k}.marker = 'continuous';
    end;
end;

sts = 1;

return;

