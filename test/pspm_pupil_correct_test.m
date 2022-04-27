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
      opt.C_x = 1;
      opt.C_y = 1;
      opt.C_z = 1;
      opt.S_x = 1;
      opt.S_y = 1;
      this.verifyWarning(@()pspm_pupil_correct(pupil, gaze_x, gaze_y, opt), 'ID:invalid_input');
      opt.S_z = 'a';
      this.verifyWarning(@()pspm_pupil_correct(pupil, gaze_x, gaze_y, opt), 'ID:invalid_input');
      opt.S_z = 5;
      pupil = 'abc';
      this.verifyWarning(@()pspm_pupil_correct(pupil, gaze_x, gaze_y, opt), 'ID:invalid_input');
      pupil = 1:3;
      gaze_x = 'abc';
      this.verifyWarning(@()pspm_pupil_correct(pupil, gaze_x, gaze_y, opt), 'ID:invalid_input');
      gaze_x = 1:3;
      gaze_y = 'abc';
      this.verifyWarning(@()pspm_pupil_correct(pupil, gaze_x, gaze_y, opt), 'ID:invalid_input');
      gaze_y = 1:3;
      pupil = 1:100;
      this.verifyWarning(@()pspm_pupil_correct(pupil, gaze_x, gaze_y, opt), 'ID:invalid_input');
      pupil = 8:10;
      gaze_x = ones(10);
      this.verifyWarning(@()pspm_pupil_correct(pupil, gaze_x, gaze_y, opt), 'ID:invalid_input');
    end
    function looking_directly_at_camera_doesnt_change_pupil(this)
      N = 1000;
      pupil = linspace(2, 9, N);
      opt.C_x = 10;
      opt.C_y = 20;
      opt.C_z = 30;
      opt.S_x = 1;
      opt.S_y = 1;
      opt.S_z = 30;
      gaze_x = repmat(opt.C_x - opt.S_x, 1, N);
      gaze_y = repmat(opt.S_y - opt.C_y, 1, N);
      [sts, pupil_corr] = pspm_pupil_correct(pupil, gaze_x, gaze_y, opt);
      assert(sts == 1);
      import matlab.unittest.constraints.IsEqualTo
      import matlab.unittest.constraints.RelativeTolerance
      this.verifyThat(pupil, IsEqualTo(pupil_corr, 'Within', RelativeTolerance(1e-10)));
    end
    function looking_closer_to_camera_results_in_smaller_correction(this)
      N = 1000;
      pupil = linspace(2, 9, N);
      opt.C_x = 10;
      opt.C_y = 20;
      opt.C_z = 30;
      opt.S_x = 1;
      opt.S_y = 1;
      opt.S_z = 30;
      gaze_x = repmat(opt.C_x - opt.S_x, 1, N) - 2;
      gaze_y = repmat(opt.S_y - opt.C_y, 1, N) + 2;
      [sts, pupil_corr_close] = pspm_pupil_correct(pupil, gaze_x, gaze_y, opt);
      assert(sts == 1);
      % observed same pupil data when looking further from camera
      % Hence, original pupil must be larger.
      gaze_x = repmat(opt.C_x - opt.S_x, 1, N) - 10;
      gaze_y = repmat(opt.S_y - opt.C_y, 1, N) + 5;
      [sts, pupil_corr_far] = pspm_pupil_correct(pupil, gaze_x, gaze_y, opt);
      assert(sts == 1);
      this.verifyTrue(all(pupil_corr_far > pupil_corr_close));
    end
  end
end
