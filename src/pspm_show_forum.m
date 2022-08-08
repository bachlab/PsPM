function pspm_show_forum
% ● Introduced In
%   PsPM 5.1
% ● Written By
%   (C) 2020 Teddy Chao (UCL)

global settings
if isempty(settings)
  pspm_init;
end
web('https://github.com/bachlab/PsPM/issues', '-browser')
return