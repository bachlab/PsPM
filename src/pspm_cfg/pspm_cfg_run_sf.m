function out = pspm_cfg_run_sf(job)
% Updated on 19-12-2023 by Teddy
global settings
if isempty(settings), pspm_init; end
model.datafile = job.datafile{1};
model.modelfile = [job.outdir{1}, filesep, job.modelfile, '.mat'];
if strcmp(job.method, 'all')
  model.method = {'auc', 'scl', 'dcm', 'mp'};
else
  model.method = job.method;
end
% timeunits
timeunits = fieldnames(job.timeunits);
timeunits = timeunits{1};
model.timeunits = timeunits;
% epochs
if ~strcmp(timeunits, 'whole')
  if isfield(job.timeunits.(timeunits).epochs,'epochfile')
    epochs = job.timeunits.(timeunits).epochs.epochfile{1};
  else
    epochs = job.timeunits.(timeunits).epochs.epochentry;
  end
else
  epochs = [];
end
model.timing = epochs;

% filter
if ~isfield(job.filter,'def')
  if isfield(job.filter.edit.lowpass,'disable') % lowpass
    filter.lpfreq = NaN;
    filter.lporder = settings.dcm{1,2}.filter.lporder;
  else
    filter.lpfreq = job.filter.edit.lowpass.enable.freq;
    filter.lporder = job.filter.edit.lowpass.enable.order;
  end
  if isfield(job.filter.edit.highpass,'disable') % highpass
    filter.hpfreq = NaN;
    filter.hporder = settings.dcm{1,2}.filter.hporder;
  else
    filter.hpfreq = job.filter.edit.highpass.enable.freq;
    filter.hporder = job.filter.edit.highpass.enable.order;
  end
  filter.down = job.filter.edit.down; % sampling rate
  filter.direction = job.filter.edit.direction; % sampling rate
  model.filter = filter;
end
if isfield(job.chan, 'chan_nr')
  model.channel = job.chan.chan_nr;
end
options.overwrite = job.overwrite;
if strcmp(timeunits, 'markers')
  options.marker_chan_num = job.timeunits.(timeunits).mrk_chan;
end
options.threshold = job.threshold;
if ~isempty(job.theta)
  options.theta = job.theta;
end
if ~isempty(job.fresp)
  options.fresp = job.fresp;
end
if ~isempty(job.missing)
  if ischar(job.missing.missingepoch_include.missingepoch_file{1})
    model.missing = job.missing.missingepoch_include.missingepoch_file{1};
  end
end
options.dispwin = job.dispwin;
options.dispsmallwin = job.dispsmallwin;
out = pspm_sf(model, options);