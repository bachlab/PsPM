function fighandle = pspm_rev_con(model)
% ● Description
%   pspm_rev_con is a tool for reviewing contrasts of first level models
% ● Format
%   fighandle = pspm_rev_con(modelfile)
% ● Arguments
%   modelfile: filename and path of modelfile
% ● Version History
%   Introduced In PsPM 3.0
% ● Written By
%   (C) 2008-2015 Dominik R Bach (UZH, WTCN)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
fighandle = [];

% check input
% ------------------------------------------------------------------------
if nargin < 1, return;
elseif ~isfield(model, 'con')
  fprintf('No contrasts contained in model.\n');
  return;
end;

% print contrast names to screen
% ------------------------------------------------------------------------
fprintf('Contrast names for %s:\n---------------------------------------\n', model.modelfile);
for n=1:numel(model.con)
  fprintf('Contrast %d: %s\n',n,model.con(n).name);
end;
fprintf('---------------------------------------\n');
