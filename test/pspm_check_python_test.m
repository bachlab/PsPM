classdef pspm_check_python_test < matlab.unittest.TestCase
  % ● Description
  %   unittest class for the pspm_check_python function
  % ● History
  %   Written in Apr 2024 by Abdul Wahab Madni (Uni Bonn) and Teddy


  methods (Test)
    function test_current_python_environment(this)
      % Test case to report the current Python environment if it exists
      % Setup: ensure a Python environment is already configured
      original_env = pyenv;
      if original_env.Version ~= ""  % Check if there's an existing Python environment
        sts = pspm_check_python();
        this.verifyEqual(sts, 1, 'Test failed: Expected sts = 1 when reporting the current Python environment');
      else
        this.assumeFail('No Python environment set up for testing reporting current environment.');
      end
      pyenv('Version', original_env.Version);  % Reset to original Python environment after the test
    end

    function test_set_new_python_environment(this)
      % Test setting a new Python environment
      % Note: Insert a valid path for the Python executable in your system
      pyrunfile("test/pspm_py_find_location.py")
      pyinfo_file = 'test/py_loc.txt';
      pyinfo_text   = fileread(pyinfo_file);
      disp(pyinfo_text);
      if isunix
        pyinfo_struct = regexp(pyinfo_text, '\n', 'split'); % LF for unix
      else
        pyinfo_struct = regexp(pyinfo_text, '\r\n', 'split'); % CRLF for windows
      end
      pyinfo        = pyinfo_struct(1:2);
      % Adjustments
      if isunix
        % for unix, this needs to be something like ".../python3.11"
        pyinfo{1} = [pyinfo{1}, '/python', pyinfo{2}];
      else
        % for windows
        pyinfo{1} = [pyinfo{1}, '\python.EXE'];
      end
      valid_python_path = pyinfo{1};
      disp(valid_python_path);
      original_env = pyenv;
      sts = pspm_check_python(valid_python_path);
      this.verifyEqual(sts, 1, 'Test passed: Expected sts = 1 when setting a new Python environment');
      pyenv('Version', original_env.Version);  % Reset to original Python environment after the test
    end

    function test_set_invalid_python_environment(this)
      % Test setting an invalid Python environment
      invalid_python_path = 'invalid/path/to/python';
      sts = pspm_check_python(invalid_python_path);
      this.verifyEqual(sts, 0, 'Test failed: Expected sts = 0 when setting an invalid Python environment');
    end

    function test_python_environment_already_set(this)
      % Test when the specified Python environment is already set as the current
      original_env = pyenv;
      sts = pspm_check_python(original_env.Version);
      this.verifyEqual(sts, 1, 'Test failed: Expected sts = 1 when the Python environment is already set');
      pyenv('Version', original_env.Version);
    end
  end
end
