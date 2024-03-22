function pspm_cfg_run_ecg_editor(job)
% Updated on 18-12-2023 by Teddy
options = struct();
fn = job.datafile{1};
ecg_chan = pspm_cfg_channel_selector('run', job.ecg_chan);
hb_chan = pspm_cfg_channel_selector('run', job.hb_chan);
if isfield(job.artefact_epochs, 'artefact_file')
  options.artefact = job.artefact_epochs.artefact_file{1};
else
  options.artefact = '';
end
options = pspm_update_struct(options, job.faulty_settings, {'factor',...
                                                            'limit.upper',...
                                                            'limit.lower'});
pspm_ecg_editor(fn, ecg_chan, options);
