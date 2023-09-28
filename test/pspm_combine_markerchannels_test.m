classdef pspm_combine_markerchannels_test < matlab.unittest.TestCase
  % ● Description
  %   Unittest class for the pspm_combine_markerchannels function
  % ● History
  %   Written in 2023 by Teddy Chao
  properties
    expected_number_of_files = 3;
    fn_data = 'datafile';
    duration = 10;
  end
  properties (TestParameter)
  end
  methods (Test)
    function test_combine(this)
      n_sess = 10;
      sess_dist = 10;
      fn = pspm_find_free_fn(this.fn_data, '.mat');
      channels{1}.chantype = 'scr';
      channels{2}.chantype = 'hb';
      channels{3}.chantype = 'marker';
      pspm_testdata_gen(channels, this.duration, fn);

      % generate artificial missing epoch file
      sts = pspm_combine_markerchannels(fn);

      [sts_out, ~, ~, fstruct] = pspm_load_data(fn, 'none');
      this.verifyTrue(sts_out == 1, 'the processed file couldn''t be loaded');
      this.verifyTrue(fstruct.numofchan == numel(channels)+1, 'the output has a different size');
    end
  end
end