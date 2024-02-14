classdef pspm_extract_segments_core_test < matlab.unittest.TestCase
  % unittest class for the pspm_extract_segments_core function
  % PsPM TestEnvironment
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  methods (TestMethodSetup)
      function addFunctionPath(testCase)
          % Add the path to the source directory
          srcPath = fullfile(pwd, '..', 'src');
          addpath(srcPath);
      end
  end

  methods (TestMethodTeardown)
      function removeFunctionPath(testCase)
          % Remove the path to the source directory
          srcPath = fullfile(pwd, '..', 'src');
          rmpath(srcPath);
      end
  end
  methods (Test)
      function test_basic_functionality(this)
          data = {1:10};
          onsets = {[3, 4, 5]};
          missing = {logical([0, 0, 0, 0, 0, 0, 0, 0, 0, 0])};
          segment_length = 3;
          expected_segments = [3,4,5; 4,5,6; 5,6,7];
          expected_sessions = [1;1;1];
          [segments, sessions] = pspm_extract_segments_core(data, onsets, segment_length, missing);
          this.verifyEqual(segments, expected_segments);
          this.verifyEqual(sessions, expected_sessions);

      end

      function test_with_missing_data(this)
          data = {1:10};
          onsets = {[3, 4, 5]};
          missing = {logical([0, 0, 1, 0, 1, 0, 0, 0, 0, 0])};
          segment_length = 3;
          expected_segments = [NaN,4,NaN; 4,NaN,6; NaN,6,7];
          expected_sessions = [1;1;1];
          [segments, sessions] = pspm_extract_segments_core(data, onsets, segment_length, missing);
          this.verifyEqual(segments, expected_segments);
          this.verifyEqual(sessions, expected_sessions);
      end

      function test_segment_extends_beyond_data(this)
          data = {1:10};
          onsets = {[8, 9, 10]};
          missing = {false(1, 10)};
          segment_length = 4;
          expected_segments = [8,9,10,NaN; 9,10,NaN,NaN; 10,NaN,NaN,NaN];
          expected_sessions = [1;1;1];
          [segments, sessions] = pspm_extract_segments_core(data, onsets, segment_length, missing);
          this.verifyEqual(segments, expected_segments);
          this.verifyEqual(sessions, expected_sessions);
      end

      function test_input_size_mismatch_warning(this)
          data = {1:10, 11:20}; % Two elements
          onsets = {[3, 4, 5]}; % One element, mismatch with 'data'
          missing = {false(1, 10)}; % One element, mismatch with 'data'
          segment_length = 3;

          % Execute the function and capture warnings
          [output, ~] = evalc('pspm_extract_segments_core(data, onsets, segment_length, missing)');

          % Verify the specific warning message for input size mismatch is present
          expectedWarningMsg = 'The cell arrays data, onsets, and missing must have the same size.';
          this.verifyTrue(contains(output, expectedWarningMsg), 'Expected warning for input size mismatch was not issued.');
      end

      function test_incorrect_onsets_warning(this)
          data = {1:10};
          onsets = {[0, 11]}; % Incorrect onsets that should trigger a warning
          missing = {false(1, 10)};
          segment_length = 3;

          % Capture the command window output, including warnings, during function execution
          [output, ~] = evalc('pspm_extract_segments_core(data, onsets, segment_length, missing)');

          % Check if the specific warning message is in the captured output
          expectedWarningMsg = 'Onset values must be between 1 and the length of the corresponding data vector.';
          this.verifyTrue(contains(output, expectedWarningMsg), 'Expected warning for incorrect onsets was not issued.');
      end

      function test_empty_input(this)
          data = {[]};
          onsets = {[]};
          missing = {[]};
          segment_length = 3;
          expected_segments = [];
          expected_sessions = [];
          [segments, sessions] = pspm_extract_segments_core(data, onsets, segment_length, missing);
          this.verifyEqual(segments, expected_segments);
          this.verifyEqual(sessions, expected_sessions);
      end

      function test_wrong_missing_cell_length_warning(this)
          data = {[70,44,55,78,11,14,2,0,89,4,57,1,47,6,4,5,78,114,48]};
          onsets = {[3, 9, 18, 7]};
          missing = {logical([0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0])}; % Shorter than data
          segment_length = 5;

          % Capture the output and warnings
          [output, ~] = evalc('pspm_extract_segments_core(data, onsets, segment_length, missing)');

          % Verify that the specific warning message is present in the output
          expectedWarningMsg = 'The length of the missing data vector must be the same as the corresponding data vector in cell.';
          this.verifyTrue(contains(output, expectedWarningMsg), 'Expected warning for missing data length mismatch was not issued.');
      end


      function test_two_cell_arrays(this)
          data = {1:10, 11:20};
          onsets = {[3, 4, 5],[4,10]}; 
          missing = {false(1, 10),false(1,10)};
          segment_length = 2;
          expected_segments = [3,4;4,5;5,6;14,15;20,NaN];
          expected_sessions = [1;1;1;2;2];
          [segments, sessions] = pspm_extract_segments_core(data, onsets, segment_length, missing);
          this.verifyEqual(segments, expected_segments);
          this.verifyEqual(sessions, expected_sessions);
      end
  end
end
