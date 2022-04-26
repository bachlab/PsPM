function pspm_show_help_doc
% PsPM 5.1
% (C) 2008-2021 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%
% Written by 2021 Teddy Chao

%% Initialise
global settings
if isempty(settings)
	pspm_init;
end

web('https://github.com/bachlab/PsPM/blob/develop/doc/PsPM_Manual.pdf', '-browser')

return