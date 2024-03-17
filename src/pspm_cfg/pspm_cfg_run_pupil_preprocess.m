function [out] = pspm_cfg_run_pupil_preprocess(job)
% Updated on 17-03-2024 by Teddy
fn                        = job.datafile{1};
options                   = struct();
chankey                   = fieldnames(job.channel);
chankey                   = chankey{1};
options.channel           = job.channel.(chankey);
chankey                   = fieldnames(job.channel_combine);
chankey                   = chankey{1};
options.channel_combine   = job.channel_combine.(chankey);
options.chan_valid_cutoff = job.chan_valid_cutoff/100;
settkey                   = fieldnames(job.settings);
settkey                   = settkey{1};
if strcmp(settkey, 'custom_settings')
  options = pspm_update_struct(options, job.settings, 'custom_settings');
end
options.segments= {};
for i = 1:numel(job.segments)
  options.segments{end + 1} = job.segments(i);
end
options = pspm_update_struct(options, job, {'chan_valid_cutoff',...
                                            'channel_action',...
                                            'plot_data'});
[~, out{1}] = pspm_pupil_pp(fn, options);
end