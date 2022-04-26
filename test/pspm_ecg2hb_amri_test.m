classdef pspm_ecg2hb_amri_test < pspm_testcase
  % ● Description
  % unittest class for the pspm_ecg2hb_amri function
  % ● Authorship
  % (C) 2019 Eshref Yozdemir (University of Zurich)

  properties(Constant)
    input_filename = fullfile('ImportTestData', 'ecg2hb', 'test_ecg_outlier_data_short.mat');
    backup_filename = fullfile('ImportTestData', 'ecg2hb', 'test_backup.mat');
  end

  methods(TestClassSetup)
    function backup(this)
      sts = copyfile(this.input_filename, this.backup_filename);
      assert(sts == 1);
    end
  end

  methods(Test)
    function check_if_heartbeat_channel_is_saved(this)
      [sts, out_channel] = pspm_ecg2hb_amri(this.input_filename);
      load(this.input_filename);

      this.verifyEqual(data{out_channel}.header.chantype, 'hb');
    end
  end

  methods(TestClassTeardown)
    function restore(this)
      sts = copyfile(this.backup_filename, this.input_filename);
      assert(sts == 1);
      delete(this.backup_filename);
    end
  end
end
