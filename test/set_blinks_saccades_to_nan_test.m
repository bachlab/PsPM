classdef set_blinks_saccades_to_nan_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for the set_blinks_saccades_to_nan function
  % ● Authorship
  % (C) 2019 Eshref Yozdemir (University of Zurich)
  properties(Constant)
    left_blink_periods = {[], 20:30, [], 53:62};
    left_saccade_periods = {[], [], 45:56, 70:90};
    right_blink_periods = {15:25, [], [], 48:63};
    right_saccade_periods = {2:10, [], 32:36, []};
  end
  methods(TestClassSetup)
    function add(this)
      addpath(pspm_path('backroom'));
    end
  end
  methods(Test)
    function test_only_left_eye(this)
      column_names = {'blink_l', 'saccade_l', 'pupil_l', 'gaze_x_l', 'gaze_y_l'};
      mask_chans = {'blink_l', 'saccade_l'};
      fn_is_left = @(channame) strcmp(channame(end), 'l');
      data = [false(100, 2), randn(100, 3)];
      for i = 1:4
        data_in = data;
        data_in(this.left_blink_periods{i}, 1) = true;
        data_in(this.left_saccade_periods{i}, 2) = true;
        data_expect = data_in;
        data_expect(this.left_blink_periods{i}, 3:5) = NaN;
        data_expect(this.left_saccade_periods{i}, 3:5) = NaN;
        data_new = set_blinks_saccades_to_nan(data_in, column_names, mask_chans, fn_is_left);
        this.verifyEqual(data_new, data_expect);
      end
    end
    function test_only_right_eye(this)
      column_names = {'pupil_r', 'gaze_x_r', 'gaze_y_r', 'blink_r', 'saccade_r'};
      mask_chans = {'blink_r', 'saccade_r'};
      fn_is_left = @(channame) strcmp(channame(end), 'l');
      data = [randn(100, 3), false(100, 2)];
      for i = 1:4
        data_in = data;
        data_in(this.right_blink_periods{i}, 4) = true;
        data_in(this.right_saccade_periods{i}, 5) = true;
        data_expect = data_in;
        data_expect(this.right_blink_periods{i}, 1:3) = NaN;
        data_expect(this.right_saccade_periods{i}, 1:3) = NaN;
        data_new = set_blinks_saccades_to_nan(data_in, column_names, mask_chans, fn_is_left);
        this.verifyEqual(data_new, data_expect);
      end
    end
    function test_both_eyes(this)
      column_names = {'Pupil L', 'Pupil R', 'Gaze X L', 'Gaze X R', 'Gaze Y L',...
        'Gaze Y R', 'Blink L', 'Blink R', 'Saccade L', 'Saccade R'};
      mask_chans = {'Blink L', 'Blink R', 'Saccade L', 'Saccade R'};
      fn_is_left = @(channame) strcmp(channame(end-1:end), ' l');
      data = [randn(100, 6), false(100, 4)];
      for i = 1:4
        data_in = data;
        data_in(this.left_blink_periods{i}, end-3) = true;
        data_in(this.right_blink_periods{i}, end-2) = true;
        data_in(this.left_saccade_periods{i}, end-1) = true;
        data_in(this.right_saccade_periods{i}, end) = true;
        data_expect = data_in;
        data_expect(this.left_blink_periods{i}, [1, 3, 5]) = NaN;
        data_expect(this.right_blink_periods{i}, [2, 4, 6]) = NaN;
        data_expect(this.left_saccade_periods{i}, [1, 3, 5]) = NaN;
        data_expect(this.right_saccade_periods{i}, [2, 4, 6]) = NaN;
        data_new = set_blinks_saccades_to_nan(data_in, column_names, mask_chans, fn_is_left);
        this.verifyEqual(data_new, data_expect);
      end
    end
  end
  methods(TestClassTeardown)
    function remove(this)
      addpath(pspm_path('backroom'));
    end
  end
end