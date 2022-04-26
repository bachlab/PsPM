function pspm_show_forum
% Happy Easter!
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%
% Updated by Teddy Chao (UCL)

%% Initialise
global settings
if isempty(settings)
	pspm_init;
end

web('https://github.com/bachlab/PsPM/issues', '-browser')

return