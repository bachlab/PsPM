classdef pspm_get_smi_test < pspm_get_superclass
  % ● Description
  % unittest class for the pspm_get_smi function
  % ● Authorship
  % (C) 2019 Eshref Yozdemir (University of Zurich)
  properties
    fhandle = @pspm_get_smi;
    testcases;
    sample_file = fullfile('ImportTestData', 'smi', 'smi_data_1.txt');
    event_file = fullfile('ImportTestData', 'smi', 'smi_data_1_events.txt');
  end
  methods
    function define_testcases(this)
      % testcase 1
      this.testcases{1}.pth = {this.sample_file, this.event_file};
      this.testcases{1}.import = {};
      this.testcases{1}.import{end + 1} = struct('type', 'pupil_l');
      this.testcases{1}.import{end + 1} = struct('type', 'pupil_r');
      this.testcases{1}.import{end + 1} = struct('type', 'gaze_x_l');
      this.testcases{1}.import{end + 1} = struct('type', 'gaze_y_l');
      this.testcases{1}.import{end + 1} = struct('type', 'gaze_x_r');
      this.testcases{1}.import{end + 1} = struct('type', 'gaze_y_r');
      this.testcases{1}.import{end + 1} = struct('type', 'marker');
      this.testcases{1}.import{end + 1} = struct('type', 'blink_l');
      this.testcases{1}.import{end + 1} = struct('type', 'blink_r');
      this.testcases{1}.import{end + 1} = struct('type', 'saccade_l');
      this.testcases{1}.import{end + 1} = struct('type', 'saccade_r');
      % testcase 2
      this.testcases{2}.pth = this.sample_file;
      this.testcases{2}.import = {};
      this.testcases{2}.import{end + 1} = struct('type', 'pupil_l');
      this.testcases{2}.import{end + 1} = struct('type', 'pupil_r');
      this.testcases{2}.import{end + 1} = struct('type', 'gaze_x_l');
      this.testcases{2}.import{end + 1} = struct('type', 'gaze_y_l');
      this.testcases{2}.import{end + 1} = struct('type', 'gaze_x_r');
      this.testcases{2}.import{end + 1} = struct('type', 'gaze_y_r');
      this.testcases{2}.import{end + 1} = struct('type', 'marker');
    end
  end
  methods (Test)
    function invalid_input(this)
      import{1}.type = 'pupil_l';
      this.verifyWarning(@()pspm_get_smi(12, import), 'ID:invalid_input');
      this.verifyWarning(@()pspm_get_smi({}, import), 'ID:invalid_input');
      this.verifyWarning(@()pspm_get_smi({'a', 'b', 'c'}, import), 'ID:invalid_input');
      import{1}.type = 'aoseuth';
      this.verifyWarning(@()pspm_get_smi({'a', 'b'}, import), 'ID:channel_not_contained_in_file');
      import{1}.type = 'custom';
      this.verifyWarning(@()pspm_get_smi({'a', 'b'}, import), 'ID:invalid_input');
      import{1}.channel = -1;
      this.verifyWarning(@()pspm_get_smi({'a', 'b'}, import), 'ID:invalid_input');
      import{1}.channel = 1;
      import{1}.stimulus_resolution = [];
      this.verifyWarning(@()pspm_get_smi({'a', 'b'}, import), 'ID:invalid_input');
      import{1}.stimulus_resolution = [5];
      this.verifyWarning(@()pspm_get_smi({'a', 'b'}, import), 'ID:invalid_input');
      import{1}.stimulus_resolution = [5 10 15];
      this.verifyWarning(@()pspm_get_smi({'a', 'b'}, import), 'ID:invalid_input');
      import{1}.stimulus_resolution = {'a', 'b'};
      this.verifyWarning(@()pspm_get_smi({'a', 'b'}, import), 'ID:invalid_input');
      import{1}.stimulus_resolution = [1920 1080];
      import{1}.target_unit = 'kilometers';
      this.verifyWarning(@()pspm_get_smi({'a', 'b'}, import), 'ID:invalid_input');
    end
    function test_milimeter_pupil(this)
      import{1}.type = 'pupil_l';
      import{2}.type = 'pupil_r';
      [sts, data, sourceinfo] = pspm_get_smi(this.sample_file, import);
      this.verifyEqual(data{1}.units, 'mm');
      this.verifyEqual(data{2}.units, 'mm');
      [sts, data, sourceinfo] = pspm_get_smi({this.sample_file, this.event_file}, import);
      this.verifyEqual(data{1}.units, 'mm');
      this.verifyEqual(data{2}.units, 'mm');
    end
    function test_converted_pupil(this)
      import{1}.type = 'gaze_x_l';
      import{1}.stimulus_resolution = [1920 1080];
      import{1}.target_unit = 'inches';
      import{2}.type = 'gaze_x_r';
      import{2}.target_unit = 'inches';
      import{2}.stimulus_resolution = [1920 1080];
      [sts, data, sourceinfo] = pspm_get_smi(this.sample_file, import);
      this.verifyEqual(data{1}.units, 'inches');
      this.verifyEqual(data{2}.units, 'inches');
      [sts, data, sourceinfo] = pspm_get_smi({this.sample_file, this.event_file}, import);
      this.verifyEqual(data{1}.units, 'inches');
      this.verifyEqual(data{2}.units, 'inches');
    end
    function test_stimulus_resolution_converts_gaze(this)
      import{1}.type = 'gaze_x_l';
      import{2}.type = 'gaze_x_r';
      import{3}.type = 'gaze_y_l';
      import{4}.type = 'gaze_y_r';
      [sts, data, sourceinfo] = pspm_get_smi(this.sample_file, import);
      this.verifyEqual(data{1}.units, 'pixel');
      this.verifyEqual(data{2}.units, 'pixel');
      this.verifyEqual(data{3}.units, 'pixel');
      this.verifyEqual(data{4}.units, 'pixel');
      import{1}.stimulus_resolution = [1920 1080];
      import{2}.stimulus_resolution = [1920 1080];
      import{3}.stimulus_resolution = [1920 1080];
      import{4}.stimulus_resolution = [1920 1080];
      [sts, data, sourceinfo] = pspm_get_smi({this.sample_file, this.event_file}, import);
      this.verifyEqual(data{1}.units, 'mm');
      this.verifyEqual(data{2}.units, 'mm');
      this.verifyEqual(data{3}.units, 'mm');
      this.verifyEqual(data{4}.units, 'mm');
    end
    function test_blinks_saccades_are_NaN(this)
      import{1}.type = 'gaze_x_l';
      import{2}.type = 'gaze_y_r';
      import{3}.type = 'blink_l';
      import{4}.type = 'saccade_l';
      import{5}.type = 'blink_r';
      import{6}.type = 'saccade_r';
      indices = {{{3, 4}, 1}, {{5, 6}, 2}};
      [sts, data, sourceinfo] = pspm_get_smi({this.sample_file, this.event_file}, import);
      assert(sts == 1);
      for i = 1:numel(indices)
        testindices = indices{i};
        for j = testindices{1}
          mask = data{j{1}}.data;
          if ~any(isnan(mask))
            mask = logical(mask);
            this.verifyTrue(all(isnan(data{testindices{2}}.data(mask))));
          end
        end
      end
    end
  end
end
