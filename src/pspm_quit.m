function pspm_quit
% ● Description
%   pspm_quit clears settings, removes paths & closes figures
% ● Version History
%   Introduced In TBA.
% ● Written By
%   (C) 2008-2022 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
% ● Maintained By
%   2022 Teddy Chao

global settings
if isempty(settings)
  pspm_init;
end
fs = filesep;
if settings.scrpath, rmpath(settings.path), end;
if any(contains(path, 'VBA'))
  rmpath(pspm_path('ext','VBA'));
  rmpath(pspm_path('ext','VBA','subfunctions'));
  rmpath(pspm_path('ext','VBA','stats&plots'));
end
clear settings
close all
disp(' ');
disp('Thanks for using PsPM.');
disp(repelem('-',20));
disp('PsPM 6.0.0 (c) 2008-2022 Dominik R. Bach');
disp('Uni Bonn, DE | UCL, UK | UZH, CH');