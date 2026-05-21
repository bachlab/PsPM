classdef pspm_convert_hb2hp_test < pspm_testcase
% * Description
%   Unittest class for the pspm_convert_hb2hp function
% * History
%   Written in 2019 by Ivan Rojkov (University of Zurich)
%   Updated in 2024 by Teddy
%   Updated in 2026 by Bernhard von Raußendorf

properties
    original_filename = fullfile(fileparts(mfilename('fullpath')), '..', ...
        'ImportTestData', 'ecg2hb', 'test_ecg_outlier_data_short_hb.mat');

    input_filename = fullfile(fileparts(mfilename('fullpath')), '..', ...
        'ImportTestData', 'ecg2hb', 'totest_test_ecg_outlier_data_short_hb.mat');
end

methods (TestClassSetup)
    function check_original_file(this)
        this.assertTrue(exist(this.original_filename, 'file') == 2, ...
            sprintf('Input file not found: %s', this.original_filename));
    end
end

methods (TestMethodSetup)
    function reset_input_file(this)
        [sts, msg] = copyfile(this.original_filename, this.input_filename);
        this.assertTrue(sts, msg);
    end
end

methods (TestClassTeardown)
    function cleanup(this)
        if exist(this.input_filename, 'file') == 2
            delete(this.input_filename);
        end
    end
end

% Tests
methods (Test)
function invalid_input(this)
  % Verify no input
  this.verifyWarning(@() pspm_convert_hb2hp(), 'ID:invalid_input');
  % Verify not a string filename
  this.verifyWarning(@() pspm_convert_hb2hp(2, 100), 'ID:invalid_input');
   % Verify no sample rate
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
    fn = this.input_filename;
    sr = 1000;

    % this.verifyWarningFree(@() pspm_convert_hb2hp(this.input_filename, sr));
    [sts, outchannel] = pspm_convert_hb2hp(fn, sr);
    this.verifyEqual(sts, 1);
    [sts, infos, data, filestruct] = pspm_load_data(fn);
    this.verifyEqual(sts, 1);
    this.verifyEqual(data{outchannel}.header.chantype, 'hp');
end

function too_strict_limits(this)
    fn = this.input_filename;
    sr = 1;
    options = struct('limit_lower', 11, 'limit_upper', 11);

    % options = struct('limit_lower', 10, 'limit_upper', 11);
    % this.verifyWarning(@() pspm_convert_hb2hp(fn, sr, options), ...
    % 'ID:too_strict_limits');

    % this.verifyWarningFree(@() pspm_convert_hb2hp(this.input_filename, sr));
    [sts, outchannel] = pspm_convert_hb2hp(fn, sr,options);
    this.verifyEqual(sts, 1);
    [sts, infos, data, filestruct] = pspm_load_data(fn);
    this.verifyEqual(sts, 1);
    this.verifyEqual(data{outchannel}.header.chantype, 'hp');
    this.verifyTrue(any(isnan(data{outchannel}.data)))
end

function add_replace_channel_action(this)
    fn = this.input_filename;
    sr = 1;
    options.channel_action = 'add';

    [sts, infos, ~, filestruct] = pspm_load_data(fn);
    this.verifyEqual(sts, 1);
    % display(infos.history)

    % add 1st hp 
    [sts, outchannel] = pspm_convert_hb2hp(fn, sr, options);
    this.verifyEqual(sts, 1);
    [sts, ~, data, ~ ] = pspm_load_data(fn);
    this.verifyEqual(sts, 1);
    this.verifyEqual(data{outchannel}.header.chantype, 'hp');
    this.verifyEqual(filestruct.numofchan + 1 , numel(data));
    % display(infos.history)

    % add 2nd hp
    [sts, outchannel] = pspm_convert_hb2hp(fn, sr, options);
    this.verifyEqual(sts, 1);
    [sts, ~, data, ~ ] = pspm_load_data(fn);

    this.verifyEqual(sts, 1);
    this.verifyEqual(data{outchannel}.header.chantype, 'hp');
    this.verifyEqual(filestruct.numofchan + 2 , numel(data));


    % replace hp (last)
    options.channel_action = 'replace';    
    [sts, outchannel] = pspm_convert_hb2hp(fn, sr, options);
    this.verifyEqual(sts, 1);
    [sts, infos, data, ~] = pspm_load_data(fn);
    
    % infos.history
    this.verifyEqual(sts, 1);
    this.verifyEqual(data{outchannel}.header.chantype, 'hp');
    this.verifyEqual(filestruct.numofchan + 2 , numel(data));

end
end
end
