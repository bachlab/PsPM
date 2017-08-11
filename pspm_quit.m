% SCR_QUIT clears settings, removes paths & closes figures
%__________________________________________________________________________
% PsPM 3.1
% (C) 2008-2016 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%
% $Id$
% $Rev$
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

rmpath([settings.path, 'VBA']); 
rmpath([settings.path, 'VBA', fs, 'subfunctions']); 
rmpath([settings.path, 'VBA', fs, 'stats&plots']); 

clear settings
close all

disp(' ');
disp('Thanks for using PsPM.');
disp('_____________________________________________________________________________________________');
disp('PsPM 3.2 (c) 2008-2017 Dominik R. Bach');
disp('University of Zurich, CH  --  University College London, UK');
    