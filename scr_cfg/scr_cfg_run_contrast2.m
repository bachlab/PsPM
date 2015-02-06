function out = scr_cfg_run_contrast2(job)
% Executes scr_con1

% $Id: scr_cfg_run_contrast2.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% modelfile
if isfield(job.testtype, 'one_sample')
    modelfile = job.testtype.one_sample.modelfile';
else
    modelfile{1,1} = job.testtype.two_sample.modelfile1';
    modelfile{1,2} = job.testtype.two_sample.modelfile2';
end

% outfile
outfile = [job.outdir{1} '\'  job.filename '.mat'];

% connames & con
connames = fieldnames(job.def_con_name);
connames = connames{1};
if isfield(job.def_con_name.(connames),'con_all')
    con = 'all';
else
   con = job.def_con_name.(connames).convec; 
end
% nrCon = size(job.def_con_name.(connames).con, 2);
% if strcmp(connames, 'name')
%     clear connames
%     for iCon=1:nrCon
%         connames{1,iCon} = job.def_con_name.name.con(iCon).conname;
%         con(1,iCon) = job.def_con_name.name.con(iCon).conval;
%     end
% else
%     for iCon=1:nrCon
%         con(1,iCon) = job.def_con_name.(connames).con(iCon).conval;
%     end
% end

% datatype
%datatype = job.datatype;

% options
options.overwrite = job.overwrite;

scr_con2(modelfile, outfile, con, connames, options);

out = {outfile};