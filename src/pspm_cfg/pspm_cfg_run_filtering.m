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
  case 'leaky_integrator'
    tau = job.filtertype.(filtertype).tau;
    out = pspm_pp(filtertype, datafile, channelnumber, tau, options);
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
end
