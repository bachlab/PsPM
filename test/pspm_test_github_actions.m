function pspm_test_github_actions(varargin)

% pspm_test_github_actions is a test suite for PsPM with GitHub Actions
% Variable
%   exit_code: indicating the result of testing, 0 if succeed, -1 if fail

% PsPM TestEnvironment for GitHub Actions
% (C) 2021 Dominik Bach (WCHN, UCL)
%          Linus Ruettimann (UZH)
%          Teddy Chao (WCHN, UCL)

%$ imports
import matlab.unittest.TestSuite;

quit_after_tests = false;
if nargin > 0
  quit_after_tests = varargin{1};
  assert(islogical(quit_after_tests));
end

%% Build suites
suite = [...
  TestSuite.fromClass(?pspm_align_channels_test), ...
  TestSuite.fromClass(?pspm_bf_data_test), ...
  TestSuite.fromClass(?pspm_bf_test), ...
  TestSuite.fromClass(?pspm_blink_saccade_filt_test), ...
  TestSuite.fromClass(?pspm_convert_gaze_distance_test), ...
  TestSuite.fromClass(?pspm_convert_unit_test), ...
  TestSuite.fromClass(?pspm_dcm_test), ...
  TestSuite.fromClass(?pspm_ecg2hb_amri_test), ...
  TestSuite.fromClass(?pspm_ecg2hb_test), ...
  TestSuite.fromClass(?pspm_extract_segments_test), ...
  TestSuite.fromClass(?pspm_find_channel_test), ...
  TestSuite.fromClass(?pspm_find_sounds_test), ...
  TestSuite.fromClass(?pspm_find_valid_fixations_test), ...
  TestSuite.fromClass(?pspm_get_timing_test), ...
  TestSuite.fromClass(?pspm_glm_test), ...
  TestSuite.fromClass(?pspm_import_test), ...
  TestSuite.fromClass(?pspm_interpolate_test), ...
  TestSuite.fromClass(?pspm_load_data_test), ...
  TestSuite.fromClass(?pspm_load1_test), ...
  TestSuite.fromClass(?pspm_path_test), ...
  TestSuite.fromClass(?pspm_pp_test), ...
  TestSuite.fromClass(?pspm_prepdata_test), ...
  TestSuite.fromClass(?pspm_process_illuminance_test), ...
  TestSuite.fromClass(?pspm_pulse_convert_test),...
  TestSuite.fromClass(?pspm_pupil_correct_eyelink_test), ...
  TestSuite.fromClass(?pspm_pupil_correct_test), ...
  TestSuite.fromClass(?pspm_pupil_pp_test), ...
  TestSuite.fromClass(?pspm_ren_test), ...
  TestSuite.fromClass(?pspm_resp_pp_test), ...
  TestSuite.fromClass(?pspm_scr_pp_test), ...
  TestSuite.fromClass(?pspm_split_sessions_test), ...
  TestSuite.fromClass(?pspm_trim_test), ...
  TestSuite.fromClass(?pspm_write_channel_test), ...
  TestSuite.fromClass(?set_blinks_saccades_to_nan_test), ...
  ];

%% Import suites
import_suite = [...
  TestSuite.fromClass(?import_eyelink_test), ...
  TestSuite.fromClass(?import_smi_test), ...
  TestSuite.fromClass(?import_viewpoint_test), ...
  TestSuite.fromClass(?pspm_get_acq_bioread_test), ...
  TestSuite.fromClass(?pspm_get_acq_test), ...
  TestSuite.fromClass(?pspm_get_acqmat_test), ...
  TestSuite.fromClass(?pspm_get_biograph_test), ...
  TestSuite.fromClass(?pspm_get_biosemi_test), ...
  TestSuite.fromClass(?pspm_get_biotrace_test), ...
  TestSuite.fromClass(?pspm_get_brainvis_test), ...
  TestSuite.fromClass(?pspm_get_edf_test), ...
  TestSuite.fromClass(?pspm_get_eyelink_test), ...
  TestSuite.fromClass(?pspm_get_labchartmat_ext_test), ...
  TestSuite.fromClass(?pspm_get_labchartmat_in_test), ...
  TestSuite.fromClass(?pspm_get_mat_test), ...
  TestSuite.fromClass(?pspm_get_obs_test), ...
  TestSuite.fromClass(?pspm_get_physlog_test), ...
  TestSuite.fromClass(?pspm_get_smi_test), ...
  TestSuite.fromClass(?pspm_get_spike_test), ...
  TestSuite.fromClass(?pspm_get_txt_test), ...
  TestSuite.fromClass(?pspm_get_vario_test), ...
  TestSuite.fromClass(?pspm_get_viewpoint_test), ...
  TestSuite.fromClass(?pspm_get_wdq_n_test), ...
  ];

%% Channel type suites
chantype_suite = [...
  TestSuite.fromClass(?pspm_get_ecg_test), ...
  TestSuite.fromClass(?pspm_get_sps_test), ...
  TestSuite.fromClass(?pspm_get_events_test), ...
  TestSuite.fromClass(?pspm_get_hb_test), ...
  TestSuite.fromClass(?pspm_get_hr_test), ...
  TestSuite.fromClass(?pspm_get_marker_test), ...
  TestSuite.fromClass(?pspm_get_pupil_test), ...
  TestSuite.fromClass(?pspm_get_resp_test), ...
  TestSuite.fromClass(?pspm_get_scr_test), ...
  ];

full_suite = [suite, import_suite, chantype_suite];

%% Run tests
[pth, ~, ~] = fileparts(which('pspm_test_github_actions.m'));
addpath(pth);
settings = [];
pspm_init;
settings.developmode = 1; % set to develop mode
stats = run(full_suite);
n_failed = sum([stats.Failed]);
success = n_failed == 0;

if success
  disp('pspm_test: All tests have passed!');
  fid = fopen('success.txt', 'wt');
  fprintf(fid, format_test_results(stats));
  fclose(fid);
else
  disp('pspm_test: Some tests have failed!');
  fid = fopen('failure.txt', 'wt');
  fprintf(fid, format_test_results(stats));
  fclose(fid);
end

if quit_after_tests
  exit_code = 1 - success;
  quit(exit_code);
end

end