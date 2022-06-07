classdef pspm_gaze_pp_test < pspm_testcase

  % DEFINITION
  % pspm_gaze_pp_test unittest classes for the pspm_gaze_pp function
  % PsPM TestEnvironment
  % (C) 2021 Teddy Chao (WCHN, UCL)
  % Supervised by Professor Dominik Bach (WCHN, UCL)

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
      options.overwrite = true;
      this.pspm_input_fn = pspm_import(...
        this.raw_input_fn, 'eyelink', import, options);
      this.pspm_input_fn = this.pspm_input_fn{1};
    end
  end

  methods(Test)
    function invalid_input(this)
      this.verifyWarning(@()pspm_gaze_pp(52), 'ID:invalid_input');
      this.verifyWarning(@()pspm_gaze_pp('abc'), 'ID:nonexistent_file');
      opt.channel = 'gaze';
      this.verifyWarning(@()pspm_gaze_pp(this.pspm_input_fn, opt), 'ID:invalid_channeltype');
      opt.channel = 'gaze_x_l';
      opt.channel_combine = 'pupil_x_l';
      this.verifyWarning(@()pspm_gaze_pp(this.pspm_input_fn, opt), 'ID:invalid_input');
      opt.channel_combine = 'gaze_l';
      this.verifyWarning(@()pspm_gaze_pp(this.pspm_input_fn, opt), 'ID:invalid_input');
    end

    function check_if_preprocessed_channel_is_saved(this)
      opt.channel = 'gaze_x_r';
      [~, out_channel] = pspm_gaze_pp(this.pspm_input_fn, opt);
      testdata = load(this.pspm_input_fn);
      this.verifyEqual(testdata.data{out_channel}.header.chantype,'gaze_pp_x_r');
      % opt.channel = 'gaze_y_r';
      % [~, out_channel] = pspm_gaze_pp(this.pspm_input_fn, opt);
      % testdata = load(this.pspm_input_fn);
      % this.verifyEqual(testdata.data{out_channel}.header.chantype,'gaze_pp_y_r');
    end

    function check_upsampling_rate(this)
      for freq = [500 1000 1500]
        opt.custom_settings.valid.interp_upsamplingFreq = freq;
        opt.channel = 'gaze_x_r';
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

    function check_channel_combining(this)
      opt.channel = 'gaze_x_r';
      opt.channel_combine = 'gaze_x_l';
      % [~, out_channel] = pspm_gaze_pp(this.pspm_input_fn, opt);
      % testdata = load(this.pspm_input_fn);
      % this.verifyEqual(testdata.data{out_channel}.header.chantype, 'gaze_pp_x_c');
      opt.channel = 'gaze_y_r';
      opt.channel_combine = 'gaze_y_l';
      % [~, out_channel] = pspm_gaze_pp(this.pspm_input_fn, opt);
      % testdata = load(this.pspm_input_fn);
      % this.verifyEqual(testdata.data{out_channel}.header.chantype, 'gaze_pp_y_c');
    end

    function check_segments(this)
      opt.channel = 'gaze_r';
      opt.segments{1}.start = 5;
      opt.segments{1}.end = 10;
      opt.segments{1}.name = 'seg1';
      opt.segments{2}.start = 25;
      opt.segments{2}.end = 27;
      opt.segments{2}.name = 'seg2';
      % [~, out_channel] = pspm_gaze_pp(this.pspm_input_fn, opt);
      % testdata = load(this.pspm_input_fn);
      % this.verifyTrue(isfield(testdata.data{out_channel}.header, 'segments'));
      % this.verifyEqual(testdata.data{out_channel}.header.segments{1}.name, 'seg1');
      % this.verifyEqual(testdata.data{out_channel}.header.segments{2}.name, 'seg2');
    end
  end

  methods(TestClassTeardown)
    function restore(this)
      delete(this.pspm_input_fn);
    end
  end
end
