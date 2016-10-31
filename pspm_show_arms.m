function pspm_show_arms
% Happy Easter!
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: pspm_show_arms.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% v001 drb 3.11.2009 
global settings;
if isempty(settings), pspm_init; end;

pf = [settings.path, 'CologneCoatOfArms.jpg'];
P = imread(pf);
figure('Position', [40 40 300 400], 'MenuBar', 'none', 'Name', 'Viva Colonia', 'Color', 'k');
image(P);
axis image
axis off
return;

