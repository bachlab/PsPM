function out = pspm_cfg_run_glm(job, model, options)

% call common data & design selector
[newmodel, newoptions] = pspm_cfg_selector_data_design('run', job);

% integrate into existing structure
fields = fieldnames(newmodel);
for i = 1:numel(fields)
    model.(fields{i}) = newmodel.(fields{i});
end
fields = fieldnames(newoptions);
for i = 1:numel(fields)
    options.(fields{i}) = newoptions.(fields{i});
end

% modefile 
model.modelfile = pspm_cfg_selector_outputfile('run', job);

% normalize
model = pspm_update_struct(model, job, {'norm'});

% filter
model.filter = pspm_cfg_selector_filter('run', job.filter);
if ischar(model.filter) && strcmpi(model.filter, 'none')
    model = rmfield(model, 'filter');
end

model.channel = pspm_cfg_selector_channel('run', job.chan);

if isfield(job.latency, 'free')
  model.latency = 'free';
  model.window = job.latency.free.time_window;
else
  model.latency = 'fixed';
end

% options
options = pspm_update_struct(options, job.output, {'overwrite'});

% set option to create stats exclude if set
if isfield(job.exclude_missing,'exclude_missing_yes')
  length = job.exclude_missing.exclude_missing_yes.segment_length;
  cut = job.exclude_missing.exclude_missing_yes.cutoff;
  options.exclude_missing = struct('segment_length',length ,'cutoff', cut);
end

pspm_glm(model, options);
out = {model.modelfile};
