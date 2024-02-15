function package_root = getPackageRoot()
%
%   package_root = sl.stack.getPackageRoot()
%
%   Returns the path of the folder that contains the base package.
%
%   Examples:
%   Called from: 'C:\repos\matlab_git\my_repo\+package\my_function.m
%   Returns: 'C:\repos\matlab_git\my_repo\'
%

temp_path = adi.sl.stack.getMyBasePath('','n_callers_up',1);

I = strfind(temp_path,'+');
if isempty(I)
    package_root = temp_path;
else
   last_char_I = I(1)-2;
   package_root = temp_path(1:last_char_I);
end

end
