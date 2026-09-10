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
  % Verify options is not a struct
  this.verifyWarning(@() pspm_convert_hb2hp('abc',2,'abc'), 'ID:invalid_input');

  fn = this.input_filename;

  options.channel_action = 'abc';
  this.verifyWarning( @() pspm_convert_hb2hp(fn, 100, options), 'ID:invalid_input');

  options = struct('limit_lower', 2, 'limit_upper', 1);
  this.verifyWarning( @() pspm_convert_hb2hp(fn, 100, options), 'ID:invalid_input');

  options = struct('limit_lower', -1);
  this.verifyWarning( @() pspm_convert_hb2hp(fn, 100, options), 'ID:invalid_input');

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

function selects_hb_channel_by_index(this)
    fn = [tempname, '.mat'];

    channels = { ...
        struct('chantype', 'hb'), ...
        struct('chantype', 'hb') ...
        };

    testdata = pspm_testdata_gen(channels, 5);

    % Channel 1 -> HP = 1000 ms
    testdata.data{1}.data = ...
        [0.5; 1.5; 2.5; 3.5; 4.5];

    % Channel 2 -> HP = 500 ms
    testdata.data{2}.data = ...
        [0.5; 1.0; 1.5; 2.0; 2.5; 3.0; 3.5; 4.0; 4.5];

    save(fn, '-struct', 'testdata');
    cleanup = onCleanup(@() delete(fn));

    options.channel = 1;
    options.channel_action = 'add';

    [sts, outchannel] = pspm_convert_hb2hp(fn, 2, options);
    this.verifyEqual(sts, 1);

    [sts, ~, data] = pspm_load_data(fn);
    this.verifyEqual(sts, 1);

    hp = data{outchannel};

    % Explicitly selecting channel 1 must produce 1000 ms.
    this.verifyEqual(hp.data, 1000 * ones(size(hp.data)), 'AbsTol', 1e-10);
end

function too_strict_limits(this)
    fn = this.input_filename;
    sr = 1;
    options = struct('limit_lower', 10, 'limit_upper', 11);

    [sts, outchannel] = pspm_convert_hb2hp(fn, sr,options);
    this.verifyEqual(sts, 1);
    [sts, infos, data, filestruct] = pspm_load_data(fn);
    this.verifyEqual(sts, 1);
    this.verifyEqual(data{outchannel}.header.chantype, 'hp');
    this.verifyTrue(all(isnan(data{outchannel}.data)));
end

function too_strict_limits_warning(this)
    fn = this.input_filename;
    sr = 1;

    options = struct('limit_lower', 10, 'limit_upper', 11);
    this.verifyWarning(@() pspm_convert_hb2hp(fn, sr, options), 'ID:too_strict_limits');
end

function add_replace_channel_action(this)
    fn = this.input_filename;
    sr = 1;
    options.channel_action = 'add';

    [sts, ~, ~, filestruct] = pspm_load_data(fn);
    this.verifyEqual(sts, 1);

    original_num_channels = filestruct.numofchan;

    % add 1st hp
    [sts, hp1] = pspm_convert_hb2hp(fn, sr, options);
    this.verifyEqual(sts, 1);

    [sts, ~, data, ~] = pspm_load_data(fn);
    this.verifyEqual(sts, 1);
    this.verifyEqual(data{hp1}.header.chantype, 'hp');
    this.verifyEqual(original_num_channels + 1, numel(data));

    % add 2nd hp
    [sts, hp2] = pspm_convert_hb2hp(fn, sr, options);
    this.verifyEqual(sts, 1);

    [sts, ~, data, ~] = pspm_load_data(fn);
    this.verifyEqual(sts, 1);
    this.verifyEqual(data{hp2}.header.chantype, 'hp');
    this.verifyEqual(original_num_channels + 2, numel(data));

    % Make sure the two added channels are different channels
    this.verifyNotEqual(hp1, hp2);

    % replace last hp
    options.channel_action = 'replace';

    [sts, hp_replaced] = pspm_convert_hb2hp(fn, sr, options);
    this.verifyEqual(sts, 1);

    [sts, ~, data, ~] = pspm_load_data(fn);
    this.verifyEqual(sts, 1);

    % Number of channels must stay the same
    this.verifyEqual(original_num_channels + 2, numel(data));

    % The last HP channel should have been replaced
    this.verifyEqual(hp_replaced, hp2);

    % Replaced channel is still HP
    this.verifyEqual(data{hp_replaced}.header.chantype, 'hp');
end

function known_heart_period_values(this)
    fn = [tempname, '.mat'];

    duration = 5;
    sr = 2;

    channels = {struct('chantype', 'hb')};
    testdata = pspm_testdata_gen(channels, duration);
    testdata.data{1}.data = [0.5; 1.5; 3.0; 4.0];

    save(fn, '-struct', 'testdata');
    cleanup = onCleanup(@() delete(fn));
    
    % Convert HB -> HP.
    [sts, outchannel] = pspm_convert_hb2hp(fn, sr);
    this.verifyEqual(sts, 1);

    [sts, ~, data, ~] = pspm_load_data(fn);
    this.verifyEqual(sts, 1);

    hp = data{outchannel};

    % Expected interpolated HP signal.
    expected_hp = [ ...
        1000;
        1000;
        1000;
        1166.666666666667;
        1333.333333333333;
        1500;
        1250;
        1000;
        1000;
        1000
        ];

    % Verify actual numerical conversion.
    this.verifyEqual(hp.data, expected_hp, 'AbsTol', 1e-10);

    % Verify metadata.
    this.verifyEqual(hp.header.chantype, 'hp');
    this.verifyEqual(hp.header.units, 'ms');
    this.verifyEqual(hp.header.sr, sr);
end

function selects_last_hb_channel_by_default(this)
    fn = [tempname, '.mat'];
    
    channels = { ...
        struct('chantype', 'hb'), ...
        struct('chantype', 'hb') ...
        };

    testdata = pspm_testdata_gen(channels, 5);

    % Channel 1: IBI = 1 s -> HP = 1000 ms
    testdata.data{1}.data = [0.5; 1.5; 2.5; 3.5; 4.5];

    % Channel 2: IBI = 0.5 s -> HP = 500 ms
    testdata.data{2}.data = ...
        [0.5; 1.0; 1.5; 2.0; 2.5; 3.0; 3.5; 4.0; 4.5];

    save(fn, '-struct', 'testdata');
    cleanup = onCleanup(@() delete(fn));

    sr = 2;
    options.channel_action = 'add';

    [sts, outchannel] = pspm_convert_hb2hp(fn, sr, options);

    this.verifyEqual(sts, 1);

    [sts, ~, data] = pspm_load_data(fn);
    this.verifyEqual(sts, 1);

    hp = data{outchannel};

    this.verifyEqual(hp.header.chantype, 'hp');
    this.verifyEqual(hp.header.units, 'ms');
    this.verifyEqual(hp.header.sr, sr);

    % Default 'hb' must select the LAST HB channel.
    this.verifyEqual(hp.data, 500 * ones(size(hp.data)), 'AbsTol', 1e-10);

end
end
end
