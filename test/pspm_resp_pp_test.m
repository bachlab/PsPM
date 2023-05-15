classdef pspm_resp_pp_test < pspm_testcase
  % ● Description
  % unittest class for the pspm_resp_pp function
  % ● Authorship
  % (C) 2019 Eshref Yozdemir (University of Zurich)
  properties(Constant)
    input_filename = ['ImportTestData' filesep 'resp' filesep 'pspm_resp_pp_input.mat'];
    backup_filename = ['ImportTestData' filesep 'resp' filesep 'pspm_resp_pp_input_backup.mat'];
    r660_results_filename = ['ImportTestData' filesep 'resp' filesep 'pspm_resp_pp_r660_results.mat'];
    sampling_rate = 2000;
    resp_channel = 1;
    options = struct('systemtype', 'cushion');
  end
  methods(TestClassSetup)
    function backup(this)
      sts = copyfile(this.input_filename, this.backup_filename);
      assert(sts == 1);
    end
  end
  methods(Test)
    function invalid_input(this)
      % no argument
      this.verifyWarning(@()pspm_resp_pp(), 'ID:invalid_input');
      % no sample rate is given
      this.verifyWarning(@()pspm_resp_pp('filename'), 'ID:invalid_input');
      % pass non-string filename
      this.verifyWarning(@()pspm_resp_pp(5, 20), 'ID:invalid_input');
      % pass nonnumeric sampling rate
      this.verifyWarning(@()pspm_resp_pp('filename', '205'), 'ID:invalid_input');
      % pass nonnumeric sampling rate
      this.verifyWarning(@()pspm_resp_pp('filename', '205'), 'ID:invalid_input');
      % pass nonnumeric sampling rate
      this.verifyWarning(@()pspm_resp_pp('filename', '205'), 'ID:invalid_input');
      % pass too high channel
      this.verifyWarning(@()pspm_resp_pp(this.input_filename, 2000, 999999999), 'ID:invalid_input');
    end
    % Regression test. Compare results to r660 version which is presumably correct
    function compare_results_to_results_obtained_from_r660_version(this)
      import matlab.unittest.constraints.IsEqualTo
      import matlab.unittest.constraints.RelativeTolerance
      [sts, out, old_data] = pspm_load_data(this.r660_results_filename);
      assert(sts == 1);
      assert(numel(old_data) == 5);
      assert(strcmpi(old_data{1}.header.chantype, 'resp'));
      assert(strcmpi(old_data{2}.header.chantype, 'rp'));
      assert(strcmpi(old_data{3}.header.chantype, 'ra'));
      assert(strcmpi(old_data{4}.header.chantype, 'rfr'));
      assert(strcmpi(old_data{5}.header.chantype, 'rs'));
      sts = pspm_resp_pp(this.input_filename, this.sampling_rate, this.resp_channel, this.options);
      assert(sts == 1);
      [sts, out, new_data] = pspm_load_data(this.input_filename);
      assert(sts == 1);
      assert(numel(new_data) == 5);
      assert(strcmpi(new_data{1}.header.chantype, 'resp'));
      assert(strcmpi(new_data{2}.header.chantype, 'rp'));
      assert(strcmpi(new_data{3}.header.chantype, 'ra'));
      assert(strcmpi(new_data{4}.header.chantype, 'rfr'));
      assert(strcmpi(new_data{5}.header.chantype, 'rs'));
      for i = 1:5
        this.verifyThat(old_data{i}.data, IsEqualTo(new_data{i}.data, 'Within', RelativeTolerance(1e-10)));
      end
    end
    % TODO: Write more tests
  end
  methods(TestClassTeardown)
    function restore(this)
      sts = copyfile(this.backup_filename, this.input_filename);
      assert(sts == 1);
      delete(this.backup_filename);
    end
  end
end
