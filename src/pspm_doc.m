function sts = pspm_doc(func_name, varargin)
% ● Description
%    pspm_doc sorts the help text and save into a file or variable for future usage.
% ● Format
%    sts = pspm_doc(func_name, options)
% ● Arguments
%   * func_name: [string] The name of the function whose help text is to be saved.

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
%% 2 Read help text into a struct
S = pspm_help(func_name);
if nargin > 1
  options = varargin{1};
else
  options = struct();
end
%% 3 Convert to markdown
M = [];
% 3.1 Add title
Title       = pspm_doc_get_title(func_name);
M = [M, '# ', Title, newline];
% 3.2 Add description
if isfield(S, 'Description')
  Description = pspm_doc_get_description(S.Description);
  M = [M, '## ', 'Description',  newline, Description, newline];
end
% 3.3 Add format
if isfield(S, 'Format')
  Format      = pspm_doc_get_format(S.Format);
  M = [M, '## ', 'Format',       newline, Format,      newline];
end
% 3.4 Add arguments
if isfield(S, 'Arguments')
  Arguments   = pspm_doc_get_arguments(S.Arguments);
  M = [M, '## ', 'Arguments',    newline, Arguments,   newline];
end
% 3.5 Add references
if isfield(S, 'References')
  References  = pspm_doc_get_references(S.References);
  M = [M, '## ', 'References',   newline, References,  newline];
end
%% 4 Write to file
if isfield(options, 'path')
  writelines(M, [options.path, '/', Title,'.md']);
else
  writelines(M, [Title,'.md']);
end
sts = 1;
end

function Y = pspm_doc_get_title(X)
if strcmp(X(end-1:end),'.m')
  Y = X(1:end-2);
else
  Y = X;
end
end
function Y = pspm_doc_get_format(X)
Y = ['`',insertAfter(insertBefore(X, char(10), ['` or'] ), char(10),'`'), '`']
Y = [Y, newline];
end
function Y = pspm_doc_get_description(X)
X = insertAfter(X, newline, newline);
Y = [X, newline];
end
function Y = pspm_doc_get_arguments(X)
Y = ['| Variable | Definition |',newline,'|:--|:--|', newline];
list_arg = fieldnames(X);
for i_arg = 1:length(list_arg)
  switch class(X.(list_arg{i_arg}))
    case 'char'
      Y = [Y, '| ', list_arg{i_arg}, ' | ', X.(list_arg{i_arg}), ' |', newline];
    case 'struct'
      Y = [Y, '| ', list_arg{i_arg}, ' | ', ' '                , ' |', newline];
      list_arg2 = fieldnames(X.(list_arg{i_arg}));
      for i_arg2 = 1:length(list_arg2)
        Y = [Y, '| ', list_arg{i_arg}, '.', list_arg2{i_arg2}, ' | ', X.(list_arg{i_arg}).(list_arg2{i_arg2}), ' |'];
        if i_arg2 < length(list_arg2)
          Y = [Y, newline];
        end
      end
  end
end
end
function Y = pspm_doc_get_references(X)
Y = [];
for i_ref = 1:length(X)
  Y = [Y, X{i_ref}, newline, newline];
end
end