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
          expected_sessions = [1,1,1];
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
          expected_sessions = [1,1,1];
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
          expected_sessions = [1,1,1];
          [segments, sessions] = pspm_extract_segments_core(data, onsets, segment_length, missing);
          this.verifyEqual(segments, expected_segments);
          this.verifyEqual(sessions, expected_sessions);
      end

      function test_incorrect_onsets(this)
          data = {1:10};
          onsets = {[0, 11]};
          missing = {false(1, 10)};
          segment_length = 3;
          this.verifyError(@() pspm_extract_segments_core(data, onsets, segment_length, missing), ...
                           'pspm_extract_segments_core:InvalidOnset');
      end

      function test_cell_arrays_different_sizes(this)
          data = {1:10, 11:20};
          onsets = {[3, 4, 5]}; 
          missing = {false(1, 10)};
          segment_length = 3;
          this.verifyError(@() pspm_extract_segments_core(data, onsets, segment_length, missing), ...
                           'pspm_extract_segments_core:SizeMismatch');
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

      function test_wrong_missing_cell_length(this)
          data = {[70,44,55,78,11,14,2,0,89,4,57,1,47,6,4,5,78,114,48]};
          onsets = { [3, 9,18,7] };
          missing = { logical([0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0]) };
          segment_length = 5;
          this.verifyError(@() pspm_extract_segments_core(data, onsets, segment_length, missing), ...
                           'pspm_extract_segments_core:MissingDataLengthMismatch');
      end

      function test_two_cell_arrays(this)
          data = {1:10, 11:20};
          onsets = {[3, 4, 5],[4,10]}; 
          missing = {false(1, 10),false(1,10)};
          segment_length = 2;
          expected_segments = [3,4;4,5;5,6;14,15;20,NaN];
          expected_sessions = [1,1,1,2,2];
          [segments, sessions] = pspm_extract_segments_core(data, onsets, segment_length, missing);
          this.verifyEqual(segments, expected_segments);
          this.verifyEqual(sessions, expected_sessions);
      end
  end
end
