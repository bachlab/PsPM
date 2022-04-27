% pspm_App is the script for calling the updated modern GUI for PsPM
% pspm_App is currently a beta version
%__________________________________________________________________________
% PsPM 5.1
% (C) The PsPM Team, UCL

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

pspm_App;