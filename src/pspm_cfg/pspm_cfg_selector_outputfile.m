function [modelfile, outdir] = pspm_cfg_selector_outputfile(outtype, varargin)
% [modelfile, outdir] = pspm_cfg_selector_modelfile(outtype)
%  modelfile = pspm_cfg_selector('run', job)
% outtype: char, used in the help text

if nargin < 1
    outtype = 'output';
elseif strcmpi(outtype, 'run')
    job = varargin{1};
    [pth, fn, ext] = fileparts(job.outfile);
    modelfile = fullfile(job.outdir{1}, [fn, '.mat']);
    return
end

modelfile         = cfg_entry;
modelfile.name    = sprintf('%s file name', outtype);
modelfile.tag     = 'outfile';
modelfile.strtype = 's';
modelfile.help    = {sprintf('Specify file name for the resulting %s.', outtype)};

% Output directory
outdir         = cfg_files;
outdir.name    = 'Output directory';
outdir.tag     = 'outdir';
outdir.filter  = 'dir';
outdir.num     = [1 1];
outdir.help    = {sprintf('Specify directory where the mat file with the resulting %s will be written.', outtype)};
