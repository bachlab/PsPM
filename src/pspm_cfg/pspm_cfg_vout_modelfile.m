function vout = pspm_cfg_vout_modelfile(job)
vout = cfg_dep;
vout.sname      = 'Model File';
% this can be entered into any file selector
vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
vout.src_output = substruct('.','modelfile');