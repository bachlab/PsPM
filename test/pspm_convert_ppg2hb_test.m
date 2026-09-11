classdef pspm_convert_ppg2hb_test < pspm_testcase
% * Description
%   Unittest class for the pspm_convert_ppg2hb function

properties
    original_filename = fullfile('ImportTestData', 'ppg', 'pspm_SCAN_test.mat');
    input_filename = fullfile('ImportTestData', 'ppg', 'totest_pspm_SCAN_test.mat');
end

properties (TestParameter)
    method = {'classic', 'heartpy'};
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


options = struct('channel_action', 'wrong');
this.verifyWarning( @() pspm_convert_ppg2hb(this.input_filename, options), 'ID:invalid_input');

options = struct('lsm', 1000);
this.verifyWarning( @() pspm_convert_ppg2hb(this.input_filename, options), 'ID:invalid_input'); 

options = struct('diagnostics', 2);
this.verifyWarning( @() pspm_convert_ppg2hb(this.input_filename, options), 'ID:invalid_input');

options = struct('lsm', 10.5);
this.verifyWarning( @() pspm_convert_ppg2hb(this.input_filename, options), 'ID:invalid_input');

end

function basic_conversion(this,method)

 if strcmp(method, 'heartpy')
    psts = pspm_check_python;
    this.assumeEqual(psts, 1, 'Python is not available.');

    [psts, ~] = pspm_check_python_modules('heartpy');
    this.assumeEqual(psts, 1, 'HeartPy is not available.');
 end

fn = this.input_filename;

options = struct();
options.method = method;
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

function channel_action_add_replace(this,method)

if strcmp(method, 'heartpy')
    psts = pspm_check_python;
    this.assumeEqual(psts, 1, 'Python is not available.');

    [psts, ~] = pspm_check_python_modules('heartpy');
    this.assumeEqual(psts, 1, 'HeartPy is not available.');
end

fn = this.input_filename;

options = struct();
options.method = method;
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

function one_pulse_found(this)

    fn = this.input_filename;

    [nsts, infos, data] = pspm_load_data(fn);
    this.verifyEqual(nsts, 1);

    for i = 1:numel(data)
        if strcmpi(data{i}.header.chantype, 'ppg')
            data{i}.data(:) = 0;

            middle_sample = round(numel(data{i}.data) / 2);
            data{i}.data(middle_sample) = 1;

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

    this.verifyWarning( @() pspm_convert_ppg2hb(fn, options), 'ID:OnePulse');

end

function selects_last_ppg_channel_by_default(this)

    fn = this.input_filename;

    [nsts, infos, data] = pspm_load_data(fn);
    this.verifyEqual(nsts, 1);

    % Find an existing valid PPG channel.
    ppg_index = [];

    for i = 1:numel(data)
        if strcmpi(data{i}.header.chantype, 'ppg')
            ppg_index = i;
            break;
        end
    end

    this.assertFalse(isempty(ppg_index));

    % Add a second PPG channel containing no pulses.
    second_ppg = data{ppg_index};
    second_ppg.data(:) = 0;

    data{end + 1} = second_ppg;

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

    % Default 'ppg' must select the last PPG channel.
    this.verifyWarning( @() pspm_convert_ppg2hb(fn, options), 'ID:NoPulse');

end

function selects_ppg_channel_by_index(this)
    fn = this.input_filename;

    [nsts, infos, data] = pspm_load_data(fn);
    this.verifyEqual(nsts, 1);

    ppg_index = [];

    for i = 1:numel(data)
        if strcmpi(data{i}.header.chantype, 'ppg')
            ppg_index = i;
            break;
        end
    end

    this.assertFalse(isempty(ppg_index));

    % Add invalid second PPG channel.
    second_ppg = data{ppg_index};
    second_ppg.data(:) = 0;
    data{end + 1} = second_ppg;

    outdata.infos = infos;
    outdata.data = data;
    outdata.options.overwrite = 1;

    nsts = pspm_load_data(fn, outdata);
    this.verifyEqual(nsts, 1);

    options = struct();
    options.method = 'classic';
    options.channel = ppg_index;
    options.channel_action = 'add';
    options.diagnostics = false;

    [sts, outchannel] = pspm_convert_ppg2hb(fn, options);

    this.verifyEqual(sts, 1);
    this.verifyGreaterThan(outchannel, 0);

    [nsts, ~, data] = pspm_load_data(fn);
    this.verifyEqual(nsts, 1);

    this.verifyEqual(data{outchannel}.header.chantype, 'hb');

end

function basic_conversion_with_lsm(this)
    fn = this.input_filename;

    options = struct();
    options.method = 'classic';
    options.channel = 'ppg';
    options.channel_action = 'add';
    options.diagnostics = false;
    options.lsm = 10;

    [sts, outchannel] = pspm_convert_ppg2hb(fn, options);

    this.verifyEqual(sts, 1);

    [nsts, ~, data] = pspm_load_data(fn);
    this.verifyEqual(nsts, 1);

    this.verifyEqual(data{outchannel}.header.chantype, 'hb');
    this.verifyGreaterThan(numel(data{outchannel}.data), 1);
    this.verifyTrue(all(diff(data{outchannel}.data) > 0));

end

function no_pulse_found_with_lsm(this)
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
    options.lsm = 10;

    this.verifyWarning( ...
        @() pspm_convert_ppg2hb(fn, options), ...
        'ID:NoPulse');

end

function heartpy_rejects_invalid_peak(this)

    % Skip test if Python / HeartPy is unavailable.
    psts = pspm_check_python;
    this.assumeEqual(psts, 1, 'Python is not available.');

    [psts, ~] = pspm_check_python_modules('heartpy');
    this.assumeEqual(psts, 1, 'HeartPy is not available.');

    fn = this.input_filename;

    [nsts, infos, data] = pspm_load_data(fn);
    this.verifyEqual(nsts, 1);

    % Find PPG channel.
    ppg_index = [];

    for i = 1:numel(data)
        if strcmpi(data{i}.header.chantype, 'ppg')
            ppg_index = i;
            break;
        end
    end

    this.assertFalse(isempty(ppg_index));

    sr = data{ppg_index}.header.sr;
    n_samples = numel(data{ppg_index}.data);
    duration = (n_samples - 1) / sr;

    % Generate regular beats every second.
    beat_times = (2:1:floor(duration)-2)';

    % Add one premature beat 200 ms after a regular beat.
    middle = round(numel(beat_times) / 2);
    preceding_beat = beat_times(middle);
    artifact_time = preceding_beat + 0.2;

    impulses = zeros(n_samples, 1);

    beat_indices = round(beat_times * sr) + 1;
    artifact_index = round(artifact_time * sr) + 1;

    impulses(beat_indices) = 1;
    impulses(artifact_index) = 1;

    % Turn impulses into smooth PPG-like pulses.
    pulse_t = (-round(0.08 * sr):round(0.08 * sr))' / sr;
    pulse = exp(-0.5 * (pulse_t / 0.02).^2);

    synthetic_ppg = conv(impulses, pulse, 'same');

    data{ppg_index}.data = synthetic_ppg;

    % Save synthetic PPG.
    outdata.infos = infos;
    outdata.data = data;
    outdata.options.overwrite = 1;

    nsts = pspm_load_data(fn, outdata);
    this.verifyEqual(nsts, 1);

    % Run PsPM HeartPy conversion.
    options = struct();
    options.method = 'heartpy';
    options.channel = ppg_index;
    options.channel_action = 'add';
    options.diagnostics = false;

    [sts, outchannel] = pspm_convert_ppg2hb(fn, options);
    this.assertEqual(sts, 1);

    [nsts, ~, data] = pspm_load_data(fn);
    this.verifyEqual(nsts, 1);

    hb = data{outchannel}.data;

    tolerance = 0.05;

    % Normal surrounding beats must be present.
    this.verifyTrue( ...
        any(abs(hb - preceding_beat) < tolerance));

    this.verifyTrue( ...
        any(abs(hb - (preceding_beat + 1)) < tolerance));

    % Premature peak must have been rejected by HeartPy.
    this.verifyFalse( ...
        any(abs(hb - artifact_time) < tolerance));

end

end
end
