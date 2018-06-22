function [out] = pspm_cfg_run_extract_segments(job)

% $Id$
% $Rev$

out = {};
options = struct();
mode = 'auto';

if isfield(job, 'mode')
    if isfield(job.mode, 'mode_automatic')
        mode = 'auto';
        glm_file = job.mode.mode_automatic.glm_file{1};        
    elseif isfield(job.mode, 'mode_manual')
        mode = 'manual';
        chan = job.mode.mode_manual.channel;
        fn = job.mode.mode_manual.datafiles;
        
        if isfield(job.mode.mode_manual.conditions, 'condition')
            conditions = job.mode.mode_manual.conditions.condition;
            tm = struct();
            tm.names = cell(numel(conditions),1);
            tm.onsets = cell(numel(conditions),1);
            tm.durations = cell(numel(conditions),1);
            for i = 1:numel(conditions)
                tm.names{i} = conditions(i).cond_name;
                tm.onsets{i} = conditions(i).cond_onsets;
                tm.durations{i} = conditions(i).cond_duration;
            end
        elseif isfield(job.mode.mode_manual.conditions, 'condition_files')
            tm = job.mode.mode_manual.conditions.condition_files;
        end
        
    end
    
    % extract options
    options.timeunit = job.options.timeunit;
    options.marker_chan = job.options.marker_chan;
    options.length = job.options.segment_length;
    
    field_name_nan_output = fieldnames(job.options.nan_output);
    switch field_name_nan_output{1}
        case 'nan_none'
            options.nan_output = 'none';
        case 'nan_screen'
            options.nan_output = 'screen';
        case 'nan_output_file'
            file_name = job.options.nan_output.nan_output_file.nan_file;
            file_path = job.options.nan_output.nan_output_file.nan_path{1};
            options.nan_output = fullfile(file_path, file_name);
    end
    
    % extract output
    options.overwrite = job.output.overwrite;
    options.plot = job.output.plot;
    
    out_file = job.output.output_file.file_name;
    out_path = job.output.output_file.file_path{1};
    
    options.outputfile = [out_path filesep out_file];   
    
    switch mode
        case 'auto'
            [~, out] = pspm_extract_segments(mode, glm_file, options);
        case 'manual'
            [~, out] = pspm_extract_segments(mode, fn, chan, tm, options);
    end
    out = {out.outputfile};
else
    warning('ID:invalid_input', 'No mode specified');
end