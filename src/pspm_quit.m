% pspm_quit clears settings, removes paths & closes figures
%__________________________________________________________________________
% PsPM 5.0.0
% (C) 2008-2020 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%
% $Id: pspm_quit.m 805 2019-09-16 07:12:08Z esrefo $
% $Rev: 805 $
%
global settings
if isempty(settings), pspm_init; end;
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
disp('PsPM 5.1.1 (c) 2008-2021 Dominik R. Bach');
disp('University of Zurich, CH  --  University College London, UK');
