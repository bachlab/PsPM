function pspm_cfg_run_review2(job)
% Updated on 19-12-2023 by Teddy
if isempty(job.con)
    pspm_rev2(job.modelfile{1});
else
    pspm_rev2(job.modelfile{1}, job.con);
end