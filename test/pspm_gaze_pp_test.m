classdef pspm_gaze_pp_test < pspm_testcase
% Definition
% pspm_gaze_pp_test unittest classes for the pspm_gaze_pp function
% PsPM TestEnvironment
% (C) 2021 Teddy
% (C) Updated 2025 Bernhard von Raußendorf
properties
    raw_input_fn = fullfile('ImportTestData', 'eyelink', 'S114_s2.asc');
    pspm_input_fn = '';
    backup_fn = '';
end

methods(TestClassSetup)
function backup(this)
  import = {};
  import{end + 1}.type = 'pupil_l';
  import{end}.eyelink_trackdist = 600;
  import{end}.distance_unit = 'mm';
  import{end + 1}.type = 'pupil_r';
  import{end}.eyelink_trackdist = 600;
  import{end}.distance_unit = 'mm';
  import{end + 1}.type = 'gaze_x_l';
  import{end}.eyelink_trackdist = 600;
  import{end}.distance_unit = 'mm';
  import{end + 1}.type = 'gaze_y_l';
  import{end}.eyelink_trackdist = 600;
  import{end}.distance_unit = 'mm';
  import{end + 1}.type = 'gaze_x_r';
  import{end}.eyelink_trackdist = 600;
  import{end}.distance_unit = 'mm';
  import{end + 1}.type = 'gaze_y_r';
  import{end}.eyelink_trackdist = 600;
  import{end}.distance_unit = 'mm';
  import{end + 1}.type = 'marker';
  options = struct();
  options.overwrite = 1; % to always overwrite

  [sts, this.pspm_input_fn] = pspm_import( ...
    this.raw_input_fn, 'eyelink', import, options);

  this.assertEqual(sts, 1);
  this.assertTrue(exist(this.pspm_input_fn, 'file') == 2);

  [pathstr, name, ext] = fileparts(this.pspm_input_fn);
  this.backup_fn = fullfile(pathstr, [name, '_backup', ext]);

  [sts, msg] = copyfile(this.pspm_input_fn, this.backup_fn);
  this.assertTrue(sts, msg);
end
end
methods (TestMethodSetup)
    function reset_input_file(this)
        [sts, msg] = copyfile(this.backup_fn, this.pspm_input_fn);
        this.assertTrue(sts, msg);
    end
end

methods(Test)
function invalid_input(this)
  this.verifyWarning(@()pspm_gaze_pp(52), 'ID:invalid_input');
  this.verifyWarning(@()pspm_gaze_pp('abc'), 'ID:nonexistent_file');

  opt.channel = 'scr';
  this.verifyWarning(@()pspm_gaze_pp(this.pspm_input_fn, opt), ...
    'ID:invalid_input');

  opt.channel = 1:3;
  this.verifyWarning(@()pspm_gaze_pp(this.pspm_input_fn, opt), ...
    'ID:invalid_input');

  opt.channel = 1:4;
  this.verifyWarning(@()pspm_gaze_pp(this.pspm_input_fn, opt), ...
    'ID:unexpected_channeltype');
end
function preprocessed_channel(this)
  opt.channel = 'gaze';
  opt.channel_action = 'add';

  [sts, out_channel] = this.verifyWarningFree(@() ...
    pspm_gaze_pp(this.pspm_input_fn, opt));

  this.verifyEqual(sts, 1);
  this.verifyEqual(numel(out_channel), 2);

  testdata = load(this.pspm_input_fn);
  this.verifyEqual(testdata.data{out_channel(1)}.header.chantype, 'gaze_x_c');
  this.verifyEqual(testdata.data{out_channel(2)}.header.chantype, 'gaze_y_c');

  opt.channel = [5, 3, 6, 4];
  opt.channel_action = 'add';

  [sts, out_channel] = this.verifyWarningFree(@() ...
    pspm_gaze_pp(this.pspm_input_fn, opt));

  this.verifyEqual(sts, 1);
  this.verifyEqual(numel(out_channel), 2);

  testdata = load(this.pspm_input_fn);
  this.verifyEqual(testdata.data{out_channel(1)}.header.chantype, 'gaze_x_c');
  this.verifyEqual(testdata.data{out_channel(2)}.header.chantype, 'gaze_y_c');
end
function channel_action_add_replace(this)
  [nsts, ~, data] = pspm_load_data(this.pspm_input_fn);
  this.verifyEqual(nsts, 1);
  n_channels = numel(data);

  opt.channel = 'gaze';
  opt.channel_action = 'add';

  [sts, out_add] = pspm_gaze_pp(this.pspm_input_fn, opt);
  this.verifyEqual(sts, 1);

  [nsts, ~, data] = pspm_load_data(this.pspm_input_fn);
  this.verifyEqual(nsts, 1);
  this.verifyEqual(numel(data), n_channels + 2);
  this.verifyEqual(data{out_add(1)}.header.chantype, 'gaze_x_c');
  this.verifyEqual(data{out_add(2)}.header.chantype, 'gaze_y_c');

  opt.channel_action = 'replace';

  [sts, out_replace] = pspm_gaze_pp(this.pspm_input_fn, opt);
  this.verifyEqual(sts, 1);

  [nsts, ~, data] = pspm_load_data(this.pspm_input_fn);
  this.verifyEqual(nsts, 1);
  this.verifyEqual(numel(data), n_channels + 2);
  this.verifyEqual(out_replace, out_add);
  this.verifyEqual(data{out_replace(1)}.header.chantype, 'gaze_x_c');
  this.verifyEqual(data{out_replace(2)}.header.chantype, 'gaze_y_c');
end

end


methods (TestClassTeardown)
    function cleanup(this)
        if exist(this.pspm_input_fn, 'file') == 2
            delete(this.pspm_input_fn);
        end

        if exist(this.backup_fn, 'file') == 2
            delete(this.backup_fn);
        end
    end
end
end
