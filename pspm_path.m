function path_to_folder = pspm_path(varargin)
    % pspm_path is an operating system agnostic function that returns the path
    % folders under root PsPM directory. This function is mainly used during
    % directory imports to call functions from libraries or folders that are not
    % added to path by default (such as backroom folder for utility functions).
    %
    % FORMAT:
    %     path_to_folder = pspm_path(varargin)
    %
    % INPUT:
    %     varargin: Pass any number of string arguments to pspm_path. Each argument
    %               is assumed to be the name of a folder. For example, if you want
    %               to get the path to <PSPM_ROOT>/a/b/c folder, call
    %
    %                   pspm_path('a', 'b', 'c')
    %
    % OUTPUT:
    %     path_to_folder: Constructed absolute path
    %
    %__________________________________________________________________________
    % (C) 2019 Eshref Yozdemir (University of Zurich)
    if ~all(cellfun(@(x) isstr(x), varargin))
        error('ID:invalid_input', 'All inputs to pspm_path must be string');
    end
    pspm_root_path = fileparts(which('pspm_path'));
    path_to_folder = fullfile(pspm_root_path, varargin{:});
end
