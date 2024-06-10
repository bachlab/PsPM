function [params] = pspm_cfg_run_glm(job, def_filter)
% updated on 19-12-2023 by Teddy
global settings
if isempty(settings), pspm_init; end

% call common data & design selector
[model, options] = pspm_cfg_data_design_selector('run', job);

% modefile 
model.modelfile = [job.outdir{1}, filesep, job.modelfile '.mat'];

% normalize
model = pspm_update_struct(model, job, {'norm'});
% filter
if isfield(job.filter,'def')
  model.filter = def_filter;
else
  % lowpass
  if isfield(job.filter.edit.lowpass,'disable')
    model.filter.lpfreq = NaN;
    model.filter.lporder = def_filter.lporder;
  else
    model.filter.lpfreq = job.filter.edit.lowpass.enable.freq;
    model.filter.lporder = job.filter.edit.lowpass.enable.order;
  end
  % highpass
  if isfield(job.filter.edit.highpass,'disable')
    model.filter.hpfreq = NaN;
    model.filter.hporder = def_filter.hporder;
  else
    model.filter.hpfreq = job.filter.edit.highpass.enable.freq;
    model.filter.hporder = job.filter.edit.highpass.enable.order;
  end
  model.filter.down = job.filter.edit.down; % sampling rate
  model.filter.direction = job.filter.edit.direction; % sampling rate
end
model.channel = pspm_cfg_channel_selector('run', job.chan);
if isfield(job.latency, 'free')
  model.latency = 'free';
  model.window = job.latency.free.time_window;
else
  model.latency = 'fixed';
end
% options
options = pspm_update_struct(options, job, {'overwrite'});
% set option to create stats exclude if set
if isfield(job.exclude_missing,'exclude_missing_yes')
  length = job.exclude_missing.exclude_missing_yes.segment_length;
  cut = job.exclude_missing.exclude_missing_yes.cutoff;
  options.exclude_missing = struct('segment_length',length ,'cutoff', cut);
end
params.model = model;
params.options = options;
