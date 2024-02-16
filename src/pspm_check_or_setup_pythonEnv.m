function pspm_check_or_setup_pythonEnv(pythonPath)
    % pspm_check_or_setup_pythonEnv Checks and sets the Python environment if path is provided.
    %
    % This function reports the current Python environment setup in MATLAB.
    % If a specific Python executable path is provided, the function attempts
    % to update the Python environment to use the provided path.
    %
    % Arguments:
    %   pythonPath - A string specifying the path to the Python executable.
    %                If this is empty or not provided, the function simply
    %                reports the current Python environment without making changes.

    currentEnv = pyenv;
    
    % Check if Python is configured in MATLAB
    if isempty(currentEnv.Executable)
        fprintf('No Python environment is configured in MATLAB.\n');
        % Attempt to set up a new Python environment if a path is provided
        if nargin > 0 && ~isempty(pythonPath)
            try
                newEnv = pyenv('Version', pythonPath);
                fprintf('Python environment successfully updated to: %s (Version: %s)\n', newEnv.Executable, newEnv.Version);
            catch ME
                fprintf('Failed to update Python environment. Error: %s\n', ME.message);
            end
        end
    else
        fprintf('Current Python environment: %s (Version: %s)\n', currentEnv.Executable, currentEnv.Version);
        % If a path is provided and it is different from the current one, attempt to update
        if nargin > 0 && ~isempty(pythonPath) && ~strcmp(currentEnv.Executable, pythonPath)
            try
                newEnv = pyenv('Version', pythonPath);
                fprintf('Python environment successfully updated to: %s (Version: %s)\n', newEnv.Executable, newEnv.Version);
            catch ME
                fprintf('Failed to update Python environment. Error: %s\n', ME.message);
            end
        elseif nargin > 0 && ~isempty(pythonPath) && strcmp(currentEnv.Executable, pythonPath)
            fprintf('The specified Python environment is already set as current.\n');
        end
    end
end
