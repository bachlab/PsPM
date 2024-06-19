function out = pspm_help_init
% pspm_help_init sets up the help texts for matlabbatch GUI. This is work
% in progress.

% initialise
global settings

% get functions list
filelist = dir(fullfile(settings.path, '*.m'));

% loop through functions
for i = 1:numel(filelist)
    [pth, fname, ext] = fileparts(filelist(i).name);
    try 
        information = pspm_help(fname);
    catch
        information = [];
    end
    out.(fname) = information;
end
