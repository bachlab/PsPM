function out = pspm_cfg_run_trim(job)
% Updated on 19-12-2023 by Teddy
options = struct();
options = pspm_update_struct(options, job, {'overwrite'});
if isfield(job.ref,'ref_file')
  from = job.ref.ref_file.from;
  to = job.ref.ref_file.to;
  ref = 'file';
elseif isfield(job.ref,'ref_mrk')
  from = job.ref.ref_mrk.from;
  to = job.ref.ref_mrk.to;
  ref = 'marker';
  options.marker_chan_num = pspm_cfg_selector_channel('run', job.ref.ref_mrk.chan);
elseif isfield(job.ref,'ref_any_mrk')
  from = job.ref.ref_any_mrk.from.mrksec;
  to = job.ref.ref_any_mrk.to.mrksec;
  ref = [job.ref.ref_any_mrk.from.mrkno ...
    job.ref.ref_any_mrk.to.mrkno];
  options.marker_chan_num = pspm_cfg_selector_channel('run', job.ref.ref_any_mrk.chan);  
elseif isfield(job.ref,'ref_mrk_vals')
  from =job.ref.ref_mrk_vals.from.mrksec;
  to =job.ref.ref_mrk_vals.to.mrksec;
  ref = {job.ref.ref_mrk_vals.from.mrval,...
    job.ref.ref_mrk_vals.to.mrval};
  options.marker_chan_num = pspm_cfg_selector_channel('run', job.ref.ref_mrk_vals.chan);  
else
  error('Reference invalid');
end
if ~isfield(options,'marker_chan_num')
  options.marker_chan_num = 0; % Default value
end
[sts, out] = pspm_trim(job.datafile{1}, from, to, ref, options);
out = {out};

