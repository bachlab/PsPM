function sts = pspm_check_python(pythonPath)
    % ● Description
    %   pspm_check_python Checks and sets the Python environment if path is provided.
    %
    %   This function checks the current Python environment setup in MATLAB.
    %   If a specific Python executable path is provided, the function attempts
    %   to update the Python environment to use the provided path.
    %   It returns a status argument sts with values 0 or 1.
    %
    % ● Arguments
    %   pythonPath - A string specifying the path to the Python executable.
    %                If this is empty or not provided, the function simply
    %                reports the current Python environment without making changes.
    %
    % ● Returns
    %   sts - Status of the operation (1 for success, 0 for failure).
    %
    % ● History
    %   Written in March 2024 by Dominik R Bach (Uni Bonn)

    % Initialize the status to failure
    sts = 0;
    
    currentEnv = pyenv;

    % Report the current environment if no argument is passed
    if nargin < 1
        if strcmp(currentEnv.Version, '')
            fprintf('No Python environment is configured in MATLAB. Call this function with the complete Python execution path to create the environment.\n');
            return;
        else
            fprintf('Current Python environment: %s (Version: %s)\n', currentEnv.Executable, currentEnv.Version);
            sts = 1;
            return;
        end
    end

    % Attempt to update the environment if a path is provided
    if nargin > 0 && ~isempty(pythonPath)
        if isempty(currentEnv.Executable) || ~strcmp(currentEnv.Executable, pythonPath)
            try
                newEnv = pyenv('Version', pythonPath);
                fprintf('Python environment successfully updated to: %s (Version: %s)\n', newEnv.Executable, newEnv.Version);
                sts = 1; 
            catch ME
                fprintf('Failed to update Python environment. Error: %s\n', ME.message);
                warning('Failed to create or update the Python environment.');
            end
        else
            % If the specified Python environment is already set as current.
            fprintf('The specified Python environment is already set as current.\n');
            sts = 1; 
        end
    end

    return;
end
