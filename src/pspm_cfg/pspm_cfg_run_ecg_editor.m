function pspm_cfg_run_ecg_editor(job)
% Updated on 18-12-2023 by Teddy
% Updated on 12-04-2026 by Bernhard von Raußendorf

options = struct();
fn = job.datafile{1};
ecg_chan = pspm_cfg_selector_channel('run', job.ecg_chan);
options.channel = pspm_cfg_selector_channel('run', job.hb_chan);
if isfield(job.artefact_epochs, 'artefact_file')
  options.missing = job.artefact_epochs.artefact_file{1};
else
  options.missing = [];
end

options = pspm_update_struct(options, job.faulty_settings, {'factor'});
options.limits.upper = job.faulty_settings.limits.upper;
options.limits.lower = job.faulty_settings.limits.lower;


pspm_ecg_editor(fn, ecg_chan, options);
