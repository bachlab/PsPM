function pspm_quit
% ● Description
%   pspm_quit clears settings, removes paths & closes figures
% ● History
%   Written in 2008-2022 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Maintained in 2024 by Teddy

global settings
if isempty(settings)
  pspm_init;
end

% Remove paths added during pspm_init
if isfield(settings, 'added_paths') && ~isempty(settings.added_paths)
   cellfun(@rmpath, settings.added_paths);
end
settings = rmfield(settings, 'added_paths');

fs = filesep;
if settings.scrpath, rmpath(settings.path), end;

if isfile(fullfile(settings.path,'pspm_text.mat'))
  delete(fullfile(settings.path,'pspm_text.mat'))
end

clear settings
close all
disp(' ');
disp('Thanks for using PsPM.');
disp(repelem('-',20));
disp('PsPM 6.1.1 (c) 2008-2024 Dominik R. Bach');
disp('Uni Bonn, DE | UCL, UK | UZH, CH');
return
