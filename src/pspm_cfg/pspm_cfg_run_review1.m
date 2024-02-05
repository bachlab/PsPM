function pspm_cfg_run_review1(job)
% Updated on 19-12-2023 by Teddy
[sts, model, ~] = pspm_load1(job.modelfile{1}, 'all', 'any');
if sts == -1, return; end
modeltype = fieldnames(job.modeltype);
modeltype = modeltype{1};
switch modeltype
  case 'con'
    pspm_rev_con(model);
  case 'glm'
    pspm_rev_glm(job.modelfile{1}, model, job.modeltype.glm);
  case 'dcm'
    dcm_job = fieldnames(job.modeltype.dcm);
    dcm_job = dcm_job{1};
    switch dcm_job
      case 'inv'
        arg{1} = job.modeltype.dcm.inv.session_nr;
        arg{2} = job.modeltype.dcm.inv.trial_nr;
        pspm_rev_dcm(model, dcm_job, arg{1}, arg{2});
      case 'sum'
        arg{1} = job.modeltype.dcm.sum.session_nr;
        pspm_rev_dcm(model, dcm_job, arg{1});
      case {'scrf', 'names'}
        pspm_rev_dcm(model, dcm_job);
    end
  case 'sf'
    arg{1} = job.modeltype.sf.epoch_nr;
    dcm = cellfun(@(field) strcmpi(field(1).modeltype, 'dcm'), model.model);
    if any(dcm)
      pspm_rev_dcm(model.model{dcm}, modeltype, arg{1});
    else
      warning('Methods contained in SF model are not supported.');
    end
end