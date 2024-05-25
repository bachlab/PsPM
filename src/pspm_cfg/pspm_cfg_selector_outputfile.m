function [modelfile, outdir] = pspm_cfg_selector_outputfile(outtype)
% [modelfile, outdir] = pspm_cfg_selector_modelfile(outtype)
% outtype: char, used in the help text

if nargin < 1
    outtype = 'output';
end

modelfile         = cfg_entry;
modelfile.name    = 'Model Filename';
modelfile.tag     = 'modelfile';
modelfile.strtype = 's';
modelfile.help    = {sprintf('Specify file name for the resulting %s.', outtype)};

% Output directory
outdir         = cfg_files;
outdir.name    = 'Output Directory';
outdir.tag     = 'outdir';
outdir.filter  = 'dir';
outdir.num     = [1 1];
outdir.help    = {sprintf('Specify directory where the mat file with the resulting %s will be written.', outtype)};
