function pspm_check_python_modules()
    % pspm_check_python_modules Lists currently imported Python modules in MATLAB.
    %
    % This function retrieves and displays the names of Python modules that have been imported
    % into the current MATLAB session.

    % Ensure Python is correctly set up in MATLAB
    if strcmp(pyenv().Version, "")
        fprintf('Python environment does not exists. Run ''pspm_check_python()'' to ensure that the environment is correctly set up.\n');
        return;
    elseif ~strcmp(pyenv().Status, "Loaded")
        fprintf('No module is loaded yet. \n')
        return;
    end
    % Get the dictionary of imported Python modules
    modulesDict = py.sys.modules;
    
    % Convert the Python dictionary keys (module names) to a MATLAB cell array
    moduleNamesList = py.list(modulesDict.keys()); 
    moduleNames = cell(moduleNamesList); 
    
    % Display the imported module names
    fprintf('Imported Python Modules:\n');
    for i = 1:length(moduleNames)
        moduleName = char(moduleNames{i}); 
        fprintf('%d. %s\n', i, moduleName);
    end
end
