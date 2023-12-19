function out = pspm_cfg_run_contrast1(job)
% Updated on 18-12-2023 by Teddy
%% Variables
% modelfile
modelfile = job.modelfile;
% connames, convec
nrCon = size(job.con,2);
for iCon = 1:nrCon
    connames{1,iCon} = job.con(iCon).conname;
    convec{1,iCon}   = job.con(iCon).convec;
end
% datatype
datatype = job.datatype;
% deletecon
deletecon = job.deletecon;
% options
options = struct;
if isfield(options, 'zscored')
  options.zscored = job.zscored;
end
%% Run
pspm_con1(modelfile, connames, convec, datatype, deletecon, options);
out = modelfile;