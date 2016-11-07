function [out, dcm] = pspm_cfg_run_dcm(job)
% Executes pspm_dcm

% $Id$
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings
if isempty(settings), pspm_init; end;

eventnameflag = 1;

% construct job structure
% -------------------------------------------------------------------------
model.modelfile = [job.outdir{1}, filesep,  job.modelfile, '.mat'];

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
            end;
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
end
model.datafile = datafile;
model.timing = timing;

% normalization
model.norm = job.data_options.norm;

% filter
if ~isfield(job.data_options.filter,'def')
    % lowpass
    if isfield(job.data_options.filter.edit.lowpass,'disable')
        filter.lpfreq = NaN;
        filter.lporder = settings.dcm{1,1}.filter.lporder;
    else
        filter.lpfreq = job.data_options.filter.edit.lowpass.enable.freq;
        filter.lporder = job.data_options.filter.edit.lowpass.enable.order;
    end
    % highpass
    if isfield(job.data_options.filter.edit.highpass,'disable')
        filter.hpfreq = NaN;
        filter.hporder = settings.dcm{1,1}.filter.hporder;
    else
        filter.hpfreq = job.data_options.filter.edit.highpass.enable.freq;
        filter.hporder = job.data_options.filter.edit.highpass.enable.order;
    end
    filter.down = job.data_options.filter.edit.down; % sampling rate
    filter.direction = job.data_options.filter.edit.direction; % sampling rate
    model.filter = filter;
end


% channel number
if isfield(job.chan, 'chan_nr')
    model.channel = job.chan.chan_nr;
end

% options
options.crfupdate = job.resp_options.crfupdate;
options.indrf = job.resp_options.indrf;
options.getrf = job.resp_options.getrf;
options.rf = job.resp_options.rf;

options.depth = job.inv_options.depth;
options.sfpre = job.inv_options.sfpre;
options.sfpost = job.inv_options.sfpost;
options.sffreq = job.inv_options.sffreq;
options.sclpre = job.inv_options.sclpre;
options.sclpost = job.inv_options.sclpost;
options.aSCR_sigma_offset = job.inv_options.ascr_sigma_offset;

options.dispwin = job.disp_options.dispwin;
options.dispsmallwin = job.disp_options.dispsmallwin;

% condition and event names
if isfield(options, 'trlnames')
    options.trlnames = [options.trlnames{:}]; % collapse over sessions
end;
if eventnameflag
    options.eventnames = eventnames;
end;
[varargout] = pspm_dcm(model, options);

if numel(varargout) < 2
    out = varargout;
    dcm = [];
else
    out = varargout{1};
    dcm = varargout{2};
end

if ~iscell(out)
    out = {out};
end