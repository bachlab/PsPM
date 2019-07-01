function [sts, import, sourceinfo] = pspm_get_acqmat(datafile, import)
% pspm_get_acqmat is the main function for import of exported 
% biopac/acknowledge files, version 4.0 or higher (tested on 4.2.0)
%
% FORMAT: [sts, import, sourceinfo] = pspm_get_acqmat(datafile, import);
%
% This function is based on sample files, not on proper documentation of the
% file format. Always check your imported data before using it.
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id$
% $Rev$

% v001 drb 07.08.2013

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end
sourceinfo = []; sts = -1;

% load data
% -------------------------------------------------------------------------
inputdata = load(datafile);


% extract individual channels
% -------------------------------------------------------------------------
for k = 1:numel(import)
    % define channel number ---
    if import{k}.channel > 0
        chan = import{k}.channel;
    else
        chan = pspm_find_channel(cellstr(inputdata.labels), import{k}.type);
        if chan < 1, return; end
    end
    
    if chan > size(inputdata.labels, 1), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;

    sourceinfo.chan{k, 1} = sprintf('Channel %02.0f: %s', chan, inputdata.labels(chan, :));
    
    % define sample rate ---
    % catch cases that are not documented and on which we have no example
    % data
    if numel(inputdata.isi) == 1 && strcmpi(inputdata.isi_units, 'ms')
        import{k}.sr = 1000/inputdata.isi;
    else 
        warning('\nUnsupported modality - please notify the developers.\n'); return;
    end
    
    if inputdata.start_sample ~= 0
        warning('\nUnsupported sampling scheme - please notify the developers.\n'); return;
    end
        
    % get data & data units
    import{k}.data = double(inputdata.data(:, chan));
    import{k}.units = inputdata.units(chan,:);
    
    if strcmpi(settings.chantypes(import{k}.typeno).data, 'events')
        import{k}.marker = 'continuous';
    end
end

sts = 1;

return;



