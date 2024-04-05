function [params] = pspm_cfg_run_glm(job, def_filter)
% updated on 19-12-2023 by Teddy
global settings
if isempty(settings), pspm_init; end
options = struct();
model.modelfile = [job.outdir{1}, filesep, job.modelfile '.mat'];
nrSession = size(job.session,2);
for iSession = 1:nrSession
  % datafile
  model.datafile{iSession,1} = job.session(iSession).datafile{1};
  % missing epochs
  if isfield(job.session(iSession).missing,'epochs')
    if isfield(job.session(iSession).missing.epochs,'epochfile')
      model.missing{1,iSession} = job.session(iSession).missing.epochs.epochfile{1};
    else
      model.missing{1,iSession} = job.session(iSession).missing.epochs.epochentry;
    end
  end
  % data & design
  if isfield(job.session(iSession).data_design,'no_condition')
    model.timing = {};
  elseif isfield(job.session(iSession).data_design,'condfile')
    model.timing{iSession,1} = job.session(iSession).data_design.condfile{1};
  elseif isfield(job.session(iSession).data_design,'marker_cond')
    if isfield(job.session(iSession).data_design.marker_cond.marker_values,'marker_values_names')
      model.timing{iSession,1}.markervalues = strsplit(job.session(iSession).data_design.marker_cond.marker_values.marker_values_names{1});
    else
      model.timing{iSession,1}.markervalues = job.session(iSession).data_design.marker_cond.marker_values.marker_values_val;
    end
    model.timing{iSession,1}.names  = strsplit(job.session(iSession).data_design.marker_cond.cond_names{1});
  else
    nrCond = size(job.session(iSession).data_design.condition,2);
    for iCond=1:nrCond
      model.timing{iSession,1}.names{1,iCond} = job.session(iSession).data_design.condition(iCond).name;
      model.timing{iSession,1}.onsets{1,iCond} = job.session(iSession).data_design.condition(iCond).onsets;
      model.timing{iSession,1}.durations{1,iCond} = job.session(iSession).data_design.condition(iCond).durations;
      nrPmod = size(job.session(iSession).data_design.condition(iCond).pmod,2);
      if nrPmod ~= 0
        for iPmod=1:nrPmod
          model.timing{iSession,1}.pmod(1,iCond).name{1,iPmod} = job.session(iSession).data_design.condition(iCond).pmod(iPmod).name;
          model.timing{iSession,1}.pmod(1,iCond).param{1,iPmod} = job.session(iSession).data_design.condition(iCond).pmod(iPmod).param;
          model.timing{iSession,1}.pmod(1,iCond).poly{1,iPmod} = job.session(iSession).data_design.condition(iCond).pmod(iPmod).poly;
        end
      else
        model.timing{iSession,1}.pmod(1,iCond).name = [];
        model.timing{iSession,1}.pmod(1,iCond).param = [];
        model.timing{iSession,1}.pmod(1,iCond).poly = [];
      end
    end
  end
  % nuisance
  if ~isempty(job.session(iSession).nuisancefile{1})
    model.nuisance{iSession,1} = job.session(iSession).nuisancefile{1};
  else
    model.nuisance{iSession,1} = [];
  end
end
% timeunits
if isfield(job.session(iSession).data_design,'marker_cond')
  model.timeunits = 'markervalues';
else
  model.timeunits = fieldnames(job.timeunits);
  model.timeunits = model.timeunits{1};
end
% marker channel
if isfield(job.timeunits, 'markers')
  options.marker_chan_num = pspm_cfg_channel_selector('run', job.timeunits.markers.chan);
end
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
