classdef pspm_blink_saccade_filt_test < pspm_get_superclass
  % ● Description
  % unittest class for the pspm_blink_saccade_filt function
  % ● Authorship
  % (C) 2019 Eshref Yozdemir (University of Zurich)
  properties
    fn = fullfile('ImportTestData', 'eyelink', 'u_sc4b31.asc');
    testcases;
    fhandle = @pspm_blink_saccade_filt;
  end
  methods
    function define_testcases(this)
    end
  end
  methods (Test)
    function invalid_input(this)
      this.verifyWarning(@()pspm_blink_saccade_filt(this.fn, 'str'), 'ID:invalid_input');
      options.chan_action = 'delete';
      this.verifyWarning(@()pspm_blink_saccade_filt(this.fn, 0, options), 'ID:invalid_input');
    end
    function test_filtering(this)
      factor_list = [0, 0.001, 0.01, 0.1, 1];
      for discard_factor = factor_list
        import{1}.type = 'pupil_r';
        import{1}.eyelink_trackdist = 700;
        import{1}.distance_unit = 'mm';
        import{2}.type = 'gaze_x_r';
        import{3}.type = 'gaze_y_r';
        import{4}.type = 'blink_r';
        import{5}.type = 'saccade_r';
        options.eyelink_trackdist = 700;
        options.distance_unit = 'mm';
        options.overwrite = true;
        fn_imported = pspm_import(this.fn, 'eyelink', import, options);
        fn_imported = fn_imported{1};
        [~, ~, data_old] = pspm_load_data(fn_imported);
        options = struct('chan_action', 'replace');
        pspm_blink_saccade_filt(fn_imported, discard_factor, options);
        [~, ~, data_new] = pspm_load_data(fn_imported);
        N = numel(data_old{1}.data);
        n_remove = round(discard_factor * data_old{1}.header.sr);
        blink_r_indices = find(data_old{4}.data);
        sacc_r_indices = find(data_old{5}.data);
        for i = 1:3
          this.verifyTrue(assert_nan(data_new{i}.data, blink_r_indices, N, n_remove));
          this.verifyTrue(assert_nan(data_new{i}.data, sacc_r_indices, N, n_remove));
        end
      end
    end
  end
end
function out = assert_nan(data, indices, N, n_remove)
for idx = indices
  lo = max(1, idx - n_remove);
  hi = min(N, idx + n_remove);
  if ~all(isnan(data(lo:hi)))
    out = false;
    return;
  end
end
out = true;
end
