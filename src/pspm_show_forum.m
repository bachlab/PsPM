function pspm_show_forum
% ● History
%   Introduced In PsPM 5.1
%   Written in 2020 by Teddy Chao (UCL)

global settings
if isempty(settings)
  pspm_init;
end
web('https://github.com/bachlab/PsPM/issues', '-browser')
return