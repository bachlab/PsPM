classdef pspm_pupil_correct_test < pspm_testcase
  % ● Description
  % unittest class for the pspm_pupil_correct function
  % ● Authorship
  % (C) 2019 Eshref Yozdemir (University of Zurich)
  methods(Test)
    function invalid_input(this)
      
      pupil = 5:7;
      gaze_x = 1:3;
      gaze_y = 10:12;

      sr = 100; % 100Hz*10s = N
      data.infos.duration = 10; % s
      data.infos.source.best_eye = 'lr'; %for pspm_check_channel
 
      data.data = cell(3,1);
      data.data{1} = struct();
      data.data{1}.header = struct('chantype','pupil_l','sr',sr,'units','a.u.');
      data.data{1}.data   = pupil;
      data.data{2} = struct();
      data.data{2}.header = struct('chantype','gaze_x_l','sr',sr,'units','mm');
      data.data{2}.data   = gaze_x;
      data.data{3} = struct();
      data.data{3}.header = struct('chantype','gaze_y_l','sr',sr,'units','mm');
      data.data{3}.data   = gaze_y;

      opt.C_x = 1;
      opt.C_y = 1;
      opt.C_z = 1;
      opt.S_x = 1;
      opt.S_y = 1;
      this.verifyWarning(@()pspm_pupil_correct(data, opt), 'ID:invalid_input');
      opt.S_z = 'a';
      this.verifyWarning(@()pspm_pupil_correct(data, opt), 'ID:invalid_input');
      opt.S_z = 5;
      pupil = 'abc';
      this.verifyWarning(@()pspm_pupil_correct(data, opt), 'ID:invalid_input');
      pupil = 1:3;
      gaze_x = 'abc';
      this.verifyWarning(@()pspm_pupil_correct(data, opt), 'ID:invalid_input');
      gaze_x = 1:3;
      gaze_y = 'abc';
      this.verifyWarning(@()pspm_pupil_correct(data,  opt), 'ID:invalid_input');
      gaze_y = 1:3;
      pupil = 1:100;
      this.verifyWarning(@()pspm_pupil_correct(data,  opt), 'ID:invalid_input');
      pupil = 8:10;
      gaze_x = ones(10);
      this.verifyWarning(@()pspm_pupil_correct(data,  opt), 'ID:invalid_input');
    end
    function looking_directly_at_camera_doesnt_change_pupil(this)
      N = 1000;
      pupil = linspace(2, 9, N)';
      opt.C_x = 10;
      opt.C_y = 20;
      opt.C_z = 30;
      opt.S_x = 1;
      opt.S_y = 1;
      opt.S_z = 30;
      gaze_x = repmat(opt.C_x - opt.S_x, N,1);
      gaze_y = repmat(opt.S_y - opt.C_y, N,1);

      sr = 100; % 100Hz*10s = N
      data.infos.duration = 10; % s
      data.infos.source.best_eye = 'lr'; %for pspm_check_channel
 
      data.data = cell(3,1);
      data.data{1} = struct();
      data.data{1}.header = struct('chantype','pupil_l','sr',sr,'units','a.u.');
      data.data{1}.data   = pupil;
      data.data{2} = struct();
      data.data{2}.header = struct('chantype','gaze_x_l','sr',sr,'units','mm');
      data.data{2}.data   = gaze_x;
      data.data{3} = struct();
      data.data{3}.header = struct('chantype','gaze_y_l','sr',sr,'units','mm');
      data.data{3}.data   = gaze_y;

    
      [sts, pupil_corr] = pspm_pupil_correct(data, opt);
      assert(sts == 1);
      import matlab.unittest.constraints.IsEqualTo
      import matlab.unittest.constraints.RelativeTolerance
      this.verifyThat(pupil, IsEqualTo(pupil_corr, 'Within', RelativeTolerance(1e-10)));
    end
    function looking_closer_to_camera_results_in_smaller_correction(this)
      N = 1000;
      pupil = linspace(2, 9, N)';
      opt.C_x = 10;
      opt.C_y = 20;
      opt.C_z = 30;
      opt.S_x = 1;
      opt.S_y = 1;
      opt.S_z = 30;
      gaze_x = (repmat(opt.C_x - opt.S_x, 1, N) - 2)';
      gaze_y = (repmat(opt.S_y - opt.C_y, 1, N) + 2)';
      
      % infos
      sr = 100; % 100Hz*10s = N
      data.infos.duration = 10; % s
      data.infos.source.best_eye = 'lr'; %for pspm_check_channel
      % data
      data.data = cell(3,1);
      data.data{1} = struct();
      data.data{1}.header = struct('chantype','pupil_l','sr',sr,'units','a.u.');
      data.data{1}.data   = pupil;
      data.data{2} = struct();
      data.data{2}.header = struct('chantype','gaze_x_l','sr',sr,'units','mm');
      data.data{2}.data   = gaze_x;
      data.data{3} = struct();
      data.data{3}.header = struct('chantype','gaze_y_l','sr',sr,'units','mm');
      data.data{3}.data   = gaze_y;

      [sts, pupil_corr_close] = pspm_pupil_correct(data, opt);
      assert(sts == 1);
      % observed same pupil data when looking further from camera
      % Hence, original pupil must be larger.
      data.data{2}.data = repmat(opt.C_x - opt.S_x, 1, N) - 10; % gaze_x
      data.data{3}.data = repmat(opt.S_y - opt.C_y, 1, N) + 5; % gaze_y
      [sts, pupil_corr_far] = pspm_pupil_correct(data, opt);
      assert(sts == 1);
      this.verifyTrue(all(pupil_corr_far > pupil_corr_close));
    end
  end
end
