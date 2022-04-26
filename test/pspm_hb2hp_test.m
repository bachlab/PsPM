classdef pspm_hb2hp_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for the pspm_hb2hp function
  % PsPM TestEnvironment
  % ● Authorship
  % (C) 2019 Ivan Rojkov (University of Zurich)
  methods (Test)
    function invalid_input(this)
      files = {...
        fullfile('ImportTestData', 'ecg2hb', 'test_ecg_outlier_data_short.mat'),...
        fullfile('ImportTestData', 'ecg2hb', 'test_hb2hp_data1.mat'),...
        fullfile('ImportTestData', 'ecg2hb', 'test_hb2hp_data2.mat')...
        };
      options.channel_action = 'abc';
      % Verify no input
      this.verifyWarning(@() pspm_hb2hp(), 'ID:invalid_input');
      % Verify not a string filename
      this.verifyWarning(@() pspm_hb2hp(2), 'ID:invalid_input');
      % Verify no sample rate
      this.verifyWarning(@() pspm_hb2hp('abc'), 'ID:invalid_input');
      % Verify not a string sample rate
      this.verifyWarning(@() pspm_hb2hp('abc','abc'), 'ID:invalid_input');
      % Verify not a numeric channel
      this.verifyWarning(@() pspm_hb2hp('abc',2,'abc'), 'ID:invalid_input');
      % Verify that call of pspm_load_data fails
      this.verifyWarning(@() pspm_hb2hp(files{1},100), 'ID:invalid_input');
      % Verify that interpolation does not have enough points
      this.verifyWarning(@() pspm_hb2hp(files{2}, 100), 'ID:too_strict_limits');
      % Verify that call of pspm_write_channel fails
      this.verifyWarning(@() pspm_hb2hp(files{3},100,[],options), 'ID:invalid_input');
    end
  end
end