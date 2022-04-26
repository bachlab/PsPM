classdef pspm_get_viewpoint_test < pspm_get_superclass
  % PSPM_GET_VIEWPOINT_TEST
  % unittest class for the pspm_get_viewpoint function
  % (C) 2019 Eshref Yozdemir (University of Zurich)
  properties
    fhandle = @pspm_get_viewpoint;
    testcases;
    files = {...
      fullfile('ImportTestData', 'viewpoint', 'viewpoint_test_data.txt'),...
      fullfile('ImportTestData', 'viewpoint', 'viewpoint_test_data_with_events.txt')...
      };
  end
  methods
    function define_testcases(this)
      for i = 1:numel(this.files)
        this.testcases{i}.pth = this.files{i};
        this.testcases{i}.import = {};
        this.testcases{i}.import{end + 1} = struct('type', 'pupil_l');
        this.testcases{i}.import{end + 1} = struct('type', 'pupil_r');
        this.testcases{i}.import{end + 1} = struct('type', 'gaze_x_l');
        this.testcases{i}.import{end + 1} = struct('type', 'gaze_y_l');
        this.testcases{i}.import{end + 1} = struct('type', 'gaze_x_r');
        this.testcases{i}.import{end + 1} = struct('type', 'gaze_y_r');
        this.testcases{i}.import{end + 1} = struct('type', 'marker');
        this.testcases{i}.import{end + 1} = struct('type', 'blink_l');
        this.testcases{i}.import{end + 1} = struct('type', 'blink_r');
        this.testcases{i}.import{end + 1} = struct('type', 'saccade_l');
        this.testcases{i}.import{end + 1} = struct('type', 'saccade_r');
      end
    end
  end
  methods (Test)
    function invalid_input(this)
      import{1}.type = 'pupil_l';
      this.verifyWarning(@()pspm_get_viewpoint(12, import), 'ID:invalid_input');
      this.verifyWarning(@()pspm_get_viewpoint({}, import), 'ID:invalid_input');
      this.verifyWarning(@()pspm_get_viewpoint({'a'}, import), 'ID:invalid_input');
      import{1}.type = 'aoseuth';
      this.verifyWarning(@()pspm_get_viewpoint('a', import), 'ID:channel_not_contained_in_file');
      import{1}.type = 'custom';
      this.verifyWarning(@()pspm_get_viewpoint('a', import), 'ID:invalid_input');
      import{1}.channel = -1;
      this.verifyWarning(@()pspm_get_viewpoint('a', import), 'ID:invalid_input');
      import{1}.channel = 1;
      import{1}.target_unit = 'kilometers';
      this.verifyWarning(@()pspm_get_viewpoint('a', import), 'ID:invalid_input');
    end
    function test_milimeter_gaze(this)
      import{1}.type = 'gaze_x_l';
      import{2}.type = 'gaze_y_l';
      for fn = this.files
        [sts, data, sourceinfo] = pspm_get_viewpoint(fn{1}, import);
        assert(sts == 1);
        this.verifyEqual(data{1}.units, 'mm');
        this.verifyEqual(data{2}.units, 'mm');
      end
    end
    function test_converted_gaze(this)
      import{1}.type = 'gaze_x_l';
      import{1}.target_unit = 'inches';
      import{2}.type = 'gaze_y_l';
      import{2}.target_unit = 'inches';
      for fn = this.files
        [sts, data, sourceinfo] = pspm_get_viewpoint(fn{1}, import);
        assert(sts == 1);
        this.verifyEqual(data{1}.units, 'inches');
        this.verifyEqual(data{2}.units, 'inches');
      end
    end
    function test_blinks_saccades_are_NaN(this)
      import{1}.type = 'gaze_x_l';
      import{1}.target_unit = 'inches';
      import{2}.type = 'gaze_y_l';
      import{2}.target_unit = 'inches';
      import{3}.type = 'pupil_l';
      import{4}.type = 'blink_l';
      import{5}.type = 'saccade_l';
      for fn = this.files
        [sts, data, sourceinfo] = pspm_get_viewpoint(fn{1}, import);
        assert(sts == 1);
        for i = 4:5
          mask = data{i}.data;
          if ~any(isnan(mask))
            mask = logical(mask);
            for j = 1:3
              this.verifyTrue(all(isnan(data{j}.data(mask))));
            end
          end
        end
      end
    end
  end
end