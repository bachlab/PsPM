function [sts, import, sourceinfo] = pspm_get_smrx(datafile, import)
% ● Description
%   pspm_get_smrx is the main function for importting spike-smr files
% ● Format
%   [sts, import, sourceinfo] = pspm_get_smr(datafile, import);
% ● Arguments
%     import: [struct]
% ● History
%   Introduced in PsPM 6.1
%   Written in 2023 by Teddy

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];
addpath(pspm_path('Import','CEDS64ML'));

%% 2 Get external file
% using CED library
warning off;
fid = fopen(datafile);
chanlist = SONChanList(fid);
return