function [information, arguments] = pspm_help(func_name)
% ● Description
%   pspm_help returns the description and arguments of 
%   a specified function
% ● Format
%   [information, arguments] = pspm_help(func_name)
% ● Arguments
%     func_name:  the name of the function for help information
% ● Outputs
%   information:  the description of the specific function
%     arguments:  the arguments of the specific function
% ● Copyright
%   Introduced in PsPM 6.0
%   Written and maintained in 2022 by Teddy Chao (UCL)

global settings
if isempty(settings)
  pspm_init;
end
fid = fopen([settings.path,func_name,'.m'],'r');
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
% get rid of empty lines
mk = cellfun(@ischar,A) & ~cellfun(@isempty,A);
A = A(mk);
% find matching lines
B = regexp(A,'^\s*%.*','match');
B = vertcat(B{:});
information = sort_info (B);
arguments = sort_args (B);

function A = sort_args (B)
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
  str = [str, B{N_target+1, 1}];
  N_target = N_target + 1;
  if strcmp(B{N_target+1,1}(1:2),' ●')
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
  end
  if contains(C,'% ')
    C(strfind(C,'% '):(strfind(C,'% ')+1))=[];
  end
  B{i_line, 1} = C;
end
D = {'Description', 'Format'};
% sort
A = struct();
for i_D = 1:length(D)
  N_target = find(strcmp(B, ['● ', D{i_D}]),1);
  str = '';
  while ( ~strcmp(B{N_target+1,1}(1),'●') )
    str = [str, B{N_target+1, 1}];
    N_target = N_target + 1;
    if strcmp(B{N_target,1}(1),'●') || strcmp(B{N_target,1}(1),' ')
        break
    end
  end
  A.(D{i_D}) = remove_multiple_space(str);
end

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