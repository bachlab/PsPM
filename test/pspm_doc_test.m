classdef pspm_doc_test < matlab.unittest.TestCase
  % ● Description
  %   unittest class for the pspm_doc function
  % ● History
  %   2024 by Teddy
  properties(Constant)
    list_func = {'pspm_align_channels',...
                 'pspm_bf_data',...
                 'pspm_check_data',...
                 'pspm_cfg_run_gaze_convert',...
                 'pspm_combine_markerchannels',...
                 'pspm_convert_ppg2hb',...
                 'pspm_dcm',...
                 'pspm_denoise_spike',...
                 'pspm_display',...
                 'pspm_downsample',...
                 'pspm_ecg_editor',...
                 'pspm_emg_pp',...
                 'pspm_epochs2logical',...
                 'pspm_export',...
                 'pspm_extract_segments',...
                 'pspm_eye',...
                 'pspm_find_eye',...
                 'pspm_find_valid_fixations',...
                 'pspm_gaze_pp',...
                 'pspm_get_labchart',...
                 'pspm_get_timing',...
                 'pspm_glm',...
                 'pspm_import',...
                 'pspm_jobman',...
                 'pspm_merge',...
                 'pspm_pupil_pp',...
                 'pspm_pupil_pp_options',...
                 'pspm_process_illuminance',...
                 'pspm_scr_pp',...
                 'pspm_write_channel'}
  end
  methods (Test)
    function valid_input(this)
      for i = 1:length(this.list_func)
        this.verifyEqual(pspm_doc(this.list_func{i}), 1);
        this.verifyEqual(isfile([this.list_func{i},'.md']), true);
        delete([this.list_func{i},'.md'])
      end
    end
  end
end
