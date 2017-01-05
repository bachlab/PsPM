function [sts, import, sourceinfo] = pspm_get_labchart(datafile, import)
% pspm_get_labchartmat is the main function for import of LabChart 
% (ADInstruments) files.
% See pspm_labchartmat_in and pspm_labchart_mat_ex for import of matlab 
% files that were exported either using the built-in function or the
% online conversion tool.
% 
%
% FORMAT: [sts, import, sourceinfo] = pspm_get_labchart(datafile, import);
%
%__________________________________________________________________________
% PsPM 3.1
% (C) 2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end;
sourceinfo = []; sts = -1;

% add path
% -------------------------------------------------------------------------
addpath([settings.path, 'Import', filesep, 'labchart' filesep 'adi']);

% load & check data
% -------------------------------------------------------------------------
[labchart] = adi.readFile(datafile);

% loop through import jobs
% -------------------------------------------------------------------------
for k = 1:numel(import)   
    
    if strcmpi(import{k}.type, 'marker')
        if labchart.n_records > 0
            comments = labchart.records(1);
            if ~isempty(comments.comments)
                import{k}.data = [comments.comments(:).tick_position]./comments.tick_fs;
            else
                import{k}.data = [];
            end;
            import{k}.sr     = 1;
            import{k}.marker = 'timestamps';
            
            sourceinfo.chan{k, 1} = sprintf('Channel %02.0f: %s', k, 'Events');
        else
            warning('ID:channel_not_contained_in_file', ...
                'No marker channel in file %s found.\n', datafile); 
            return;
        end;
    else
        % define channel number ---
        if import{k}.channel > 0
            chan = import{k}.channel;
        else
            chan = pspm_find_channel(cellstr(labchart.channel_names(:)), import{k}.type);
            if chan < 1, return; end;
        end;
        
        if chan > labchart.n_channels, warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;
        
        sourceinfo.chan{k, 1} = sprintf('Channel %02.0f: %s', chan, labchart.channel_names{chan});
        
        lab_chan = labchart.channel_specs(chan);
        % get data ---
        import{k}.data = lab_chan.getData(1);
        % get units ---
        import{k}.units = lab_chan.units{:};
        % get sr ---
        import{k}.sr = lab_chan.fs;
    end;
end;
delete(labchart.file_h);
% clear path and return
% -------------------------------------------------------------------------
rmpath([settings.path, 'Import', filesep, 'labchart' filesep 'adi']);
sts = 1;
