function pspm_check_or_setup_pythonEnv(pythonPath)
    % pspm_check_or_setup_pythonEnv Checks and sets the Python environment if path is provided.
    %
    % This function checks the current Python environment setup in MATLAB.
    % If a specific Python executable path is provided, the function attempts
    % to update the Python environment to use the provided path.
    %
    % Arguments:
    %   pythonPath - A string specifying the path to the Python executable.
    %                If this is empty or not provided, the function simply
    %                reports the current Python environment without making changes.

    currentEnv = pyenv;
    
    % Report the current environment
    if strcmp(currentEnv.Version, '')
        fprintf('No Python environment is configured in MATLAB.\n');
    else
        fprintf('Current Python environment: %s (Version: %s)\n', currentEnv.Executable, currentEnv.Version);
    end
    
    % Update the environment if a path is provided and it's either not set or different
    if nargin > 0 && ~isempty(pythonPath) && (isempty(currentEnv.Executable) || ~strcmp(currentEnv.Executable, pythonPath))
        try
            newEnv = pyenv('Version', pythonPath);
            fprintf('Python environment successfully updated to: %s (Version: %s)\n', newEnv.Executable, newEnv.Version);
            fprintf('New current Python environment: %s (Version: %s)\n', newEnv.Executable, currentEnv.Version);
        catch ME
            fprintf('Failed to update Python environment. Error: %s\n', ME.message);
        end
    elseif nargin > 0 && ~isempty(pythonPath) && strcmp(currentEnv.Executable, pythonPath)
        fprintf('The specified Python environment is already set as current.\n');
    end
end
