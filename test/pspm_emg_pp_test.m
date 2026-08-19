classdef pspm_emg_pp_test < pspm_testcase
% * Description
%   Unittest class for the pspm_emg_pp function

properties
    original_filename = fullfile('ImportTestData', 'emg', 'pspm_TM012face.mat');
    input_filename = fullfile('ImportTestData', 'emg', 'totest_pspm_TM012face.mat');
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

methods (Test)

function invalid_input(this)
fn = this.input_filename;

options = struct();
options.mains_freq = 'abc';

this.verifyWarning(@() pspm_emg_pp(fn, options), ...
    'ID:invalid_input');
end

function basic_preprocessing(this)
    fn = this.input_filename;
    
    options = struct();
    options.channel = 'emg';
    options.channel_action = 'add';
    options.mains_freq = 50;
    
    [nsts, ~, data, filestruct] = pspm_load_data(fn);
    this.verifyEqual(nsts, 1);
    
    [sts, outchannel] = pspm_emg_pp(fn, options);
    
    this.verifyEqual(sts, 1);
    this.verifyTrue(isnumeric(outchannel));
    this.verifyGreaterThan(outchannel, 0);
    
    [nsts, infos, data] = pspm_load_data(fn);
    this.verifyEqual(nsts, 1);
    
    this.verifyEqual(numel(data), filestruct.numofchan + 1);
    this.verifyEqual(data{outchannel}.header.chantype, 'emg_pp');
    this.verifyGreaterThan(numel(data{outchannel}.data), 0);
    this.verifyTrue(all(isfinite(data{outchannel}.data)));
    
    % this.verifyTrue(isfield(infos, 'history'));
    % this.verifyTrue(contains(infos.history{end}, 'EMG preprocessing'));
    % this.verifyTrue(contains(infos.history{end}, 'Output channeltype: emg_pp'));
end

function channel_action_add_replace(this)
    fn = this.input_filename;
    
    options = struct();
    options.channel = 'emg';
    options.channel_action = 'add';
    options.mains_freq = 50;
    
    [nsts, ~, data, filestruct] = pspm_load_data(fn);
    this.verifyEqual(nsts, 1);
    
    % add emg_pp
    [sts, outch_add] = pspm_emg_pp(fn, options);
    this.verifyEqual(sts, 1);
    
    [nsts, ~, data] = pspm_load_data(fn);
    this.verifyEqual(nsts, 1);
    this.verifyEqual(numel(data), filestruct.numofchan + 1);
    this.verifyEqual(data{outch_add}.header.chantype, 'emg_pp');
    
    % repace emg_pp
    options.channel_action = 'replace';
    [sts, outch_replace] = pspm_emg_pp(fn, options);
    this.verifyEqual(sts, 1);
    
    [nsts, ~, data] = pspm_load_data(fn);
    this.verifyEqual(nsts, 1);
    
    this.verifyEqual(numel(data), filestruct.numofchan + 1);
    this.verifyEqual(outch_replace, outch_add);
    this.verifyEqual(data{outch_replace}.header.chantype, 'emg_pp');
end

function channel_action_replace(this)
    fn = this.input_filename;
    
    options = struct();
    options.channel = 'emg';
    options.channel_action = 'replace';
    options.mains_freq = 50;
    
    [nsts, ~, data, filestruct] = pspm_load_data(fn);
    this.verifyEqual(nsts, 1);
    
    % replace emg_pp
    [sts, outch] = pspm_emg_pp(fn, options);
    this.verifyEqual(sts, 1);
    
    [nsts, ~, data] = pspm_load_data(fn);
    this.verifyEqual(nsts, 1);
    this.verifyEqual(numel(data), filestruct.numofchan + 1);
    this.verifyEqual(data{outch}.header.chantype, 'emg_pp');


end
end
end