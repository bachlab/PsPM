classdef pspm_pupil_correct_eyelink_test < pspm_testcase
  % ● Description
  % unittest class for the pspm_pupil_correct_eyelink function
  % ● Authorship
  % (C) 2019 Eshref Yozdemir (University of Zurich)
  properties
    raw_input_filename = fullfile('ImportTestData', 'eyelink', 'S114_s2.asc');
    pspm_input_filename = '';
  end
  methods(TestClassSetup)
    function backup(this)
      import = {};
      import{end + 1}.type = 'pupil_r';
      import{end}.eyelink_trackdist = 600;
      import{end}.distance_unit = 'mm';
      import{end + 1}.type = 'pupil_l';
      import{end}.eyelink_trackdist = 600;
      import{end}.distance_unit = 'mm';
      import{end + 1}.type = 'gaze_x_r';
      import{end + 1}.type = 'gaze_y_r';
      import{end + 1}.type = 'gaze_x_l';
      import{end + 1}.type = 'gaze_y_l';
      import{end + 1}.type = 'marker';
      this.pspm_input_filename = pspm_import(this.raw_input_filename, 'eyelink', import, struct());
      this.pspm_input_filename = this.pspm_input_filename{1};
    end
  end
  methods(Test)
    function invalid_input(this)
      opt = struct();
      this.verifyWarning(@()pspm_pupil_correct_eyelink(52, opt), 'ID:invalid_input');
      this.verifyWarning(@()pspm_pupil_correct_eyelink('abc', opt), 'ID:invalid_input');
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.screen_size_px = [1920 1080];
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.screen_size_mm = [43.5 29.9];
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.mode = 'auto';
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.C_z = 5;
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.C_z = 495;
      this.verifyWarningFree(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt));
      opt.screen_size_px = 'aoe';
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.screen_size_px = 1;
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.screen_size_px = [1 2 3];
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.screen_size_px = [-1920 1080];
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.screen_size_px = [1920 1080];
      opt.screen_size_mm = 'aouet';
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.screen_size_mm = 1;
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.screen_size_mm = [1 2 3];
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.screen_size_mm = [-25 14];
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.screen_size_mm = [25 14];
      this.verifyWarningFree(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt));
      opt.mode = 'mixed';
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.mode = 'manual';
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.C_x = 5;
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.C_y = 5;
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.S_x = 5;
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.S_y = 5;
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.S_z = 5;
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.channel = 'gaze_x_l';
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.channel = 5;
      this.verifyWarning(@()pspm_pupil_correct_eyelink(this.pspm_input_filename, opt), 'ID:invalid_input');
    end
    function check_if_corrected_channel_is_saved(this)
      options.screen_size_px = [1920 1080];
      options.screen_size_mm = [43 25];
      options.mode = 'auto';
      options.C_z = 495;
      options.channel = 'pupil_l';
      [sts, out_channel] = pspm_pupil_correct_eyelink(this.pspm_input_filename, options);
      load(this.pspm_input_filename);
      this.verifyEqual(data{out_channel}.header.chantype, 'pupil_pp_l');
      ecg_chan_indices = find(cell2mat(cellfun(@(x) strcmp(x.header.chantype, 'pupil_l'), data, 'uni', false)));
      this.verifyEqual(numel(data{ecg_chan_indices(end)}.data), numel(data{out_channel}.data));
    end
  end
  methods(TestClassTeardown)
    function restore(this)
      delete(this.pspm_input_filename);
    end
  end
end
