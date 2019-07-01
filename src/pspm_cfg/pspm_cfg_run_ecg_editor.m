function pspm_cfg_run_ecg_editor(job)

% $Id$
% $Rev$

options = struct();
fn = job.datafile{1};

if isfield(job.ecg_chan, 'chan_nr')
    ecg_chan = job.ecg_chan.chan_nr;
else
    ecg_chan = -1;
end;

if isfield(job.hb_chan, 'chan_nr')
    options.hb = job.hb_chan.chan_nr;
else
    options.hb = -1;
end;

if isfield(job.artefact_epochs, 'artefact_file')
    options.artefact = job.artefact_epochs.artefact_file{1};
else
    options.artefact = '';
end;

options.factor = job.faulty_settings.factor;
options.limit.upper = job.faulty_settings.limit.upper;
options.limit.lower = job.faulty_settings.limit.lower;


pspm_ecg_editor(fn, ecg_chan, options);