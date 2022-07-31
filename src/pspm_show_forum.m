function pspm_show_forum
% ● Introduced In
%   PsPM 5.1
% ● Written By
%   (C) 2020 Teddy Chao (UCL)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
%% Show webpage
web('https://github.com/bachlab/PsPM/issues', '-browser')
return