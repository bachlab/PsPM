function vout = pspm_cfg_vout_dynamic(job)
% common function for generating output channel dependencies
if isfield(job.outputtype, 'channel_action')
    vout = pspm_cfg_vout_outchannel(job);
else
    vout = pspm_cfg_vout_outfile(job);
end

