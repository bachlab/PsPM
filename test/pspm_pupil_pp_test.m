classdef pspm_pupil_pp_test < pspm_testcase
  % ● Description
  % unittest class for the pspm_pupil_pp function
  % ● Authorship
  % (C) 2019 Eshref Yozdemir (University of Zurich)
  % Update 2021 Teddy Chao (WCHN, UCL)
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
      this.pspm_input_filename = pspm_import(...
        this.raw_input_filename, 'eyelink', import, struct());
      this.pspm_input_filename = this.pspm_input_filename{1};
    end
  end
  methods(Test)
    function invalid_input(this)
      this.verifyWarning(@()pspm_pupil_pp(52), 'ID:invalid_input');
      this.verifyWarning(@()pspm_pupil_pp('abc'), 'ID:nonexistent_file');
      opt.channel = 'pupil_x_l';
      this.verifyWarning(@()pspm_pupil_pp(...
        this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.channel = 'pupil_l';
      opt.channel_combine = 'gaze_y_l';
      this.verifyWarning(@()pspm_pupil_pp(...
        this.pspm_input_filename, opt), 'ID:invalid_input');
      opt.channel_combine = 'pupil_l';
      this.verifyWarning(@()pspm_pupil_pp(...
        this.pspm_input_filename, opt), 'ID:invalid_input');
    end
    function check_if_preprocessed_channel_is_saved(this)
      opt.channel = 'pupil_r';
      [~, out_chan] = pspm_pupil_pp(this.pspm_input_filename, opt);
      testdata = load(this.pspm_input_filename);
      this.verifyEqual(testdata.data{out_chan}.header.chantype,...
        'pupil_r');
    end
    function check_upsampling_rate(this)
      for freq = [500 1000 1500]
        opt.custom_settings.valid.interp_upsamplingFreq = freq;
        opt.channel = 'pupil_r';
        [~, out_chan] = pspm_pupil_pp(this.pspm_input_filename, opt);
        testdata = load(this.pspm_input_filename);
        pupil_chan_indices = find(...
          cell2mat(cellfun(@(x) strcmp(x.header.chantype, 'pupil_r'),...
          testdata.data, 'uni', false)));
        pupil_chan = pupil_chan_indices(end);
        sr = testdata.data{pupil_chan}.header.sr;
        upsampling_factor = freq / sr;
        this.verifyEqual(...
          numel(testdata.data{pupil_chan}.data) * upsampling_factor,...
          numel(testdata.data{out_chan}.data));
      end
    end
    % function check_channel_combining(this)
    %   opt.channel = 'pupil_r';
    %   opt.channel_combine = 'pupil_l';
    %   [~, out_chan] = pspm_pupil_pp(this.pspm_input_filename, opt);
    %   testdata = load(this.pspm_input_filename);
    %   this.verifyEqual(testdata.data{out_chan}.header.chantype, 'pupil_c');
    % end
    function check_segments(this)
      opt.channel = 'pupil_r';
      opt.segments{1}.start = 5;
      opt.segments{1}.end = 10;
      opt.segments{1}.name = 'seg1';
      opt.segments{2}.start = 25;
      opt.segments{2}.end = 27;
      opt.segments{2}.name = 'seg2';
      [~, out_chan] = pspm_pupil_pp(this.pspm_input_filename, opt);
      testdata = load(this.pspm_input_filename);

      this.verifyTrue(isfield(testdata.data{out_chan}.header, 'segments'));
      this.verifyEqual(testdata.data{out_chan}.header.segments{1}.name, 'seg1');
      this.verifyEqual(testdata.data{out_chan}.header.segments{2}.name, 'seg2');
    end
  end
  methods(TestClassTeardown)
    function restore(this)
      delete(this.pspm_input_filename);
    end
  end
end
