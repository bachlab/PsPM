function scr_cfg_run_review1(job)
% Runs review model - first level

% $Id: scr_cfg_run_review1.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% check model file
[sts, model, ~] = scr_load1(job.modelfile{1}, 'all', 'any');
if sts == -1, return; end;

modeltype = fieldnames(job.modeltype);
modeltype = modeltype{1};

switch modeltype
    case 'con'
        scr_rev_con(model);
    case 'glm'
        scr_rev_glm(job.modelfile{1}, model, job.modeltype.glm);
    case 'dcm'
           dcm_job = fieldnames(job.modeltype.dcm);
           dcm_job = dcm_job{1};
           switch dcm_job
               case 'inv'
                   arg{1} = job.modeltype.dcm.inv.session_nr;
                   arg{2} = job.modeltype.dcm.inv.trial_nr;
                   scr_rev_dcm(model, dcm_job, arg{1}, arg{2});
               case 'sum'
                   arg{1} = job.modeltype.dcm.sum.session_nr;
                   scr_rev_dcm(model, dcm_job, arg{1});
               case {'scrf', 'names'}
                   scr_rev_dcm(model, dcm_job);
           end
    case 'sf'
        arg{1} = job.modeltype.sf.episode_nr;
        scr_rev_dcm(model, modeltype, arg{1}); 
end