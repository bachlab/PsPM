classdef import_eyelink_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for import_eyelink, PsPM TestEnvironment
  % ● Authorship
  % (C) 2019 Eshref Yozdemir (University of Zurich)
  properties
    funcpath = pspm_path('Import', 'eyelink');
    files = {['ImportTestData' filesep 'eyelink' filesep 'S114_s2_short.asc'],...
      ['ImportTestData' filesep 'eyelink' filesep 'example_data.asc'],...
      ['ImportTestData' filesep 'eyelink' filesep 'u_sc4b31_short.asc']};
  end
  methods
    function test_import_eyelink_on_file(this, filepath)
      import matlab.unittest.constraints.IsEqualTo
      import matlab.unittest.constraints.RelativeTolerance
      % read eyelink file using import eyelink
      addpath(this.funcpath);
      data = import_eyelink(filepath);
      rmpath(this.funcpath);
      % manually read the file and compare the results
      fid = fopen(filepath);
      sn = 0;
      tline = fgetl(fid);
      eyesObserved = '';
      pupil_l_idx = -1;
      pupil_r_idx = -1;
      gaze_x_l_idx = -1;
      gaze_y_l_idx = -1;
      gaze_x_r_idx = -1;
      gaze_y_r_idx = -1;
      blink_l_idx = -1;
      blink_r_idx = -1;
      sacc_l_idx = -1;
      sacc_r_idx = -1;
      blink_l = false;
      blink_r = false;
      sacc_l = false;
      sacc_r = false;
      while ischar(tline)
        parts = split(tline);
        is_dataline = ~isempty(str2num(parts{1}));
        is_msgline = strcmp(parts{1}, 'MSG') && (contains(tline, 'CS') ...
        || contains(tline, 'US') || contains(tline, 'TS'));
        if strncmp(tline, 'SBLINK L', numel('SBLINK L'))
          blink_l = true;
        elseif strncmp(tline, 'SBLINK R', numel('SBLINK R'))
          blink_r = true;
        elseif strncmp(tline, 'EBLINK L', numel('EBLINK L'))
          blink_l = false;
        elseif strncmp(tline, 'EBLINK R', numel('EBLINK R'))
          blink_r = false;
        elseif strncmp(tline, 'SSACC L', numel('SSACC L'))
          sacc_l = true;
        elseif strncmp(tline, 'SSACC R', numel('SSACC R'))
          sacc_r = true;
        elseif strncmp(tline, 'ESACC L', numel('ESACC L'))
          sacc_l = false;
        elseif strncmp(tline, 'ESACC R', numel('ESACC R'))
          sacc_r = false;
        end
        if contains(tline, 'RECCFG')
          sn = sn + 1;
          sample_idx = 1;
          msg_idx = 1;
          msgtimes = data{sn}.markers;
          this.verifyEqual(data{sn}.sampleRate, to_num(parts{5}));
          this.verifyEqual(lower(data{sn}.eyesObserved), lower(parts{8}));
          eyesObserved = parts{8};
          if strcmpi(eyesObserved, 'l')
            pupil_l_idx = 1;
            gaze_x_l_idx = 2;
            gaze_y_l_idx = 3;
            blink_l_idx = 4;
            sacc_l_idx = 5;
          elseif strcmpi(eyesObserved, 'r')
            pupil_r_idx = 1;
            gaze_x_r_idx = 2;
            gaze_y_r_idx = 3;
            blink_r_idx = 4;
            sacc_r_idx = 5;
          else
            pupil_l_idx = 1;
            pupil_r_idx = 2;
            gaze_x_l_idx = 3;
            gaze_y_l_idx = 4;
            gaze_x_r_idx = 5;
            gaze_y_r_idx = 6;
            blink_l_idx = 7;
            blink_r_idx = 8;
            sacc_l_idx = 9;
            sacc_r_idx = 10;
          end
        elseif contains(tline, 'GAZE_COORDS')
          this.verifyEqual(data{sn}.gaze_coords.xmin, to_num(parts{4}));
          this.verifyEqual(data{sn}.gaze_coords.ymin, to_num(parts{5}));
          this.verifyEqual(data{sn}.gaze_coords.xmax, to_num(parts{6}));
          this.verifyEqual(data{sn}.gaze_coords.ymax, to_num(parts{7}));
        elseif contains(tline, 'ELCL_PROC')
          this.verifyEqual(lower(data{sn}.elcl_proc), lower(parts{4}));
        elseif is_dataline
          % check if the values in the current line are in the expected locations
          if pupil_l_idx ~= -1
            this.verifyEqual(to_num(parts{4}), data{sn}.channels(sample_idx, pupil_l_idx));
          end
          if gaze_x_l_idx ~= -1
            this.verifyEqual(to_num(parts{2}), data{sn}.channels(sample_idx, gaze_x_l_idx));
          end
          if gaze_y_l_idx ~= -1
            this.verifyEqual(to_num(parts{3}), data{sn}.channels(sample_idx, gaze_y_l_idx));
          end
          if pupil_r_idx ~= -1
            if pupil_l_idx ~= -1
              this.verifyEqual(to_num(parts{7}), data{sn}.channels(sample_idx, pupil_r_idx));
            else
              this.verifyEqual(to_num(parts{4}), data{sn}.channels(sample_idx, pupil_r_idx));
            end
          end
          if gaze_x_r_idx ~= -1
            if gaze_x_l_idx ~= -1
              this.verifyEqual(to_num(parts{5}), data{sn}.channels(sample_idx, gaze_x_r_idx));
            else
              this.verifyEqual(to_num(parts{2}), data{sn}.channels(sample_idx, gaze_x_r_idx));
            end
          end
          if gaze_y_r_idx ~= -1
            if gaze_y_l_idx ~= -1
              this.verifyEqual(to_num(parts{6}), data{sn}.channels(sample_idx, gaze_y_r_idx));
            else
              this.verifyEqual(to_num(parts{3}), data{sn}.channels(sample_idx, gaze_y_r_idx));
            end
          end
          if blink_l_idx ~= -1
            this.verifyEqual(data{sn}.channels(sample_idx, blink_l_idx), double(blink_l));
          end
          if blink_r_idx ~= -1
            this.verifyEqual(data{sn}.channels(sample_idx, blink_r_idx), double(blink_r));
          end
          if sacc_l_idx ~= -1
            this.verifyEqual(data{sn}.channels(sample_idx, sacc_l_idx), double(sacc_l));
          end
          if sacc_r_idx ~= -1
            this.verifyEqual(data{sn}.channels(sample_idx, sacc_r_idx), double(sacc_r));
          end
          sample_idx = sample_idx + 1;
        elseif is_msgline
          % check if current message and its time is correct
          message = parts(3:end);
          message = message{1};
          this.verifyEqual(message, data{sn}.markerinfo.name{msg_idx});
          this.verifyEqual(to_num(parts{2}), msgtimes(msg_idx));
          msg_idx = msg_idx + 1;
        end
        tline = fgetl(fid);
      end
      fclose(fid);
    end
  end
  methods (Test)
    function test_import_eyelink(this)
      for i = 1:numel(this.files)
        this.test_import_eyelink_on_file(this.files{i});
      end
    end
  end
end
function a = to_num(str)
a = str2num(str);
if isempty(a)
  a = NaN;
end
end
