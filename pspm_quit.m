% pspm_quit clears settings, removes paths & closes figures
%__________________________________________________________________________
% PsPM 6.00
% (C) 2008-2022 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)


%% Initialise
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
disp('_____________________________________________________________________________________________');
disp('PsPM 6.0.0 (c) 2008-2022 Dominik R. Bach');
disp('University of Zurich, CH  --  University College London, UK');
