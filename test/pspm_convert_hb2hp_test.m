classdef pspm_convert_hb2hp_test < matlab.unittest.TestCase
% * Description
%   Unittest class for the pspm_convert_hb2hp function
% * History
%   Written in 2019 by Ivan Rojkov (University of Zurich)
%   Updated in 2024 by Teddy
%   Updated in 2026 by Bernhard von Raußendorf

properties (Constant)
    input_filename = fullfile(fileparts(mfilename('fullpath')), 'ImportTestData', 'ecg2hb', 'test_ecg_outlier_data_short_hb.mat');
    backup_filename = fullfile(fileparts(mfilename('fullpath')),'ImportTestData', 'ecg2hb', 'test_backup.mat');
end

methods (TestClassSetup)
 function backup(this)
    this.assertTrue(isfile(this.input_filename), ...
        sprintf('Input file not found: %s', this.input_filename));

    [sts, msg] = copyfile(this.input_filename, this.backup_filename);
    this.assertTrue(sts, msg);
 end
end

methods (TestMethodSetup)
 function reset_input_file(this)
    [sts, msg] = copyfile(this.backup_filename, this.input_filename);
    this.assertTrue(sts, msg);
 end
end

% Tests
methods (Test)
function invalid_input(this)
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

  % 
  % % Verify that call of pspm_load_data fails
  % this.verifyWarning(@() pspm_convert_hb2hp(files{1},100), 'ID:nonexistent_file');
  % % Verify that interpolation does not have enough points
  % % this.verifyWarning(@() pspm_convert_hb2hp(files{2}, 100), 'ID:too_strict_limits');
  % % Verify that call of pspm_write_channel fails
  % options.channel_action = 'abc';
  % this.verifyWarning(@() pspm_convert_hb2hp(files{3},100,[],options),'ID:invalid_input');
  % %options.channel_action = 'add';
  % %this.verifyWarningFree(@()pspm_convert_hb2hp(files{1},100,[],options));

end

function basic_conversion(this)
    sr = 1000;

    % this.verifyWarningFree(@() pspm_convert_hb2hp(this.input_filename, sr));

    [sts, outchannel] = pspm_convert_hb2hp(this.input_filename, sr);

    this.verifyEqual(sts, 1);
    this.verifyTrue(isnumeric(outchannel));
    this.verifyGreaterThan(outchannel, 0);
end

function too_strict_limits(this)
    % fn = fullfile('ImportTestData', 'ecg2hb', 'test_hb2hp_data2.mat');
    sr = 100;
    options = struct();
    options = struct('limit_lower', 10, 'limit_upper', 11);

    this.verifyWarning(@() pspm_convert_hb2hp(this.input_filename, sr, options), 'ID:too_strict_limits');

    [sts, outchannel] = pspm_convert_hb2hp(this.input_filename, sr, options);
    this.verifyEqual(sts, 1);
    this.verifyTrue(isnumeric(outchannel));
    this.verifyGreaterThan(outchannel, 0);
end

function add_channel_action(this)
    fn = fullfile('ImportTestData', 'ecg2hb', 'test_ecg_outlier_data_short_hb.mat');
    sr = 100;
    options = struct();
    options.channel_action = 'add';

    this.verifyWarningFree(@() pspm_convert_hb2hp(fn, sr, options));

    [sts, outchannel] = pspm_convert_hb2hp(fn, sr, options);

    this.verifyEqual(sts, 1);
    this.verifyTrue(isnumeric(outchannel));
    this.verifyGreaterThan(outchannel, 0);
end




end

methods (TestClassTeardown)
 function restore(this)
    if isfile(this.backup_filename)
        [sts, msg] = copyfile(this.backup_filename, this.input_filename);
        this.assertTrue(sts, msg);
        delete(this.backup_filename);
    end
 end
end

end
