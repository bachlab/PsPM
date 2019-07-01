function pspm_cfg_run_review2(job)
% Runs review model - second level

% $Id$
% $Rev$

if isempty(job.con)
    pspm_rev2(job.modelfile{1});
else
    pspm_rev2(job.modelfile{1}, job.con);
end