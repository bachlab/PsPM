function path_to_folder = pspm_path(varargin)
% ● Description
%   pspm_path is an operating system agnostic function that returns the path
%   of folders under root PsPM directory. This function is mainly used during
%   directory imports to call functions from libraries or folders that are not
%   added to path by default (such as backroom folder for utility functions).
% ● Format
%   path_to_folder = pspm_path(varargin)
% ● Arguments
%   * varargin: Pass any number of string arguments to pspm_path. Each argument
%             is assumed to be the name of a folder. For example, if you want
%             to get the path to <PSPM_ROOT>/a/b/c folder, call
%             pspm_path('a', 'b', 'c').
% ● Outputs
%   * path_to_folder: Constructed absolute path
% ● History
%   Written in 2019 by Eshref Yozdemir (University of Zurich)
%   Maintained in 2022 by Teddy

if ~all(cellfun(@(x) isstr(x), varargin))
  error('ID:invalid_input', 'All inputs to pspm_path must be string');
end
pspm_root_path = fileparts(which('pspm_path'));
path_to_folder = fullfile(pspm_root_path, varargin{:});
return
