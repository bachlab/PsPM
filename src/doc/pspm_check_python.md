# pspm_check_python
## Description
pspm_check_python Checks and sets the Python environment if path is provided.

This function checks the current Python environment setup in MATLAB.

If a specific Python executable path is provided, the function attempts to update the Python environment to use the provided path.

It returns a status argument sts with values 0 or 1.

## Arguments
| Variable | Definition |
|:--|:--|
| pythonPath | A string specifying the path to the Python executable. If this is empty or not provided, the function simply reports the current Python environment without making changes. |

## Outputs
| Variable | Definition |
|:--|:--|
| sts | Status of the operation (1 for success, 0 for failure). |

