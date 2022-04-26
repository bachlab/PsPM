function output = pspm_template_options(input, options)

% DEFINITION
%   pspm_template_options ...
% FORMAT
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
% PsPM (version)
% (C) 2021 developer (unit, university)
% Supervised by Professor Dominik Bach (WCHN, UCL)

%% Initialise
global settings
if isempty(settings)
	pspm_init;
end
sts = -1;