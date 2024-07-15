function vout = pspm_cfg_vout_outchannel(job)
% common function for generating output channel dependencies
vout = cfg_dep;
vout.sname      = 'Output Channel';
vout.tgt_spec   = cfg_findspec({{'class','cfg_entry', 'strtype', 'i'}});
vout.src_output = substruct('()',{1});