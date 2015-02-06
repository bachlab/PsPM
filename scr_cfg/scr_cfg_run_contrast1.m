function out = scr_cfg_run_contrast1(job)
% Executes scr_con1

% $Id: scr_cfg_run_contrast1.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

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

% datatype
datatype = job.datatype;

scr_con1(modelfile, connames, convec, datatype, deletecon);

out = modelfile;