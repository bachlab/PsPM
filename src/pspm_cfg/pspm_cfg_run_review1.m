function pspm_cfg_run_review1(job)
% Updated on 19-12-2023 by Teddy
if isfield(job.modeltype, 'glm')
    pspm_rev_glm(job.modelfile{1}, job.modeltype.glm);
elseif isfield(job.modeltype, 'dcm')    
    dcm_job = fieldnames(job.modeltype.dcm);
    dcm_job = dcm_job{1};
    switch dcm_job
      case 'inv'
        arg{1} = job.modeltype.dcm.inv.session_nr;
        arg{2} = job.modeltype.dcm.inv.trial_nr;
        pspm_rev_dcm(model, dcm_job, arg{1}, arg{2});
      case 'sum'
        arg{1} = job.modeltype.dcm.sum.session_nr;
        pspm_rev_dcm(job.modelfile{1}, dcm_job, arg{1});
      case {'scrf', 'names'}
        pspm_rev_dcm(job.modelfile{1}, dcm_job);
    end
elseif isfield(job.modeltype, 'sf')    
    sn = job.modeltype.sf.epoch_nr;
    pspm_rev_dcm(job.modelfile{1}, 'sf', sn);
end