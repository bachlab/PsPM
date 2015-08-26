function [params] = scr_cfg_run_glm(job)
% Gets together model and appropriate options and passes them back to
% scr_cfg_run_glm_<modality> which then calls the scr_glm function after
% the appropriate parameters have been passed/changed.

global settings
if isempty(settings), scr_init; end;

model.modelfile = [job.outdir{1}, filesep, job.modelfile '.mat'];

nrSession = size(job.session,2);
for iSession=1:nrSession
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
%     if ~isfield(job.session(iSession).nuisance,'no_nuisance')
%         model.nuisance{iSession,1} = job.session(iSession).nuisance.nuisancefile{1};
%     else
%         model.nuisance{iSession,1} = [];
%     end
    
end

% timeunits
model.timeunits = fieldnames(job.timeunits);
model.timeunits = model.timeunits{1};

% marker channel
if isfield(job.timeunits, 'markers')
    if job.timeunits.markers.mrk_chan ~= 0
        options.marker_chan_num = job.timeunits.markers.mrk_chan;
    end
end


% normalize
model.norm = job.norm;

% filter
if isfield(job.filter,'def')
    model.filter = settings.glm(1,1).filter;
else
    % lowpass
    if isfield(job.filter.edit.lowpass,'disable')
        model.filter.lpfreq = NaN;
        model.filter.lporder = settings.glm(1,1).filter.lporder;
    else
        model.filter.lpfreq = job.filter.edit.lowpass.enable.freq;
        model.filter.lporder = job.filter.edit.lowpass.enable.order;
    end
    % highpass
    if isfield(job.filter.edit.highpass,'disable')
        model.filter.hpfreq = NaN;
        model.filter.hporder = settings.glm(1,1).filter.hporder;
    else
        model.filter.hpfreq = job.filter.edit.highpass.enable.freq;
        model.filter.hporder = job.filter.edit.highpass.enable.order;
    end
    model.filter.down = job.filter.edit.down; % sampling rate
    model.filter.direction = job.filter.edit.direction; % sampling rate
end

% channel number
if isfield(job.chan, 'chan_nr')
    model.channel = job.chan.chan_nr;
end

% options
options.overwrite = job.overwrite;

params.model = model;
params.options = options;
