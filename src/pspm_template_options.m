function output = pspm_template_options(input, options)
% ● Description
%   pspm_template_options ...
% ● Format
%   output = pspm_template_options(input, options)
% ARGUMENTS
%   Input
%     input     variable type
%               meaning ...
%               unit: (if applicable)
%   Output
%     output    variable type
%               meaning: ...
%               unit: (if applicable)
%   Optional
%     options   a struct
%               meaning: ...
%       field   variable type
%               meaning: ...
%               unit: (if applicable)
% ● Introduced In
%   PsPM Version
% ● Written By
%   (C) 2021 developer (unit, university)
% Supervised by Professor Dominik Bach (WCHN, UCL)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;