% pspm_quit clears settings, removes paths & closes figures
%__________________________________________________________________________
% PsPM 4.4.0
% (C) 2008-2019 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%
% $Id: pspm_quit.m 805 2019-09-16 07:12:08Z esrefo $
% $Rev: 805 $
%
% v109 drb 14.08.2013 removed import paths
% v108 30.05.2013 removed fil distribution
% v107 17.05.2013 updated footer
% v106 08.05.2012 updated footer & added more import paths
% v105 20.07.2011 updated footer
% v104 7.9.2010 changed import path structure
% v103 drb 2.9.2010 made compatible with other OSs (filesep), added vario
% v102 drb 20.3.2010 added DAVB & acq path
% v101 drb 8.9.2009

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
disp('PsPM 4.3.0 (c) 2008-2019 Dominik R. Bach');
disp('University of Zurich, CH  --  University College London, UK');
    
