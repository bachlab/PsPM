function pspm_show_forum
% PsPM 5.1
% (C) 2020 Teddy Chao (UCL)
%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
%% Show webpage
web('https://github.com/bachlab/PsPM/issues', '-browser')
return