function output = pspm_template_varargin(input, varargin)
% ● Descrition
%   pspm_template_varargin ...
% ● Format
%   output = pspm_template(input, varargin)
% ● Arguments
%   Input
%      input: [variable type, unit: (if applicable)]
%             meaning: ...
%   Optional
%     option: [variable type, unit: (if applicable)]
%             meaning: ...
% ● Outputs
%     output: [variable type, unit: (if applicable)]
%             meaning: ...
% ● Version
%   PsPM (version)
%   (C) 2021 developer (unit, university)
%   Supervised by Professor Dominik Bach (WCHN, UCL)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;