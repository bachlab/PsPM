function [out] = pspm_cfg_run_proc_illuminance(job)
% Updated on 19-12-2023 by Teddy
src_file = job.lum_file{1};
out_file = [job.outdir{1}, filesep, job.filename];
if isempty(regexpi(out_file, '.*\.mat$'))
    out_file = [out_file, '.mat'];
end
sr = job.sr;
options = struct();
options.fn = out_file;
options.bf.duration = job.bf.duration;
options.bf.offset = job.bf.offset;
options.overwrite = job.overwrite;
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
