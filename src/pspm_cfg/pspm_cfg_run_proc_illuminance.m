function [out] = pspm_cfg_run_proc_illuminance(job)
% Updated on 08-01-2024 by Teddy
src_file = job.lum_file{1};
out_file = [job.outdir{1}, filesep, job.filename];
if isempty(regexpi(out_file, '.*\.mat$', 'once'))
  out_file = [out_file, '.mat'];
end
sr = job.sr;
options = struct();
options.fn = out_file;
options.overwrite = job.overwrite;
%% basis function
options.bf = struct();
options.bf = pspm_update_struct(options.bf, job.bf, {'duration','offset'});
dil_f = fields(job.bf.dilation);
% only check first field
switch dil_f{1}
  case 'ldrf_gm'
    options.bf.dilation.fhandle = @pspm_bf_ldrf_gm;
  case 'ldrf_gu'
    options.bf.dilation.fhandle = @pspm_bf_ldrf_gu;
end
con_f = fields(job.bf.constriction);
switch con_f{1}
  case 'lcrf_gm'
    options.bf.constriction.fhandle = @pspm_bf_lcrf_gm;
end
[~, nuis_file] = pspm_process_illuminance(src_file, sr, options);
out{1} = nuis_file;
