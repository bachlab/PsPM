function out = pspm_cfg_run_contrast1(job)
% Updated on 18-12-2023 by Teddy
modelfile = job.modelfile;
nrCon = size(job.con,2);
for iCon=1:nrCon
    connames{1,iCon} = job.con(iCon).conname;
    convec{1,iCon} = job.con(iCon).convec;
end
datatype = job.datatype;
deletecon = job.deletecon;
options.zscored = job.zscored;
pspm_con1(modelfile, connames, convec, datatype, deletecon, options);
out = modelfile;