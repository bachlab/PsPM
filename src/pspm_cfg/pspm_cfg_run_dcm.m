function out = pspm_cfg_run_dcm(job)
% Executes pspm_dcm
%% initialise
global settings
if isempty(settings), pspm_init; end
eventnameflag = 1;
model = struct();
options = struct();
%% construct job structure
% modelfile & overwrite
model.modelfile = pspm_cfg_selector_outputfile('run', job);
options.overwrite = job.output.overwrite;
% datafiles & events
nrSession = size(job.session,2);
for iSession=1:nrSession
  % datafile
  datafile{iSession} = job.session(iSession).datafile{1};
  % events
  if isfield(job.session(iSession).timing,'timingfile')
    timing{1,iSession} = job.session(iSession).timing.timingfile{1};
    eventnameflag = 0;
  else
    nrEvents = size(job.session(iSession).timing.timing_man,2);
    for iEvents=1:nrEvents
      if isempty(job.session(iSession).timing.timing_man(iEvents).name)
        eventnameflag = 0;
      elseif eventnameflag == 0
      elseif iSession == 1
        eventnames{iEvents} = job.session(iSession).timing.timing_man(iEvents).name;
      elseif ~strcmpi(eventnames{iEvents}, job.session(iSession).timing.timing_man(iEvents).name)
        warning('Event names inconsistent across sessions - event names will not be used.');
        eventnameflag = 0;
      end
      timing{1,iSession}{1,iEvents} = job.session(iSession).timing.timing_man(1,iEvents).onsets;
    end
  end
  % conditions
  nrCond = size(job.session(iSession).condition,2);
  for iCond=1:nrCond
    condition{1,iSession}.name{1,iCond} = job.session(iSession).condition(iCond).name;
    condition{1,iSession}.index{1,iCond} = job.session(iSession).condition(iCond).index;
  end
  for iCond=1:size(job.session(iSession).condition,2)
    for iIndex=1:length(job.session(iSession).condition(iCond).index)
      indexNr = job.session(iSession).condition(iCond).index(iIndex);
      options.trlnames{1,iSession}{indexNr} = job.session(iSession).condition(iCond).name;
    end
  end
  % missing epochs
  if isfield(job.session(iSession).missing,'epochs')
    if isfield(job.session(iSession).missing.epochs,'datafile')
      model.missing{1,iSession} = job.session(iSession).missing.epochs.datafile{1};
    else
      model.missing{1,iSession} = job.session(iSession).missing.epochs.epochentry;
    end
  elseif isfield(job.session(iSession).missing, 'no_epochs')
    model.missing{1,iSession} = [];
  end
end
model.datafile = datafile;
model.timing = timing;
% filter
filter = pspm_cfg_selector_filter('run', job.data_options.filter);
if isstruct(filter)
    model.filter = filter;
end
% normalization, subsession threshold
model = pspm_update_struct(model, job.data_options, {'norm', 'substhresh'});
% constrained model
model.constrained = job.data_options.constr_model;
% channel number
if isfield(job.chan, 'chan_nr')
  model.channel = job.chan.chan_nr;
end
if isfield(job.resp_options.rf, 'disabled')
    options.rf = 0;
else
    options.rf = job.resp_options.rf.datafile;
end
% options
options = pspm_update_struct(options, job.resp_options, {'crfupdate',...
                                                         'indrf',...
                                                         'getrf'});
options = pspm_update_struct(options, job.inv_options, {'depth',...
                                                        'sfpre',...
                                                        'sfpost',...
                                                        'sffreq',...
                                                        'sclpre',...
                                                        'sclpost',...
                                                        'ascr_sigma_offset',...
                                                        'dispwin',...
                                                        'dispsmallwin'});
% condition and event names
if isfield(options, 'trlnames')
  options.trlnames = [options.trlnames{:}]; % collapse over sessions
end
if eventnameflag
  options.eventnames = eventnames;
end
pspm_dcm(model, options);
out = {model.modelfile};


