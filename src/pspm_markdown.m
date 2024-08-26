function sts = pspm_doc(func_name, options)
% ● Description
%    pspm_doc sorts the help text and save into a file or variable for future usage.
% ● Format
%    sts = pspm_doc(func_name, options)
% ● Arguments
%   * func_name: [string] The name of the function whose help text is to be saved.
%   ┌───options
%   └───.format: [string] The format of help text file/variable. The allowed values are 
%                'html', 'markdown', 'md', 'txt', 'latex'.

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

%% 2 Read help text into a struct
S = pspm_help(func_name);

%% 3 Convert to markdown
M = [];
% 3.1 Add title


%% 4 Convert to required format by using Pandoc
end