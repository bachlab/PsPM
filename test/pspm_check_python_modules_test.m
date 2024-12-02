classdef pspm_check_python_modules_test < matlab.unittest.TestCase
  % ● Description
  %   Unittest class for the pspm_check_python_modules function
  % PsPM TestEnvironment
  % ● History
  %   Written in Apr 2024 by Abdul Wahab Madni (Uni Bonn) and Teddy

  methods (TestMethodSetup)
    function addFunctionPath(testCase)
      % Add the path to the source directory
      src_path = fullfile('src');
      addpath(src_path);
    end
  end
  methods (Test)
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
      addpath('src');
      py.importlib.import_module('math');  % Import a Python module to ensure there's at least one
      [output, ~] = evalc('pspm_check_python_modules("math")');
      expectedMessage = 'Python modules have been successfully retrieved.';
      this.verifyTrue(contains(output, expectedMessage), ...
        'Test failed: Unexpected output instead of confirming Python modules were retrieved.');
    end
  end
end
