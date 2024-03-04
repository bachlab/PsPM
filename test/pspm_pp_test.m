classdef pspm_pp_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for the pspm_pp function
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  properties
  end
  methods (Test)
    function invalid_input(this)
      % test for invalid file
      this.verifyWarning(@()pspm_pp('butter', 'file'), 'ID:invalid_input');
      % for the following tests a valid file is required thus
      % generate some random data
      channels{1}.chantype = 'scr';
      channels{2}.chantype = 'hb';
      channels{3}.chantype = 'scr';
      fn = 'testfile549813.mat';
      pspm_testdata_gen(channels, 10, fn);
      % perform the other tests with invalid input data
      this.verifyWarning(@()pspm_pp('foo', fn, 'scr', 100), 'ID:invalid_input');
      this.verifyWarning(@()pspm_pp('butter', fn, 'scr', 19), 'ID:invalid_input');
    end
    function median_test(this)
      %generate testdata
      channels{1}.chantype = 'scr';
      channels{2}.chantype = 'hb';
      channels{3}.chantype = 'scr';
      fn = 'testfile549813.mat';
      pspm_testdata_gen(channels, 10, fn);
      %filter one channel
      [sts, newfile] = pspm_pp('median', fn, 3, 50, struct('channel_action', 'replace'));
      this.verifyTrue(sts == 1);
      [sts, infos, data, filestruct] = pspm_load_data(newfile, 'none');
      this.verifyTrue(sts == 1, 'the returned file couldn''t be loaded');
      this.verifyTrue(filestruct.numofchan == numel(channels), 'the returned file contains not as many channels as the inputfile');
      delete(newfile);
      delete(fn);
    end
    function butter_test(this)
      %generate testdata
      channels{1}.chantype = 'scr';
      channels{2}.chantype = 'hb';
      channels{3}.chantype = 'scr';
      fn = 'testfile549814.mat';
      pspm_testdata_gen(channels, 10, fn);
      %filter one channel
      filt = struct('hporder', 1, 'lporder', 1, 'hpfreq', 1, 'lpfreq', 4, 'down', 8);
      [sts, newfile] = pspm_pp('butter', fn, 'scr', filt, struct('channel_action', 'replace'));
      this.verifyTrue(sts == 1);
      [sts, infos, data, filestruct] = pspm_load_data(newfile, 'none');
      this.verifyTrue(sts == 1, 'the returned file couldn''t be loaded');
      this.verifyTrue(filestruct.numofchan == numel(channels), 'the returned file contains not as many channels as the inputfile');
      delete(newfile);
      delete(fn);
    end
  end
end
