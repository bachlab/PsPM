function moduleNames = pspm_check_python_modules(module)
    % pspm_check_python_modules returns a list of currently imported Python modules in MATLAB.
    %
    % This function retrieves and returns the names of Python modules that have been imported
    % into the current MATLAB session. If a module name is provided as
    % argument, will try to load this module of not already loaded

    % Initialize return variable
    moduleNames = {};

    try
        % Ensure Python is correctly set up in MATLAB
        pe = pyenv();
        if strcmp(pe.Version, "")
            fprintf('Python environment does not exist. Run ''pspm_check_python()'' to ensure that the environment is correctly set up.\n');
            return;
        elseif ~strcmp(pe.Status, "Loaded")
            fprintf('No module is loaded yet.\n');
            return;
        else
            % Get the dictionary of imported Python modules
            modulesDict = py.sys.modules;
            moduleNamesList = py.list(modulesDict.keys());
            moduleNames = cell(moduleNamesList);

            % Print confirmation message
            fprintf('Python modules have been successfully retrieved. Total modules: %d\n', numel(moduleNames));
        end
    catch ME
        fprintf('An error occurred while retrieving Python modules: %s\n', ME.message);
    end

    if nargin > 0 && ischar(module) && ~ismember(module, moduleNames)
         py.importlib.import_module(module);
    end
end