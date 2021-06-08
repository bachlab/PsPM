classdef pspm_scr_pp_test < matlab.unittest.TestCase
% SCR_PP_TEST
% unittest class for the pspm_pp function
%__________________________________________________________________________
% SCRalyze TestEnvironment
% (C) 2013 Linus R�ttimann (University of Zurich)

properties(Constant)
fn = 'testdatafile79887.mat';
end

methods (Test)
function invalid_input(this)
    % test for invalid file
    this.verifyWarning(@()pspm_pp('butter', 'file'), 'ID:invalid_input');
    % for the following tests a valid file is required thus
    % generate some random data
    channels{1}.chantype = 'scr';
    channels{2}.chantype = 'hb';
    channels{3}.chantype = 'scr';
    pspm_testdata_gen(channels, 10, this.fn);
    % perform the other tests with invalid input data
    this.verifyWarning(@()pspm_scr_pp( this.fn, struct('sr', 10)), 'ID:invalid_input');
    % this.verifyWarning(@()pspm_pp('simple_qa', fn, struct('missing_epochs_filename', 1)), 'ID:invalid_input');
end


function scr_pp_test(this)
    %generate testdata
    channels{1}.chantype = 'scr';
    sr = 10;
    

    %filter one channel
    options1 = struct('deflection_threshold', 0, ...
    'expand_epochs', 0, ...
    'channel_action', 'add');

    options2 = struct('deflection_threshold', 0, ...
    'expand_epochs', 0, ...
    'channel_action', 'replace');

    options3 = struct('missing_epochs_filename', 'test_missing.mat', ...
    'deflection_threshold', 0, ...
    'expand_epochs', 0);

    pspm_testdata_gen(channels, sr, this.fn);
    [sts, ~, ~, filestruct] = pspm_load_data(this.fn, 'none');
    this.verifyTrue(sts == 1, 'the returned file couldn''t be loaded');
    this.verifyTrue(filestruct.numofchan == numel(channels), 'the returned file contains not as many channels as the inputfile');

    % Verifying the situation without no missing epochs filename option and add the epochs to the file
    pspm_testdata_gen(channels, sr, this.fn);
    [~, out] = pspm_scr_pp(this.fn, sr, options1);
    [sts_out, ~, ~, ~] = pspm_load_data(out{1}, 'none');
    % Verify out
    this.verifyTrue(sts_out == 1, 'the returned file couldn''t be loaded');

    % Verifying the situation without no missing epochs filename option and replace the data in the file
    pspm_testdata_gen(channels, sr, this.fn);
    [~, out] = pspm_scr_pp(this.fn, sr, options2);
    [sts_out, ~, ~, filestruct_out] = pspm_load_data(out{1}, 'none');
    % Verify out
    this.verifyTrue(sts_out == 1, 'the returned file couldn''t be loaded');
    this.verifyTrue(filestruct_out.numofchan == numel(channels), 'the output has a different size');

    % Verifying the situation with missing epochs filename option
    pspm_testdata_gen(channels, sr, this.fn);
    [~, out] = pspm_scr_pp(this.fn, sr, options3);
    [sts_out, ~, ~, filestruct_out] = pspm_load_data(out{1}, 'none');
    % Verify out
    this.verifyTrue(sts_out == 1, 'the returned file couldn''t be loaded');
    this.verifyTrue(filestruct_out.numofchan == numel(channels), 'the output has a different size');
    % may need to verify epochs...

    % test no file exists when not provided
    % this.verifyError(@()load('missing_epochs_test_out'), 'MATLAB:load:couldNotReadFile');

    % Delete testdata
    delete(this.fn);
    delete('test_missing.mat');
end
end
end
