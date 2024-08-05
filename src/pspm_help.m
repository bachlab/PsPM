function information = pspm_help(func_name)
% ● Description
%   pspm_help returns the description and arguments of
%   a specified function
% ● Format
%   information = pspm_help(func_name)
% ● Arguments
%   * func_name  : the name of the function for help information
% ● Outputs
%   * information: the description of the specific function
% ● History
%   Introduced in PsPM 6.0
%   Written in 2022 and updated in 2024 by Teddy

global settings
if isempty(settings)
  pspm_init;
end

fid = fopen([settings.path,filesep,func_name,'.m'],'r','n','UTF-8');
% read the file into a cell array, one cell per line
i = 1;
tline = fgetl(fid);
A{i} = tline;
while ischar(tline)
  i = i+1;
  tline = fgetl(fid);
  A{i} = tline;
end
fclose(fid);
A = A.';
% get help text
A = A(1:find(cellfun(@isempty,A),1)-1);
% get rid of empty lines
A = A(cellfun(@ischar,A) & ~cellfun(@isempty,A));
% find matching lines
B = regexp(A,'^\s*%.*','match');
B = vertcat(B{:});
information = sort_info (B);
if isfield(information, 'Description')
    information.Description = sort_description(information.Description);
end
if isfield(information, 'Arguments')
  information.Arguments = sort_args(information.Arguments);
end
if isfield(information, 'Outputs')
  information.Outputs = sort_args(information.Outputs);
end
if isfield(information, 'References')
  information.References = sort_refs(information.References);
end
return

function A = sort_info (B)
% remove '% '
for i_line = 1:length(B)
  C = B{i_line, 1};
  if C(1) == ' '
    break
  elseif strcmp(C, '% ') || strcmp(C, '%  ') || strcmp(C, '%   ') || strcmp(C, '%    ')
    B{i_line, 1} = '';
  else
    B{i_line, 1} = C(find(~isspace(C(2:end)),1)+1:end);
  end
end
% Remove empty lines
B = B(cellfun(@ischar,B) & ~cellfun(@isempty,B));
D = {'Description', ...
  'Format', ...
  'Arguments', ...
  'Outputs', ...
  'References', ...
  'History', ...
  'Developer'};
% sort
A = struct();
for i_D = 1:length(D)
  N_target = find(strcmp(B, [char(9679),' ', D{i_D}]),1);
  if ~isempty(N_target)
    str = '';
    while ( ~strcmp(B{N_target+1,1}(1),char(9679)) )
      str = [str, B{N_target+1, 1}, newline];
      N_target = N_target + 1;
      if N_target == length(B)
        break
      elseif strcmp(B{N_target+1,1}(1),char(9679))
        break
      elseif strcmp(B{N_target+1,1}(1),'%')
        break
      end
    end
    while strcmp(str(end), newline)
      str = str(1:(end-1));
    end
    A.(D{i_D}) = remove_multiple_space(str);
  end
end

function args = sort_description(A)
% identify all line breaks
linebreaks = strfind(A, newline);
% find those line breaks that correspond to new paragraphs, and exclude
% them
linebreaks = setdiff(linebreaks, strfind(A,['.', newline]) + 1);
linebreaks = setdiff(linebreaks, strfind(A,['. ', newline]) + 2);
% remove remaining line breaks and replace with space, remove multiple
% spaces
A(linebreaks) = ' ';
A = remove_multiple_space(A);
% split paragraphs into cells
args = splitlines(A);

function args = sort_args(A)
B = A;
B(strfind(B,[newline, char(9474)])) = '';
B(strfind(B,[newline, ' ', char(9474)])) = ' ';
B(strfind(B,[newline, char(9474)])) = '';
B(strfind(B,char(9474))) = '';
checklist = strfind(B,newline);
checklist_valid = [strfind(B,[newline,char(9500)]),...
  strfind(B,[newline,char(9492)]),...
  strfind(B,[newline,'*']),...
  strfind(B,[newline,char(9484)])]  ;
checklist = checklist(~ismember(checklist, checklist_valid));
B(checklist) = ' ';
B(strfind(B,char(9472)))=' ';
B = remove_multiple_space(B);
levels = B([1,strfind(B,newline)+1]);
level_ends = [strfind(B,newline),length(B)];
level_starts = [1,level_ends(1:end-1)+1];
args = struct();
for i_level = 1:length(levels)
  C = B((level_starts(i_level)):(level_ends(i_level)));
  if ~strcmp(levels(i_level),char(9500)) && ~strcmp(levels(i_level), char(9492))
    % this is a field
    if strcmp(levels(i_level),char(9484))
      fieldname = C;
      while strcmp(fieldname(1),char(9484))
        fieldname = fieldname(2:end);
      end
      fieldcontent = '';
    else
      split = strfind(C, ':');
      if length(split)>1
        split = split(1);
      end
      fieldname = C(1:(split-1));
      fieldcontent = C((split+1):end);
    end
    args.(sort_content(fieldname)) = sort_content(fieldcontent);
  else
    [var_name_start,var_name_end] = regexp(C,'(?<=^)(.*?)(?=:)'); % get subfields
    [var_name_start2,var_name_end2] = regexp(C,'(?<=:)(.*?)(?=$)'); % get explainations
    varname = C(var_name_start:var_name_end);
    while strcmp(varname(1),' ') || strcmp(varname(1),char(9500)) || strcmp(varname(1),char(9492)) || strcmp(varname(1),'.')
      varname = varname(2:end);
    end
    content = C(var_name_start2:var_name_end2);
    while strcmp(content(1),' ')
      content = content(2:end);
    end
    args.(sort_content(fieldname)).(sort_content(varname)) = sort_content(content);
  end
end

function B = sort_refs(A)
B = remove_multiple_space (A);
B(strfind(B,newline)) = ' ';
B(strfind(B,' [')) = newline;
B(strfind(B,' *')) = newline;
B = splitlines(B);

function B = remove_multiple_space (A)
% B is a string with multiple spaces
% A is the processed B where multiple spaces were converted into one space
B = A;
if contains(A, '  ')
  idx_space = strfind(A,' ');
  idx_space_preserve = zeros(1,length(idx_space));
  if idx_space(1) == 1
    idx_space_preserve(1) = 1;
  end
  for i = 2:length(idx_space)
    if idx_space(i) == idx_space(i-1)+1
      idx_space_preserve(i) = 1;
    end
  end
  idx_space_remove = nonzeros(idx_space.*idx_space_preserve);
  B(idx_space_remove) = [];
  if strcmp(A(end),newline)
    B = B(1:end-1);
  end
  % remove " :"
  B(strfind(B, ' :')) = '';
end

function B = sort_content(A)
B = A;
if ~isempty(B)
  while ismember(B(1), {' ','.','*',char(9500),char(9492)})
    B = B(2:end);
  end
  while contains(B,newline)
    B(strfind(B, newline)) = '';
  end
  while B(end)==':' || B(end)==' '
    B = B(1:(end-1));
  end
  while contains(B,' ') && B(end)~='.'
    B(end+1) = '.';
  end
end
