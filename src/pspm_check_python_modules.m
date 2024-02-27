function moduleNames = pspm_check_python_modules()
    % pspm_check_python_modules Returns a list of currently imported Python modules in MATLAB.
    %
    % This function retrieves and returns the names of Python modules that have been imported
    % into the current MATLAB session. 
    % It checks the status of the Python environment in MATLAB
    % and provides informative feedback to the user based on the Python setup status.

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
end
