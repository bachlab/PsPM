function [out] = pspm_cfg_run_find_sounds(job)
% Updated on 19-12-2023 by Teddy
out = NaN;
file = job.datafile{1};
options = struct();
options.channel = pspm_cfg_channel_selector('run', job.chan);
if isfield(job.roi, 'region')
  options.roi = job.roi.region;
end
options = pspm_update_struct(options, job, 'threshold');
if isfield(job.diagnostic, 'diagnostics')
    d = job.diagnostic.diagnostics;
    if isfield(d.create_corrected_chan, 'yes')
        options.channel_output = 'corrected';
    end
    options.marker_chan_num = pspm_cfg_channel_selector('run', d.chan);
    if d.n_sounds > 0
      options.expectedSoundCount = job.output.diagnostic.n_sounds;
    end
    options.maxdelay = d.max_delay;
    diag_out = fieldnames(d.diag_output);
    switch diag_out{1}
      case 'hist_plot'
        options.plot = true;
      case 'text_only'
        options.plot = false;
    end
    [~, out, infos] = pspm_find_sounds(file, options);
end
