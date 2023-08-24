function out = pspm_cfg_run_contrast1(job)
% Executes pspm_con1

% $Id$
% $Rev$

% modelfile
modelfile = job.modelfile;

% contrast names & vectors
nrCon = size(job.con,2);
for iCon=1:nrCon
    connames{1,iCon} = job.con(iCon).conname;
    convec{1,iCon} = job.con(iCon).convec;
end

% delete existing contrast
deletecon = job.deletecon;

% zscore data
options.zscored = job.zscored;

% datatype
datatype = job.datatype;

pspm_con1(modelfile, connames, convec, datatype, deletecon, options);

out = modelfile;
