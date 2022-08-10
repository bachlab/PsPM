function pspm_show_help_doc
% ● Version History
%   Introduced In PsPM 5.1
%   Written By 2021 Teddy Chao (UCL)

global settings
if isempty(settings)
  pspm_init;
end
web('https://github.com/bachlab/PsPM/blob/develop/doc/PsPM_Manual.pdf',...
  '-browser')
return