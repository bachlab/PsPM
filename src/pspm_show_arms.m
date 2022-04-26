function pspm_show_arms
% Happy Easter!
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
	pspm_init;
end
pf = pspm_path('CologneCoatOfArms.jpg');

%pf = [settings.path, 'CologneCoatOfArms.jpg'];
P = imread(pf);
figure('Position', [40 40 300 400], 'MenuBar', 'none', 'Name', 'Viva Colonia', 'Color', 'k');
image(P);
axis image
axis off
return;

