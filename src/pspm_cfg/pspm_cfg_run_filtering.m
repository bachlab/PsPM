function out = pspm_cfg_run_filtering(job)
% Reviewed and updated on 18-Dec-2023 by Teddy
options = struct();
options = pspm_update_struct(options, job, {'overwrite'});
filtertype = fieldnames(job.filtertype);
filtertype = filtertype{1};
datafile = job.datafile;
datafile = datafile{1};
channelnumber = pspm_cfg_channel_selector('run', job);
switch filtertype
  case 'median'
    n = job.filtertype.(filtertype).nr_time_pt;
    out = pspm_pp(filtertype, datafile, channelnumber, n, options);
  case 'butter'
    filt = struct();
    if isfield(job.filtertype.(filtertype).freqLP, 'freqLP')
      filt.lpfreq  = job.filtertype.(filtertype).freqLP.freqLP;
    else
      filt.lpfreq  = 'none';
    end
    filt.lporder   = job.filtertype.(filtertype).orderLP;
    if isfield(job.filtertype.(filtertype).freqHP, 'freqHP')
      filt.hpfreq  = job.filtertype.(filtertype).freqHP.freqHP;
    else
      filt.hpfreq  = 'none';
    end
    filt.hporder   = job.filtertype.(filtertype).orderHP;
    filt.direction = job.filtertype.(filtertype).direction;
    filt.down      = job.filtertype.(filtertype).down.down;
    out = pspm_pp(filtertype, datafile, channelnumber, filt, options);
  case 'scr_pp'
    scr_job = job.filtertype.(filtertype);
    options = pspm_update_struct(options, scr_job, {'min',...
                                                    'max',...
                                                    'slope',...
                                                    'deflection_threshold',...
                                                    'data_island_threshold',...
                                                    'expand_epochs'});
    if isfield(scr_job.missing_epochs, 'write_to_file')
      if isfield(scr_job.missing_epochs.write_to_file,'filename') && ...
          isfield(scr_job.missing_epochs.write_to_file,'outdir')
        options.missing_epochs_filename = fullfile(...
          scr_job.missing_epochs.write_to_file.outdir{1}, ...
          scr_job.missing_epochs.write_to_file.filename);
      end
    end
    if isfield(scr_job, 'change_data')
      options.channel_action = 'add';
    else
      options.channel_action = 'replace';
    end
    [~, out] = pspm_scr_pp(datafile, options);
end
