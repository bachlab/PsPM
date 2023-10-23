options = struct();
options.max = 100;
options.missing_epochs_filename = 'output_filename';
[sts, out] = pspm_scr_pp('tpspm_REW2_acq_0005_sn02.mat', options);