options = struct();
options.max = 100;
options.baseline_jump = 1.2;
options.clipping_window_size = 100000;
options.missing_epochs_filename = 'test26Feb2024';
options.clipping_step_size = 40;
[sts, out] = pspm_scr_pp('/Users/teddy/Downloads/tpspm_REW2_acq_0005_sn02.mat', options);