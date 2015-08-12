function scr_cfg_run_review2(job)
% Runs review model - second level

% $Id$
% $Rev$

if isempty(job.con)
    scr_rev2(job.modelfile{1});
else
    scr_rev2(job.modelfile{1}, job.con);
end