% pspm_App is the script for calling the updated modern GUI for PsPM
% pspm_App is currently a beta version
%__________________________________________________________________________
% PsPM 5.1
% (C) 2008-2021 Dominik R Bach (Wellcome Centre for Human Neuroimaging)

% Updated by Teddy Chao (Wellcome Centre for Human Neuroimaging)


global settings
if isempty(settings)
    pspm_init;
end

% appdesigner(pspm_App);
% pf = pspm_path('pspm_App.mlapp');
% appdesigner(pf);

pspm_App;