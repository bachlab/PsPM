function [out,datafiles, datatype, import, options] = pspm_cfg_run_import(job)
% Arranges the users inputs to the 4 input arguments for the function
% pspm_import and executes it

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

  % Check if flank option is available
  if isfield(job.datatype.(datatype).importtype{i}.(type{1}), 'flank_option') && ...
      ~strcmp(job.datatype.(datatype).importtype{i}.(type{1}).flank_option, 'default')
    import{i}.flank = job.datatype.(datatype).importtype{i}.(type{1}).flank_option;
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
        import{i}.transfer.c = ...
          job.datatype.(datatype).importtype{i}.(type{1}).scr_transfer.input.transfer_const;
        import{i}.transfer.offset = ...
          job.datatype.(datatype).importtype{i}.(type{1}).scr_transfer.input.offset;
        import{i}.transfer.Rs = ...
          job.datatype.(datatype).importtype{i}.(type{1}).scr_transfer.input.resistor;
        import{i}.transfer.recsys = ...
          job.datatype.(datatype).importtype{i}.(type{1}).scr_transfer.input.recsys;
      case 'none'
        import{i}.transfer = 'none';
    end
  end

  % Check if eytracker distance is available
  if ~isempty(regexpi(type, 'pupil'))
    if isfield(job.datatype.(datatype), 'eyelink_trackdist')
      transfer = job.datatype.(datatype).eyelink_trackdist;
      distance_unit = job.datatype.(datatype).distance_unit;

      if transfer > 0
        import{i}.eyelink_trackdist = transfer;
        import{i}.distance_unit = distance_unit;
      else
        import{i}.eyelink_trackdist = 'none';
        import{i}.distance_unit = '';
      end
    end

    if isfield(job.datatype.(datatype), 'viewpoint_target_unit')
      import{i}.target_unit = job.datatype.(datatype).viewpoint_target_unit;
    end

    if isfield(job.datatype.(datatype), 'smi_target_unit')
      import{i}.target_unit = job.datatype.(datatype).smi_target_unit;
      import{i}.stimulus_resolution = job.datatype.(datatype).smi_stimulus_resolution;
    end

    if isfield(job.datatype.(datatype), 'delimiter')
      import{i}.delimiter = job.datatype.(datatype).delimiter;
    end

    if isfield(job.datatype.(datatype), 'header_lines')
      import{i}.header_lines = job.datatype.(datatype).header_lines;
    end

    if isfield(job.datatype.(datatype), 'channel_names_line')
      import{i}.channel_names_line = job.datatype.(datatype).channel_names_line;
    end

    if isfield(job.datatype.(datatype), 'exclude_columns')
      import{i}.exclude_columns = job.datatype.(datatype).exclude_columns;
    end

  end

end

options.overwrite = job.overwrite;

out = pspm_import(datafiles, datatype, import, options);
