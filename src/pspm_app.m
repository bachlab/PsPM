% pspm_App is the updated main GUI for PsPM
%__________________________________________________________________________
% PsPM 6.0
% (C) 2008-2021 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% Updated by Teddy Chao

global settings
if isempty(settings)
    pspm_init;
end

% appdesigner(pspm_App);
% pf = pspm_path('pspm_App.mlapp');
% appdesigner(pf);

pspm_App;