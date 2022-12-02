classdef pspm_get_eyelink_test < pspm_get_superclass
  % ● Description
  % unittest class for the pspm_get_eyelink function
  % PsPM TestEnvironment
  % ● Authorship
  % (C) 2014 Tobias Moser (University of Zurich)
  properties
    fhandle = @pspm_get_eyelink
    testcases;
    files = {...
      fullfile('ImportTestData', 'eyelink', 'S114_s2.asc'),...
      fullfile('ImportTestData', 'eyelink', 'u_sc4b31.asc')...
      };
  end
  methods
    function define_testcases(this)
      % testcase 1
      this.testcases{1}.pth = 'ImportTestData/eyelink/S114_s2.asc';
      this.testcases{1}.import{1} = struct('type', 'pupil_l', 'channel', 1); % pupil L
      this.testcases{1}.import{2} = struct('type', 'pupil_r', 'channel', 2); % pupil R
      % if 0 is specified as channel -> use default value
      this.testcases{1}.import{3} = struct('type', 'marker', 'channel', 0); % marker
      this.testcases{1}.import{4} = struct('type', 'gaze_x_l', 'channel', 3); % x l
      this.testcases{1}.import{5} = struct('type', 'gaze_y_l', 'channel', 4); % y l
      this.testcases{1}.import{6} = struct('type', 'gaze_x_r', 'channel', 5); % x r
      this.testcases{1}.import{7} = struct('type', 'gaze_y_r', 'channel', 6); % y r
      this.testcases{1}.import{8} = struct('type', 'blink_l', 'channel', 7); % blink l
      this.testcases{1}.import{9} = struct('type', 'blink_r', 'channel', 8); % blink r
      this.testcases{1}.import{10} = struct('type', 'saccade_l', 'channel', 9); % saccade l
      this.testcases{1}.import{11} = struct('type', 'saccade_r', 'channel', 10); % saccade r
    end
    % function determines import values and channel types
    function [import_struct,channel_types] = set_import_values(this)
      % if 0 is specified as channel -> use default value
      import_struct{1} =  struct('type', 'pupil_l', 'channel', 1); % pupil L
      import_struct{2} =  struct('type', 'pupil_r', 'channel', 2); % pupil R
      import_struct{3} =  struct('type', 'gaze_x_l', 'channel', 3); % x l
      import_struct{4} =  struct('type', 'gaze_y_l', 'channel', 4); % y l
      import_struct{5} =  struct('type', 'gaze_x_r', 'channel', 5); % x r
      import_struct{6} =  struct('type', 'gaze_y_r', 'channel', 6); % y r
      import_struct{7} =  struct('type', 'blink_l', 'channel', 7); % blink l
      import_struct{8} =  struct('type', 'blink_r', 'channel', 8); % blink r
      import_struct{9} =  struct('type', 'saccade_l', 'channel', 9); % saccade l
      import_struct{10} = struct('type', 'saccade_r', 'channel', 10); % saccade r
      import_struct{11} = struct('type', 'marker', 'channel', 0); % marker
      % channel types
      channel_types{1} = 'pupil';
      channel_types{2} = 'pupil';
      channel_types{3} = 'pixel';
      channel_types{4} = 'pixel';
      channel_types{5} = 'pixel';
      channel_types{6} = 'pixel';
      channel_types{7} = 'blink';
      channel_types{8} = 'blink';
      channel_types{9} = 'saccade';
      channel_types{10} = 'saccade';
    end
    function verify_basic_data_structure(this, data, sourceinfo, channel_types)
      this.verifyMatches(sourceinfo.time,...
        '^\d{2}:\d{2}:\d{2}$',...
        'The specified sourceinfo time format does not fit into the expected pattern.');
      this.verifyMatches(sourceinfo.date,...
        '^\d{2}.\d{2}.\d{4}$',...
        'The specified sourceinfo date format does not fit into the expected pattern.');
      for i = 1:length(channel_types)
        % all the specified channels should be numerical
        this.verifyThat(data{i}.data, matlab.unittest.constraints.IsReal, 'no real');
        switch channel_types{i}
          case 'pupil'
            this.verifyMatches(lower(data{i}.units),...
              '^arbitrary (area|diameter) units$', 'The pupil unit is not within the valid values.');
          case 'pupil_mm'
            this.verifyMatches(lower(data{i}.units),...
              '^mm$', 'The pupil unit is not mm.');
          case 'position'
            this.verifyMatches(lower(data{i}.units),...
              '^(pixel)$', 'The position unit is not within the valid values.');
          case 'blink'
            this.verifyMatches(lower(data{i}.units),...
              '^(blink)$', 'The blink unit is not within the valid values.');
          case 'saccade'
            this.verifyMatches(lower(data{i}.units),...
              '^(saccade)$', 'The saccade unit is not within the valid values.');
        end
      end
    end
  end
  methods (Test)
    function test_multi_session(this)
      pth = 'ImportTestData/eyelink/PCF24_short.asc';
      [import,channel_types] = this.set_import_values();
      [~, data, sourceinfo] = pspm_get_eyelink(pth, import);
      this.verify_basic_data_structure(data,sourceinfo, channel_types);
    end
    function test_two_eyes(this)
      pth = 'ImportTestData/eyelink/S114_s2.asc';
      [import,channel_types] = this.set_import_values();
      [~, data, sourceinfo] = pspm_get_eyelink(pth, import);
      this.verify_basic_data_structure(data,sourceinfo, channel_types);
    end
    function test_one_eye(this)
      pth = 'ImportTestData/eyelink/u_sc4b31.asc';
      % if 0 is specified as channel -> use default value
      import{1} = struct('type', 'marker', 'channel', 0); % marker
      import{1} = struct('type', 'pupil_r', 'channel', 1); % pupil
      import{2} = struct('type', 'gaze_x_r', 'channel', 2); % x
      import{3} = struct('type', 'gaze_y_r', 'channel', 3); % y
      import{4} = struct('type', 'blink_r', 'channel', 4); % blink
      import{5} = struct('type', 'saccade_r', 'channel', 5); % saccade
      % channel types
      channel_types{1} = 'pupil';
      channel_types{2} = 'pixel';
      channel_types{3} = 'pixel';
      channel_types{4} = 'blink';
      channel_types{5} = 'saccade';
      [~, data, sourceinfo] = pspm_get_eyelink(pth, import);
      this.verify_basic_data_structure(data, sourceinfo, channel_types);
    end
    function test_track_dist(this)
      pth = 'ImportTestData/eyelink/S114_s2.asc';
      [import,channel_types] = this.set_import_values();
      %change default setting from set_import_values
      import{1} = struct('type', 'pupil_l', ...
        'channel', 1, 'eyelink_trackdist', 700, ...
        'distance_unit', 'mm'); % pupil L
      import{2} = struct('type', 'pupil_r', ...,
        'channel', 2, 'eyelink_trackdist', 700, ...
        'distance_unit', 'mm'); % pupil R
      % change default setting from set_import_values
      channel_types{1} = 'pupil_mm';
      channel_types{2} = 'pupil_mm';
      [~, data, sourceinfo] = pspm_get_eyelink(pth, import);
      this.verify_basic_data_structure(data,sourceinfo, channel_types);
    end
    function invalid_datafile(this)
      fn = 'ImportTestData/eyelink/S114_s2.asc';
      import{1} = struct('type', 'custom'   , 'channel', 21);
      import{2} = struct('type', 'marker', 'channel', 20);
      import = this.assign_channeltype_number(import);
      this.verifyWarning(@()pspm_get_eyelink(fn, import),...
        'ID:channel_not_contained_in_file');
      import{1} = struct('type', 'scr'   , 'channel', 21);
      import{2} = struct('type', 'marker', 'channel', 20);
      import = this.assign_channeltype_number(import);
      this.verifyWarning(@()pspm_get_eyelink(fn, import),...
        'ID:channel_not_contained_in_file');
    end
    function test_blinks_saccades_are_NaN(this)
      import{1}.type = 'gaze_x_l';
      import{2}.type = 'gaze_y_r';
      import{3}.type = 'blink_l';
      import{4}.type = 'saccade_l';
      import{5}.type = 'blink_r';
      import{6}.type = 'saccade_r';
      indices = {{{3, 4}, 1}, {{5, 6}, 2}};
      for fn = this.files
        [sts, data, ~] = pspm_get_eyelink(fn{1}, import);
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
end