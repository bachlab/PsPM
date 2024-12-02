function out = pspm_cfg_run_sf(job)
% Updated on 19-12-2023 by Teddy

options = struct();
model.datafile = job.datafile{1};
model.modelfile = pspm_cfg_selector_outputfile('run', job);
if strcmp(job.method, 'all')
  model.method = {'auc', 'scl', 'dcm', 'mp'};
else
  model.method = job.method;
end
% timeunits
timeunits = fieldnames(job.timeunits);
timeunits = timeunits{1}; % to be used for dynamic referencing below
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
  model.filter = pspm_cfg_selector_filter('run', job.filter);
end
if isfield(job.chan, 'chan_nr')
  model.channel = job.chan.chan_nr;
end
if strcmp(timeunits, 'markers')
  options.marker_chan_num = pspm_cfg_selector_channel('run', job.timeunits.markers.chan);
end
if ~isempty(job.theta) 
  options.theta = job.theta;
end
if ~isempty(job.fresp)
  options.fresp = job.fresp;
end
if ~isempty(job.missing) && isfield(job.missing, 'missingepoch_include')
  if ischar(job.missing.missingepoch_include.missingepoch_file{1})
    model.missing = job.missing.missingepoch_include.missingepoch_file{1};
  end
end
options = pspm_update_struct(options, job, {'dispwin', ...
                                            'dispsmallwin', ...
                                            'overwrite', ...
                                            'threshold'});
pspm_sf(model, options);
out = {model.modelfile};


