classdef pspm_check_python_modules_test < matlab.unittest.TestCase
  % unittest class for the pspm_check_python_modules function
  % PsPM TestEnvironment
  % ● Authorship
  % Abdul Wahab Madni 2024(Uni Bonn)

  methods (Static)
    function addFunctionPath(~)
      % Add the path to the source directory
      src_path = fullfile('src');
      addpath(src_path);
    end
  end

  methods (Test)
    function test_no_python_environment(this)
      % Test case when no Python environment is configured
      [output, ~] = evalc('pspm_check_python_modules()');
      expectedMessage = 'Python environment does not exist.';
      this.verifyTrue(contains(output, expectedMessage), ...
        'Test failed: Expected output to state that no Python environment exists.');
    end

    % function test_python_environment_no_modules(this)
    %   % Test case when Python environment is set but no modules are explicitly imported
    %   % Assumption: Python is already set up for MATLAB.
    %   [output, ~] = evalc('pspm_check_python_modules()');
    %   expectedMessage = 'No module is loaded yet.';
    %   this.verifyFalse(contains(output, expectedMessage), ...
    %     'Test failed: Unexpected output instead of no modules are loaded.');
    % end

    function test_python_environment_with_modules(this)
      % Test case when Python modules are explicitly imported
      py.importlib.import_module('math');  % Import a Python module to ensure there's at least one
      [output, ~] = evalc('pspm_check_python_modules()');
      expectedMessage = 'Python modules have been successfully retrieved.';
      this.verifyTrue(contains(output, expectedMessage), ...
        'Test failed: Unexpected output instead of confirming Python modules were retrieved.');
    end
  end
end
