function [sts, moduleNames] = pspm_check_python_modules(module, varargin)
% ● Description
%   pspm_check_python_modules Returns a list of currently imported Python modules in MATLAB.
%   This function retrieves and returns the names of Python modules that have been imported
%   into the current MATLAB session. If a module name is provided as
%   argument, will try to load this module of not already loaded
%
% ● History
%   Written in 2024 by Dominik R Bach (Uni Bonn)

    % Initialize return variables
    sts = 0;
    moduleNames = {};

    if nargin > 1
        pe = pyenv();
        if strcmp(pe.Status, 'Loaded')
            warning(append('The specified python path is not used since Python environment, ', pe.Executable, ', has already been set up within the current matlab session. \n'));
        else
            pyenv(Version=varargin{1});
        end
    end

    try
        % Ensure Python is correctly set up in MATLAB
        pe = pyenv();
         if strcmp(pe.Version, '')
             warning('Python environment does not exist. Run ''pspm_check_python()'' to ensure that the environment is correctly set up.\n');
            return;
        elseif ~strcmp(pe.Status, 'Loaded')
            fprintf('No module is loaded yet.\n');
        else
            % Get the dictionary of imported Python modules
            modulesDict = py.sys.modules;
            moduleNamesList = py.list(modulesDict.keys());
            moduleNames = cell(moduleNamesList);
            moduleNames = cellfun(@(x) char(x), moduleNames, 'UniformOutput', false);

            % Print confirmation message
            fprintf('Python modules have been successfully retrieved. Total modules: %d\n', numel(moduleNames));
        end
    catch ME
        fprintf('An error occurred while retrieving Python modules: %s\n', ME.message);
        return
    end

    if nargin > 0 && ischar(module) && ~ismember(module, moduleNames)
        try
            py.importlib.import_module(module);
        catch ME
            warning('An error occurred while loading Python modules: %s\n', ME.message);
            return
        end
    end
    sts = 1;
end
