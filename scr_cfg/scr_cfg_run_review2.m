function scr_cfg_run_review2(job)
% Runs review model - second level

% $Id: scr_cfg_run_review2.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

if isempty(job.con)
    scr_rev2(job.modelfile{1});
else
    scr_rev2(job.modelfile{1}, job.con);
end