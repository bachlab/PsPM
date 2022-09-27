function pspm_show_help_doc
% ● History
%   Introduced In PsPM 5.1
%   Written in 2021 by Teddy Chao (UCL)

global settings
if isempty(settings)
  pspm_init;
end
web('https://github.com/bachlab/PsPM/blob/develop/doc/PsPM_Manual.pdf',...
  '-browser')
return