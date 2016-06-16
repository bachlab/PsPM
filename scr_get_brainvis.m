function [sts, import, sourceinfo] = scr_get_brainvis(datafile, import)
% scr_get_brainvis is the main function for import of BrainVision files
% FORMAT: [sts, import, sourceinfo] = scr_get_brainvis(datafile, import);
% this function uses fieldtrip fileio functions
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_get_brainvis.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% NOTE I did not have sample files, simply assumed that hdr.labels would be
% a cell array - might have to be changed in lines 38 and 41

% v003 drb 14.08.2013 3.0 architecture
% v002 drb 31.07.2012 fixed bug in timestamp import
% v001 drb 23.08.2011

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

% extract individual channels
% -------------------------------------------------------------------------
% loop through import jobs
for k = 1:numel(import)
        
    if strcmpi(settings.chantypes(import{k}.typeno).data, 'wave')
        % define channel number ---
        if import{k}.channel > 0
            chan = import{k}.channel;
        else
            chan = scr_find_channel(hdr.label, import{k}.type);
            if chan < 1, return; end;
        end;
        
        if chan > numel(hdr.label), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;
        
        sourceinfo.chan{k, 1} = sprintf('Channel %02.0f: %s', chan, hdr.label{chan});
        
        % sample rate ---
        import{k}.sr = hdr.Fs;
        
        % get data
        import{k}.data = indata(chan, :);
    
    else                % marker channels: get the ascending flank of each marker
        sourceinfo.chan{k, 1} = 'Automatically extracted marker recordings';
        % time unit
        import{k}.sr = 1./hdr.Fs;
        import{k}.marker = 'timestamps';
        import{k}.data = [mrk.sample];
        m_val = {mrk.value};
        val_length = length(m_val);
        val = cell(val_length, 1);
        % convert empty cells into empty strings
        for i=1:val_length
            v = m_val{i};
            if ~ischar(v) && isempty(v)
                val{i} = '';
            else
                val{i} = v;
            end;
        end;
        % convert into double
        num_val = str2double(regexprep(val, '[^0-9]*([0-9,.]*)', '$1'));
        import{k}.markerinfo.value = num_val;
        import{k}.markerinfo.name  = {mrk.type};
    end;
       
end;

% clear path and return
% -------------------------------------------------------------------------
rmpath([settings.path, 'Import', filesep, 'fieldtrip']); 
sts = 1;
return;



