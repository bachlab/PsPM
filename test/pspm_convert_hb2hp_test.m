classdef pspm_convert_hb2hp_test < matlab.unittest.TestCase
% * Description
%   Unittest class for the pspm_convert_hb2hp function
% * History
%   Written in 2019 by Ivan Rojkov (University of Zurich)
%   Updated in 2024 by Teddy
methods (Test)
function invalid_input(this)
  files = {...
  fullfile('ImportTestData', 'ecg2hb', 'test_ecg_outlier_data_short.mat'),...
  fullfile('ImportTestData', 'ecg2hb', 'test_hb2hp_data1.mat'),...
  fullfile('ImportTestData', 'ecg2hb', 'test_hb2hp_data2.mat')...
  };
  % Verify no input
  this.verifyWarning(@() pspm_convert_hb2hp(), 'ID:invalid_input');
  % Verify not a string filename
  this.verifyWarning(@() pspm_convert_hb2hp(2), 'ID:invalid_input');
  % Verify no sample rate
  this.verifyWarning(@() pspm_convert_hb2hp('abc'), 'ID:invalid_input');
  % Verify not a string sample rate
  this.verifyWarning(@() pspm_convert_hb2hp('abc','abc'), 'ID:invalid_input');
  % Verify not a numeric channel
  this.verifyWarning(@() pspm_convert_hb2hp('abc',2,'abc'), 'ID:invalid_input');
  % Verify that call of pspm_load_data fails
  this.verifyWarning(@() pspm_convert_hb2hp(files{1},100), 'ID:nonexistent_file');
  % Verify that interpolation does not have enough points
  % this.verifyWarning(@() pspm_convert_hb2hp(files{2}, 100), 'ID:too_strict_limits');
  % Verify that call of pspm_write_channel fails
  options.channel_action = 'abc';
  this.verifyWarning(@() pspm_convert_hb2hp(files{3},100,[],options),'ID:invalid_input');
  %options.channel_action = 'add';
  %this.verifyWarningFree(@()pspm_convert_hb2hp(files{1},100,[],options));

end

end

end
