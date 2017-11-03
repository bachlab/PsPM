function [out,datafiles, datatype, import, options] = pspm_cfg_run_import(job)
% Arranges the users inputs to the 4 input arguments for the function
% pspm_import and executes it

% $Id$
% $Rev$

datatype = fieldnames(job.datatype);
datatype = datatype{1};

datafiles = job.datatype.(datatype).datafile;

% Import
n = size(job.datatype.(datatype).importtype,2); % Nr. of channels

% Check if multioption is off
if ~iscell(job.datatype.(datatype).importtype)
    importtype = job.datatype.(datatype).importtype;
    job.datatype.(datatype).importtype = cell(1);
    job.datatype.(datatype).importtype{1} = importtype;
end

import = cell(1,n);

for i=1:n
    % Importtype
    type = fieldnames(job.datatype.(datatype).importtype{i});
    import{i}.type = type{1};
    
    % Channel nr.
    channel = job.datatype.(datatype).importtype{i}.(type{1}).chan_nr;
    if isfield(channel, 'chan_search')
        import{i}.channel = 0;
    elseif isfield(channel, 'chan_nr_def')
        import{i}.channel = channel.chan_nr_def;
    else
        import{i}.channel = channel.chan_nr_spec;
    end
    
    % Check if sample rate is available
    if isfield(job.datatype.(datatype).importtype{i}.(type{1}), 'sample_rate')
        import{i}.sr = job.datatype.(datatype).importtype{i}.(type{1}).sample_rate;
    end
    
    % Check if transfer function available
    if isfield(job.datatype.(datatype).importtype{i}.(type{1}), 'scr_transfer')
        transfer = fieldnames(job.datatype.(datatype).importtype{i}.(type{1}).scr_transfer);
        transfer = transfer{1};
        switch transfer
            case 'file'
                file = job.datatype.(datatype).importtype{i}.(type{1}).scr_transfer.file;
                file = file{1};
                import{i}.transfer = file;
            case 'input'
                import{i}.transfer.c = job.datatype.(datatype).importtype{i}.(type{1}).scr_transfer.input.transfer_const;
                import{i}.transfer.offset = job.datatype.(datatype).importtype{i}.(type{1}).scr_transfer.input.offset;
                import{i}.transfer.Rs = job.datatype.(datatype).importtype{i}.(type{1}).scr_transfer.input.resistor;
                import{i}.transfer.recsys = job.datatype.(datatype).importtype{i}.(type{1}).scr_transfer.input.recsys;
            case 'none'
                import{i}.transfer = 'none';
        end
    end

    % Check if eytracker distance is available
    if ~isempty(regexpi(type, 'pupil')) && ...
            isfield(job.datatype.(datatype), 'eyelink_trackdist')
        transfer = job.datatype.(datatype).eyelink_trackdist;
        if transfer > 0
            import{i}.eyelink_trackdist = transfer;
        else
            import{i}.eyelink_trackdist = 'none';
        end
    end
    
end

options.overwrite = job.overwrite;

out = pspm_import(datafiles, datatype, import, options);
