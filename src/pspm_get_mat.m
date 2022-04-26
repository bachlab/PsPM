function [sts, import, sourceinfo] = pspm_get_mat(datafile, import)
% pspm_get_mat is the main function for import of matlab files
% FORMAT: [sts, import, sourceinfo] = pspm_get_mat(datafile, import);
%      datafile: a .mat file that contains a variable 'data' that is either
%                  - a cell array of channel data vectors
%                  - a datapoints x channel matrix
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id$
% $Rev$

% v006 lr  09.09.2013 added .marker field for event channels
% v005 lr  05.09.2013 added warning IDs and additional warnings
% v004 drb 31.07.2013 changed for 3.0 architecture
% v003 drb 11.02.2011 comply with new pspm_import requirements
% v002 drb 8.1.2010 fixed a bug with error handling
% v001 drb 16.9.2009

%% Initialise
global settings
if isempty(settings)
	pspm_init;
end
sts = -1;
sourceinfo = [];

% load data and check contents
% -------------------------------------------------------------------------
data = load (datafile);
if ~isfield(data, 'data')
    warning('ID:invalid_data_structure', 'No variable ''data'' in file %s.\n', datafile); data = []; return
elseif isnumeric(data.data) 
    for k = 1:size(data.data, 2)
        foo{k} = data.data(:, k);
    end;
    data = foo;
    chantype = 'column';
elseif iscell(data.data)
    for k = 1:numel(data.data)
        if ~(isnumeric(data.data{k}) && isvector(data.data{k}))
            warning('ID:invalid_data_structure', 'All ellements of the cellarray ''data'' in file %s must be numeric vectors.\n', datafile); return;
        end
    end
    data = data.data;
    chantype = 'cell';
else
    warning('ID:invalid_data_structure', 'Variable ''data'' in file %s must be a cell or numeric.\n', datafile); return;
end;

% select desired channels
% -------------------------------------------------------------------------
for k = 1:numel(import)
    chan = import{k}.channel;
    
    if chan > numel(data), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;
    
    import{k}.data = data{chan};
    if strcmpi(settings.chantypes(import{k}.typeno).data, 'events') && ~isfield(import{k}, 'marker')
        if strcmpi(chantype, 'cell') && import{k}.sr <= settings.import.mat.sr_threshold
            import{k}.marker = 'timestamps';
        else
            import{k}.marker = 'continuous';
        end
    end
    sourceinfo.chan{k} = sprintf('Data %s %02.0', chantype, chan);
end;

sts = 1;
return;

