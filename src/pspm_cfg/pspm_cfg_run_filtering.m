function out = pspm_cfg_run_filtering(job)
% Reviewed and updated on 18-Dec-2023 by Teddy
options = struct();
options = pspm_update_struct(options, job, {'channel_action'});
filtertype = fieldnames(job.filtertype);
filtertype = filtertype{1};
datafile = job.datafile;
datafile = datafile{1};
channelnumber = pspm_cfg_selector_channel('run', job);
switch filtertype
  case 'leaky_integrator'
    tau = job.filtertype.(filtertype).tau;
    out = pspm_pp(filtertype, datafile, channelnumber, tau, options);
  case 'median'
    n = job.filtertype.(filtertype).nr_time_pt;
    out = pspm_pp(filtertype, datafile, channelnumber, n, options);
  case 'butter'
    filt = pspm_cfg_selector_filter('run', job.filtertype.(filtertype));
    out = pspm_pp(filtertype, datafile, channelnumber, filt, options);
end
