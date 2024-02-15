classdef pspm_gaze_pp_test < pspm_testcase
  % Definition
  % pspm_gaze_pp_test unittest classes for the pspm_gaze_pp function
  % PsPM TestEnvironment
  % (C) 2021 Teddy Chao (UCL)
  properties
    raw_input_fn = fullfile('ImportTestData', 'eyelink', 'S114_s2.asc');
    pspm_input_fn = '';
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
      this.pspm_input_fn = pspm_import(...
        this.raw_input_fn, 'eyelink', import, struct());
      this.pspm_input_fn = this.pspm_input_fn{1};
    end
  end
  methods(Test)
    function invalid_input(this)
      % the function checks if the input filename and options are valid
      % the input filename is only a number
      this.verifyWarning(@()pspm_gaze_pp(52), 'ID:invalid_input');
      % the input filename refers to a non-existing file
      this.verifyWarning(@()pspm_gaze_pp('abc'), 'ID:nonexistent_file');
      % the input filename is valid, but the channel referred through options is not existing
      opt.channel = 'gaze';
      this.verifyWarning(@()pspm_gaze_pp(this.pspm_input_fn, opt), 'ID:invalid_input');
      % the input filename is valid, but the two channels to combine are identical
      opt.channel = 'gaze_x_l';
      opt.channel_combine = 'pupil_x_l';
      this.verifyWarning(@()pspm_gaze_pp(this.pspm_input_fn, opt), 'ID:invalid_input');
      % the input filename is valid, but the two channels to combine are not both x or both y
      opt.channel_combine = 'gaze_y_l';
      this.verifyWarning(@()pspm_gaze_pp(this.pspm_input_fn, opt), 'ID:invalid_input');
    end
    function preprocessed_channel(this)
      % check if the channel name of the preprocessed file is correct
      opt.channel = 'gaze_x_r';
      [~, out_channel] = pspm_gaze_pp(this.pspm_input_fn, opt);
      testdata = load(this.pspm_input_fn);
      this.verifyEqual(testdata.data{out_channel}.header.chantype,'gaze_pp_x_r');
      opt.channel = 'gaze_x_l';
      [~, out_channel] = pspm_gaze_pp(this.pspm_input_fn, opt);
      testdata = load(this.pspm_input_fn);
      this.verifyEqual(testdata.data{out_channel}.header.chantype,'gaze_pp_x_l');
      opt.channel = 'gaze_y_r';
      [~, out_channel] = pspm_gaze_pp(this.pspm_input_fn, opt);
      testdata = load(this.pspm_input_fn);
      this.verifyEqual(testdata.data{out_channel}.header.chantype,'gaze_pp_y_r');
      opt.channel = 'gaze_y_l';
      [~, out_channel] = pspm_gaze_pp(this.pspm_input_fn, opt);
      testdata = load(this.pspm_input_fn);
      this.verifyEqual(testdata.data{out_channel}.header.chantype,'gaze_pp_y_l');
    end
    function upsampling_rate(this)
      % check if the upsampling rate is correct
      for freq = [500 1000 1500]
        opt.custom_settings.valid.interp_upsamplingFreq = freq;
        opt.channel = 'gaze_x_r';
        opt.valid_sample = 1;
        [~, out_channel] = pspm_gaze_pp(this.pspm_input_fn, opt);
        testdata = load(this.pspm_input_fn);
        pupil_chan_indices = find(...
          cell2mat(cellfun(@(x) strcmp(x.header.chantype, 'gaze_x_r'),...
          testdata.data, 'uni', false)));
        pupil_chan = pupil_chan_indices(end);
        sr = testdata.data{pupil_chan}.header.sr;
        upsampling_factor = freq / sr;
        this.verifyEqual(...
          numel(testdata.data{pupil_chan}.data) * upsampling_factor,...
          numel(testdata.data{out_channel}.data));
      end
    end
    function channel_combining(this)
      % check if the combined channel has the correct channel type name
      opt.channel = 'gaze_x_r';
      opt.channel_combine = 'gaze_x_l';
      [~, out_channel] = pspm_gaze_pp(this.pspm_input_fn, opt);
      testdata = load(this.pspm_input_fn);
      this.verifyEqual(testdata.data{out_channel}.header.chantype, 'gaze_pp_x_c');
      opt.channel = 'gaze_y_r';
      opt.channel_combine = 'gaze_y_l';
      [~, out_channel] = pspm_gaze_pp(this.pspm_input_fn, opt);
      testdata = load(this.pspm_input_fn);
      this.verifyEqual(testdata.data{out_channel}.header.chantype, 'gaze_pp_y_c');
    end
  end
  methods(TestClassTeardown)
    function restore(this)
      delete(this.pspm_input_fn);
    end
  end
end
