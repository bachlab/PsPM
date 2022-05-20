function struct = pspm_help(func_name)
fid = fopen([func_name,'.m'],'r');
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
% remove '% '
for i_line = 1:length(B)
  C = B{i_line, 1};
  if contains(C,'% ')
    C(strfind(C,'% '):(strfind(C,'% ')+1))=[];
  end
  B{i_line, 1} = C;
end
% sort
N_description = find(strcmp(B, '● Description'),1);
N_format      = find(strcmp(B, '● Format'),     1);
N_arguments   = find(strcmp(B, '● Arguments'),  1);
N_arguments   = find(strcmp(B, '● Version'),    1);
struct = B;
end