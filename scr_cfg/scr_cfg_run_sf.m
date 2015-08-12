function out = scr_cfg_run_sf(job)
% Executes scr_sf

% $Id$
% $Rev$

global settings
if isempty(settings), scr_init; end;

% filename
model.datafile = job.datafile{1};

% outputfile
model.modelfile = [job.outdir{1}, filesep, job.modelfile, '.mat'];

% method
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
    % lowpass
    if isfield(job.filter.edit.lowpass,'disable')
        filter.lpfreq = NaN;
        filter.lporder = settings.dcm{1,2}.filter.lporder;
    else
        filter.lpfreq = job.filter.edit.lowpass.enable.freq;
        filter.lporder = job.filter.edit.lowpass.enable.order;
    end
    % highpass
    if isfield(job.filter.edit.highpass,'disable')
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

% channel
if isfield(job.chan, 'chan_nr')
   model.channel = job.chan.chan_nr;
end

% options
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

options.dispwin = job.dispwin;
options.dispsmallwin = job.dispsmallwin;

out = scr_sf(model, options);