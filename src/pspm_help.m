function information = pspm_help(func_name)
% ● Description
%   pspm_help returns the description and arguments of
%   a specified function
% ● Format
%   information = pspm_help(func_name)
% ● Arguments
%     func_name:  the name of the function for help information
% ● Outputs
%   information:  the description of the specific function
% ● History
%   Introduced in PsPM 6.0
%   Written in 2022 and updated in 2024 by Teddy

global settings
if isempty(settings)
  pspm_init;
end
fid = fopen([settings.path,filesep,func_name,'.m'],'r');
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
information.Arguments = sort_args(information.Arguments);
information.References = sort_refs(information.References);
return

function A = sort_args_old (B)
% remove '% '
for i_line = 1:length(B)
  C = B{i_line, 1};
  if contains(C,'%')
    C(strfind(C,'%'))=[];
  end
  B{i_line, 1} = C;
end
% sort
N_target = find(strcmp(B, ' ● Arguments'),1);
str = '';
while ( ~strcmp(B{N_target+1,1}(1),'●') )
  str = [str, B{N_target+1, 1}, newline];
  N_target = N_target + 1;
  if strcmp(B{N_target+1,1}(1:2),' ●')
    break
  elseif strcmp(B{N_target+1,1}(1),'%')
    break
  elseif strcmp(B{N_target+1,1}(1:2),' 1')
    break
  end
end
D = remove_multiple_space(str);
idx_var = strfind(D,': ');
idx_fst = strfind(D,'. ');
A = cell(length(idx_var), 2);
for i_var = 1:length(idx_var)
  switch i_var
    case 1
      A{1,1} = D(1:(idx_var(1)-1));
      A{1,2} = D((idx_var(1)+2):idx_fst(1));
      % A.(var_name) = var_disc;
    case length(idx_var)
      A{length(idx_var),1} = D((idx_fst(end)+2):(idx_var(end)-1));
      A{length(idx_var),2} = D((idx_var(end)+2):end);
      % A.(var_name) = var_disc;
    otherwise
      A{i_var,1} = D((idx_fst(i_var-1)+2):(idx_var(i_var)-1));
      A{i_var,2} = D((idx_var(i_var)+2):idx_fst(i_var));
  end
end

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
  N_target = find(strcmp(B, ['● ', D{i_D}]),1);
  if ~isempty(N_target)
    str = '';
    while ( ~strcmp(B{N_target+1,1}(1),'●') )
      str = [str, B{N_target+1, 1}, newline];
      N_target = N_target + 1;
      if N_target == length(B)
        break
      elseif strcmp(B{N_target+1,1}(1),'●')
        break
      elseif strcmp(B{N_target+1,1}(1),'%')
        break
      end
    end
    A.(D{i_D}) = remove_multiple_space(str);
  end
end

function args = sort_args(A)
B = A;
B(strfind(B,[newline, '│'])) = '';
B(strfind(B,[newline, ' │'])) = ' ';
B(strfind(B,[newline, '│'])) = '';
B(strfind(B,'│')) = '';
checklist = strfind(B,newline);
checklist_valid = [strfind(B,[newline,'├']),...
  strfind(B,[newline,'└']),...
  strfind(B,[newline,'┌'])]  ;
checklist = checklist(~ismember(checklist, checklist_valid));
B(checklist) = '';
B(strfind(B,'─'))='';
[var_name_start,var_name_end] = regexp(B,'(?<=├.)(.*?)(?=:)'); % get subfields
[var_name_start2,var_name_end2] = regexp(B,'(?<=:)(.*?)(?=\n)'); % get explainations
args = struct();
for i = 1:length(var_name_start)
  varname = B(var_name_start(i):var_name_end(i));
  content = B(var_name_start2(i):var_name_end2(i));
  while content(1)==' ' 
    content = content(2:end);
  end
  while content(end)~='.' 
    content(end+1) = '.';
  end
  args.(varname) = content;
end

function B = sort_refs(A)
B = remove_multiple_space (A);
B(strfind(B,newline)) = ' ';
B(strfind(B,' [')) = newline;
B(strfind(B,' *')) = newline;

function B = remove_multiple_space (A)
% B is a string with multiple spaces
% A is the processed B where multiple spaces were converted into one space
B = A;
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