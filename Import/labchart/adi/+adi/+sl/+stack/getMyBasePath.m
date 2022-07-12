function base_path = getMyBasePath(file_name,varargin)
%getMyPath  Returns base path of calling function
%
%   base_path = sl.stack.getMyBasePath(*file_name,varargin)
%
%   Outputs:
%   --------
%   base_path : path to cotaining folder of function that is calling
%       this function.
%
%   Inputs:
%   -------
%   file_name : (default '')
%       If empty, examines calling function, otherwise it runs which() on 
%       the name to resolve the path. When called from a script or command 
%       line returns the current directory.
%
%   Optional Inputs:
%   ----------------
%   n_dirs_up : (default 0)
%       If not 0, the returned value is stripped of the path by the
%       specified number of directories. For example a value that would
%       normally be:
%           /Users/Jim/my/returned/path/testing
%       with a 'n_dirs_up' value of 2 would return:
%           /Users/Jim/my/returned/
%   n_callers_up: (default 0)
%       Normally this returns the path of the caller. If for some reason
%       you wanted to get the path of the function calling the function
%       that calls this function, set 'n_callers_up' to 1. Higher values can
%       also be used to get 'higher order' callers.
%
%   Examples:
%   ---------
%   1) Typical usage case:
%
%       base_path = getMyBasePath();
%
%   2) Useful for executing in a script where you want the script path
%   
%       base_path = getMyBasePath('myScriptsName')
%
%   3) TODO: Provide example with n_dirs_up being used
%
%   Improvements:
%   -------------
%   1) Provide specific examples ...
%
%
%   See Also:
%       sl.dir.filepartsx

in.n_dirs_up  = 0;
in.n_callers_up = 0;
in = adi.sl.in.processVarargin(in,varargin);


%NOTE: the function mfilename() can't be used with evalin
%   (as of 2009b)

%We use the stack to get the path
if nargin == 0 || isempty(file_name)
    stack = dbstack('-completenames');
    if length(stack) == 1
        base_path = cd;
    else
        %NOTE: 
        %   - 1 refers to this function
        %   - 2 refers to the calling function
        base_path = fileparts(stack(2 + in.n_callers_up).file);
    end
else
    filePath  = which(file_name);
    base_path = fileparts(filePath);
end

if in.n_dirs_up ~= 0
   base_path = adi.sl.dir.filepartsx(base_path,in.n_dirs_up); 
end

end