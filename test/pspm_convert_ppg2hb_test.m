classdef pspm_convert_ppg2hb_test < pspm_testcase
% * Description
%   Unittest class for the pspm_convert_ppg2hb function

properties
original_filename = '/home/hanno/git/PsPM/test/DatenZumTesten/ppg/pspm_SCAN_test.mat';
input_filename = '/home/hanno/git/PsPM/test/DatenZumTesten/ppg/totest_pspm_SCAN_test.mat';
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

% needs a test for py method

function invalid_input(this)
this.verifyWarning(@() pspm_convert_ppg2hb(), 'ID:invalid_input');
this.verifyWarning(@() pspm_convert_ppg2hb(1),'ID:invalid_input');

options = struct();
options.method = 'wrong_method';
this.verifyWarning(@() pspm_convert_ppg2hb(this.input_filename, options), 'ID:invalid_input');

end

function basic_conversion_classic(this)
fn = this.input_filename;

options = struct();
options.method = 'classic';
options.channel = 'ppg';
options.channel_action = 'add';
options.diagnostics = false;

[nsts, ~, data] = pspm_load_data(fn);
this.verifyEqual(nsts, 1);
n_channels = numel(data);

[sts, outchannel] = pspm_convert_ppg2hb(fn, options);

this.verifyEqual(sts, 1);
this.verifyTrue(isnumeric(outchannel));
this.verifyGreaterThan(outchannel, 0);

[nsts, infos, data] = pspm_load_data(fn);
this.verifyEqual(nsts, 1);
this.verifyEqual(numel(data), n_channels + 1);

this.verifyEqual(data{outchannel}.header.chantype, 'hb');
this.verifyEqual(data{outchannel}.header.units, 'events');
this.verifyEqual(data{outchannel}.header.sr, 1);

this.verifyGreaterThan(numel(data{outchannel}.data), 1);
this.verifyTrue(all(diff(data{outchannel}.data) > 0));

% this.verifyTrue(isfield(infos, 'history'));
% this.verifyTrue(contains(infos.history{end}, ...
%     'Heart beat detection from ppg'));
end

function channel_action_add_replace(this)
fn = this.input_filename;

options = struct();
options.method = 'classic';
options.channel = 'ppg';
options.channel_action = 'add';
options.diagnostics = false;

[nsts, ~, data, filestruct] = pspm_load_data(fn);
this.verifyEqual(nsts, 1);

% add hb
[sts, outch_add] = pspm_convert_ppg2hb(fn, options);
this.verifyEqual(sts, 1);

[nsts, ~, data] = pspm_load_data(fn);
this.verifyEqual(nsts, 1);
this.verifyEqual(numel(data), filestruct.numofchan + 1);
this.verifyEqual(data{outch_add}.header.chantype, 'hb');

% replace hb
options.channel_action = 'replace';

[sts, outch_replace] = pspm_convert_ppg2hb(fn, options);
this.verifyEqual(sts, 1);

[nsts, ~, data] = pspm_load_data(fn);
this.verifyEqual(nsts, 1);
this.verifyEqual(numel(data), filestruct.numofchan + 1);
this.verifyEqual(outch_replace, outch_add);
this.verifyEqual(data{outch_replace}.header.chantype, 'hb');
end

function no_pulse_found(this)
fn = this.input_filename;

[nsts, infos, data] = pspm_load_data(fn);
this.verifyEqual(nsts, 1);

for i = 1:numel(data)
    if strcmpi(data{i}.header.chantype, 'ppg')
        data{i}.data(:) = 0;
        break;
    end
end

outdata.infos = infos;
outdata.data = data;
outdata.options.overwrite = 1;

nsts = pspm_load_data(fn, outdata);
this.verifyEqual(nsts, 1);

options = struct();
options.method = 'classic';
options.channel = 'ppg';
options.channel_action = 'add';
options.diagnostics = false;

this.verifyWarning(@() pspm_convert_ppg2hb(fn, options), 'ID:NoPulse');
end
end
end