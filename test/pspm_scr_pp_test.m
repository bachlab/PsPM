classdef pspm_scr_pp_test < matlab.unittest.TestCase

  % DEFINITION
  %   pspm_scr_pp_test validate the behaviour of pspm_scr_pp
  %
  % (C) 2013 Linus Rittimann (University of Zurich)
  % 2021 Teddy Chao (WCHN. UCL)

  properties(Constant)
    fn = 'scr_pp_test.mat';
    duration = 10;
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
      pspm_testdata_gen(channels, this.duration, this.fn);
      % scr_pp is currently an indepedent function, so no need to
      % perform validation with other options like pspm_pp i think?
    end

    function scr_pp_test(this)
      channels{1}.chantype = 'scr';

      scr_pp_test_template(this, channels)

      % Delete testdata
      if exist(this.fn)
        delete(this.fn);
      end
      if exist('test_missing.mat')
        delete('test_missing.mat');
      end
    end
  end

  methods
    function scr_pp_test_template(this, channels)
      options1 = struct('deflection_threshold', 0, ...
        'expand_epochs', 0, ...
        'channel_action', 'add');
      options2 = struct('deflection_threshold', 0, ...
        'channel', 'scr', ...
        'expand_epochs', 0, ...
        'channel_action', 'replace');
      options3 = struct('deflection_threshold', 0, ...
        'channel', 'scr', ...
        'expand_epochs', 0, ...
        'channel_action', 'withdraw');
      options4 = struct('missing_epochs_filename', 'test_missing.mat', ...
        'deflection_threshold', 0, ...
        'expand_epochs', 0);
      options5 = struct('missing_epochs_filename', 'test_missing.mat', ...
        'deflection_threshold', 0, ...
        'expand_epochs', 0, ...
        'channel_action', 'replace');

      pspm_testdata_gen(channels, this.duration, this.fn); % generate testdata
      [sts, ~, ~, filestruct] = pspm_load_data(this.fn, 'none');
      this.verifyTrue(sts == 1, 'the returned file couldn''t be loaded');
      this.verifyTrue(filestruct.numofchan == numel(channels), ...
        'the returned file contains not as many channels as the inputfile');

      % Verifying the situation without no missing epochs filename option
      % and add the epochs to the file
      pspm_testdata_gen(channels, this.duration, this.fn);
      [~, out] = pspm_scr_pp(this.fn, options1);
      [sts_out, ~, ~, fstruct_out] = pspm_load_data(out{1}, 'none');
      this.verifyTrue(sts_out == 1, 'the returned file couldn''t be loaded');
      this.verifyTrue(fstruct_out.numofchan == numel(channels)+1, 'the output has the same size');

      % Verifying the situation without no missing epochs filename option
      % and replace the data in the file
      pspm_testdata_gen(channels, this.duration, this.fn);
      [~, out] = pspm_scr_pp(this.fn, options2);
      [sts_out, ~, ~, fstruct_out] = pspm_load_data(out{1}, 'none');
      this.verifyTrue(sts_out == 1, 'the returned file couldn''t be loaded');
      this.verifyTrue(fstruct_out.numofchan == numel(channels), 'the output has a different size');

      % Verifying the situation without no missing epochs filename option
      % and withdraw the data in the file
      pspm_testdata_gen(channels, this.duration, this.fn);
      [~, out] = pspm_scr_pp(this.fn, options3);
      [sts_out, ~, ~, fstruct_out] = pspm_load_data(out{1}, 'none');
      this.verifyTrue(sts_out == 1, 'the returned file couldn''t be loaded');
      this.verifyTrue(fstruct_out.numofchan == numel(channels), 'output was saved unexpectedly');

      % Verifying the situation with missing epochs filename option without
      % saving to datafile
      pspm_testdata_gen(channels, this.duration, this.fn);
      [~, out] = pspm_scr_pp(this.fn, options4);
      [sts_out, ~, ~, fstruct_out] = pspm_load_data(out{1}, 'none');
      this.verifyTrue(sts_out == 1, 'the returned file couldn''t be loaded');
      this.verifyTrue(fstruct_out.numofchan == numel(channels)+1, 'output has a different size');
      sts_out = exist('test_missing.mat', 'file');
      this.verifyTrue(sts_out > 0, 'missing epoch file was not saved');
      delete('test_missing.mat');

      % Verifying the situation with missing epochs filename option with
      % saving to datafile
      pspm_testdata_gen(channels, this.duration, this.fn);
      [~, out] = pspm_scr_pp(this.fn, options5);
      [sts_out, ~, ~, fstruct_out] = pspm_load_data(out{1}, 'none');
      this.verifyTrue(sts_out == 1, 'the returned file couldn''t be loaded');
      this.verifyTrue(fstruct_out.numofchan == numel(channels), 'output has a different size');
      sts_out = exist('test_missing.mat', 'file');
      this.verifyTrue(sts_out > 0, 'missing epoch file was not saved');
      delete('test_missing.mat');

      % test no file exists when not provided
      % this.verifyError(@()load('missing_epochs_test_out'), 'MATLAB:load:couldNotReadFile');
    end
  end
end
