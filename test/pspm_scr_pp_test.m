classdef pspm_scr_pp_test < matlab.unittest.TestCase
  % ● Description
  %   Unittest class for the pspm_scr_pp function
  % ● History
  %   Written in 2021 by Teddy Chao
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
      scr_pp_test_missing(this, channels)
      scr_pp_test_data_island_threshold(this, channels)

      % Delete testdata
      if exist(this.fn, 'file')
        delete(this.fn);
      end
      if exist('test_missing.mat', 'file')
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
      pspm_testdata_gen(channels, this.duration, this.fn); % generate testdata
      [sts, ~, ~, filestruct] = pspm_load_data(this.fn, 'none');
      this.verifyTrue(sts == 1, 'the returned file couldn''t be loaded');
      this.verifyTrue(filestruct.numofchan == numel(channels), ...
        'the returned file contains not as many channels as the inputfile');
      % Verifying the situation without no missing epochs filename option
      % and add the epochs to the file
      pspm_testdata_gen(channels, this.duration, this.fn);
      [~, out] = pspm_scr_pp(this.fn, options1);
      [sts_out, ~, ~, fstruct_out] = pspm_load_data(this.fn, 'none');
      this.verifyTrue(sts_out == 1, 'the returned file couldn''t be loaded');
      this.verifyTrue(fstruct_out.numofchan == numel(channels)+1, 'the output has the same size');
      % Verifying the situation without no missing epochs filename option
      % and replace the data in the file
      pspm_testdata_gen(channels, this.duration, this.fn);
      [~, out] = pspm_scr_pp(this.fn, options2);
      [sts_out, ~, ~, fstruct_out] = pspm_load_data(this.fn, 'none');
      this.verifyTrue(sts_out == 1, 'the returned file couldn''t be loaded');
      this.verifyTrue(fstruct_out.numofchan == numel(channels), 'the output has a different size');
    end
    function scr_pp_test_missing(this, channels)
      options4 = struct('missing_epochs_filename', 'test_missing.mat', ...
        'deflection_threshold', 0, ...
        'expand_epochs', 0);
      options5 = struct('missing_epochs_filename', 'test_missing.mat', ...
        'deflection_threshold', 0, ...
        'expand_epochs', 0, ...
        'channel_action', 'add');
      % Verifying the situation with missing epochs filename option without
      % saving to datafile
      pspm_testdata_gen(channels, this.duration, this.fn);
      [~, out] = pspm_scr_pp(this.fn, options4);
      [sts_out, ~, ~, fstruct_out] = pspm_load_data(this.fn, 'none');
      this.verifyTrue(sts_out == 1, 'the returned file couldn''t be loaded');
      this.verifyTrue(fstruct_out.numofchan == numel(channels), 'output has a different size');
      sts_out = exist('test_missing.mat', 'file');
      this.verifyTrue(sts_out > 0, 'missing epoch file was not saved');
      delete('test_missing.mat');
      % Delete testdata
      delete(this.fn);
    end
    function scr_pp_test_data_island_threshold(this, channels)
        % Regression test for data_island_threshold.
        %
        % Create:
        % valid data | 1 s artefact | 1 s valid island |
        % 1 s artefact | valid data
        %
        % With data_island_threshold = 2 s, only the 1 s valid island
        % between the artefacts should be removed.

        pspm_testdata_gen(channels, this.duration, this.fn);

        % Load generated test data
        [sts, infos, data] = pspm_load_data(this.fn);
        this.verifyEqual(sts, 1, ...
            'Test data could not be loaded.');

        sr = data{1}.header.sr;
        this.assertGreaterThan(sr, 2, 'Regression test requires a sampling rate greater than 2 Hz.');
        n_samples = numel(data{1}.data);

        % Use controlled valid SCR data
        data{1}.data = ones(size(data{1}.data));

        % Define two 1-second artefacts with a 1-second valid island
        % between them.
        artefact1 = round(3 * sr) + 1 : round(4 * sr);
        artefact2 = round(5 * sr) + 1 : round(6 * sr);

        % Make sure the generated data are long enough
        this.assertLessThanOrEqual(artefact2(end), n_samples);

        % Values above SCR max threshold are guaranteed to be invalid
        data{1}.data(artefact1) = 100;
        data{1}.data(artefact2) = 100;

        % Save manipulated test data
        outdata.data = data;
        outdata.infos = infos;
        outdata.options.overwrite = 1;

        sts = pspm_load_data(this.fn, outdata);
        this.verifyEqual(sts, 1, ...
            'Manipulated SCR test data could not be saved.');

        % Run SCR preprocessing
        options = struct( ...
            'channel', 1, ...
            'min', 0.05, ...
            'max', 60, ...
            'slope', 10, ...
            'deflection_threshold', 0, ...
            'data_island_threshold', 2, ...
            'expand_epochs', 0, ...
            'clipping_threshold', 1, ...
            'channel_action', 'replace');

        [sts, ~] = pspm_scr_pp(this.fn, options);
        this.verifyEqual(sts, 1, ...
            'pspm_scr_pp failed.');

        % Load processed SCR channel
        [sts, ~, processed_data] = pspm_load_data(this.fn);
        this.verifyEqual(sts, 1, ...
            'Processed test data could not be loaded.');

        processed = processed_data{1}.data;

        % Use regions away from the artefact boundaries because the slope
        % criterion can invalidate individual boundary samples.

        valid_before = round(1 * sr) : round(2 * sr);
        island_middle = round(4.25 * sr) : round(4.75 * sr);
        valid_after = round(7 * sr) : round(8 * sr);

        % Long valid data islands must remain
        this.verifyTrue(all(~isnan(processed(valid_before))), ...
            'Valid data before the artefacts were incorrectly removed.');

        this.verifyTrue(all(~isnan(processed(valid_after))), ...
            'Valid data after the artefacts were incorrectly removed.');

        % The 1-second island must be removed because it is shorter than
        % data_island_threshold = 2 seconds
        this.verifyTrue(all(isnan(processed(island_middle))), ...
            'Data island shorter than data_island_threshold was not removed.');
    end
  end
end
