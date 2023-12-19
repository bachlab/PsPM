function out = pspm_cfg_run_downsample(job)
% Updated on 18-12-2023 by Teddy
if isfield(job.chan,'all_chan')
  chan = 0;
else
  chan = job.chan.chan_vec;
end
options.overwrite = job.overwrite;
[~, out] = pspm_down(job.datafile, job.newfreq, chan, options);
if ~iscell(out)
  out ={out};
end