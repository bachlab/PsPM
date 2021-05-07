function pspm_show_help_doc
% PsPM 5.1
% (C) 2008-2021 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%
% Written by 2021 Teddy Chao

% $Id$
% $Rev$

% global settings;
% if isempty(settings)
%     pspm_init; 
% end

web('https://raw.githubusercontent.com/bachlab/PsPM/develop/doc/PsPM_Manual.pdf', '-browser')

return