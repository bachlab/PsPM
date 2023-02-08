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
      channels{1}.channeltype = 'scr';
      channels{2}.channeltype = 'hb';
      channels{3}.channeltype = 'scr';
      fn = 'testfile549813.mat';
      pspm_testdata_gen(channels, 10, fn);
      % perform the other tests with invalid input data
      this.verifyWarning(@()pspm_pp('foo', fn, 100), 'ID:invalid_input');
      this.verifyWarning(@()pspm_pp('butter', fn, 19), 'ID:invalid_freq');
      %this.verifyWarning(@()pspm_pp('simple_qa', fn, struct('missing_epochs_filename', 1)), 'ID:invalid_input');
    end
    function median_test(this)
      %generate testdata
      channels{1}.channeltype = 'scr';
      channels{2}.channeltype = 'hb';
      channels{3}.channeltype = 'scr';
      fn = 'testfile549813.mat';
      pspm_testdata_gen(channels, 10, fn);
      %filter one channel
      newfile = pspm_pp('median', fn, 50, 3);
      [sts, infos, data, filestruct] = pspm_load_data(newfile, 'none');
      this.verifyTrue(sts == 1, 'the returned file couldn''t be loaded');
      this.verifyTrue(filestruct.numofchan == numel(channels), 'the returned file contains not as many channels as the inputfile');
      delete(newfile);
      %filter multiple channels
      newfile = pspm_pp('median', fn, 50);
      [sts, infos, data, filestruct] = pspm_load_data(newfile, 'none');
      this.verifyTrue(sts == 1, 'the returned file couldn''t be loaded');
      this.verifyTrue(filestruct.numofchan == numel(channels), 'the returned file contains not as many channels as the inputfile');
      delete(newfile);
      %delete testdata
      delete(fn);
    end
    function butter_test(this)
      %generate testdata
      channels{1}.channeltype = 'scr';
      channels{2}.channeltype = 'hb';
      channels{3}.channeltype = 'scr';
      fn = 'testfile549814.mat';
      pspm_testdata_gen(channels, 10, fn);
      %filter one channel
      newfile = pspm_pp('butter', fn, 40, 3);
      [sts, infos, data, filestruct] = pspm_load_data(newfile, 'none');
      this.verifyTrue(sts == 1, 'the returned file couldn''t be loaded');
      this.verifyTrue(filestruct.numofchan == numel(channels), 'the returned file contains not as many channels as the inputfile');
      delete(newfile);
      %filter multiple channels
      newfile = pspm_pp('butter', fn, 40);
      [sts, infos, data, filestruct] = pspm_load_data(newfile, 'none');
      this.verifyTrue(sts == 1, 'the returned file couldn''t be loaded');
      this.verifyTrue(filestruct.numofchan == numel(channels), 'the returned file contains not as many channels as the inputfile');
      delete(newfile);
      %delete testdata
      delete(fn);
    end
    %        function simple_qa_test(this)
    %            %generate testdata
    %            channels{1}.channeltype = 'scr';
    %
    %            fn = 'missing_epochs_test_generated_data.mat';
    %            pspm_testdata_gen(channels, 10, fn);
    %
    %            %filter one channel
    %            missing_epoch_filename = 'missing_epochs_test_out';
    %            qa = struct('missing_epochs_filename', missing_epoch_filename, ...
    %                        'deflection_threshold', 0, ...
    %                        'expand_epochs', 0 );
    %            newfile = pspm_pp('simple_qa', fn, qa);
    %
    %            [sts, infos, data, filestruct] = pspm_load_data(newfile, 'none');
    %
    %            this.verifyTrue(sts == 1, 'the returned file couldn''t be loaded');
    %            this.verifyTrue(filestruct.numofchan == numel(channels), 'the returned file contains not as many channels as the inputfile');
    %
    %            delete(newfile);
    %
    %            out = load(missing_epoch_filename);
    %            this.verifySize(out.epochs, [ 10, 2 ], 'the written epochs are not of the correct size')
    %            delete(string(missing_epoch_filename) + ".mat");
    %
    %
    %            %no missing epochs filename option
    %            newfile = pspm_pp('simple_qa', fn);
    %
    %            [sts, infos, data, filestruct] = pspm_load_data(newfile, 'none');
    %
    %            this.verifyTrue(sts == 1, 'the returned file couldn''t be loaded');
    %            this.verifyTrue(filestruct.numofchan == numel(channels), 'the returned file contains not as many channels as the inputfile');
    %
    %            delete(newfile);
    %            % test no file exists when not provided
    %            this.verifyError(@()load('missing_epochs_test_out'), 'MATLAB:load:couldNotReadFile');
    %
    %            %delete testdata
    %            delete(fn);
    %        end
    function overwrite_test(this)
      % generate test data
      channels{1}.channeltype = 'scr';
      channels{2}.channeltype = 'hb';
      fn = 'testfile549815.mat';
      pspm_testdata_gen(channels, 10, fn);
      % run once
      newfile = pspm_pp('butter', fn, 40);
      % add one channel, run again and don't overwrite
      channels{3}.channeltype = 'scr';
      pspm_testdata_gen(channels, 10, fn);
      options.overwrite = 0;
      newfile = pspm_pp('butter', fn, 40, [1,3], options);
      % compare the files and ensure there was no overwrite
      [sts, infos, data, filestruct] = pspm_load_data(newfile, 'none');
      this.verifyTrue(filestruct.numofchan == 2, 'The file has been overwritten even if i told the function not to do so!');
      % turn on overwrite and run again
      options.overwrite = 1;
      newfile = pspm_pp('butter', fn, 40, [1,3], options);
      % compare the files and ensure there was an overwrite
      [sts, infos, data, filestruct] = pspm_load_data(newfile, 'none');
      this.verifyTrue(filestruct.numofchan == 3, 'The file has not been overwritten even if i told the function to do so!');
      % remove the files
      delete(newfile);
      delete(fn);
    end
  end
end