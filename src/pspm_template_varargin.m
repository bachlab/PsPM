function output = pspm_template_varargin(input, varargin)

% DEFINITION
%   pspm_template_varargin ...
% FORMAT
%   output = pspm_template(input, varargin)
% ARGUMENTS
%   Input
%     input     variable type
%               meaning: ...
%               unit: (if applicable)
%   Output
%     output    variable type
%               meaning: ...
%               unit: (if applicable)
%   Optional
%     option    variable type
%               meaning: ...
%               unit: (if applicable)
% PsPM (version)
% (C) 2021 developer (unit, university)
% Supervised by Professor Dominik Bach (WCHN, UCL)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;