classdef pspm_split_sessions_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for the pspm_split_sessions function
  % ● Authorship
  % (C) 2013 Linus Rüttimann (University of Zurich)
  properties
    expected_number_of_files = 3;
    fn_data = 'split_sessions_datafile';
    fn_missing = 'split_sessions_missing';
  end
  properties (TestParameter)
    nsessions = {2,5}
    prefix = {-1,-5,-15}
    suffix = {3,9,12}
    splitpoints = {[2 5 7 9 11],[10 20 33 35 60 80 90 100 111 114 116 120],[]}
    splitpoints_for_missing = {[2, 6]}
  end
  methods (Test)
    function test_missing(this, splitpoints_for_missing)
      n_sess = 10;
      sess_dist = 10;
      fn = pspm_find_free_fn(this.fn_data, '.mat');
      channels{1}.chantype = 'scr';
      channels{2}.chantype = 'hb';
      channels{3}.chantype = 'marker';
      channels{3}.sessions = n_sess;
      channels{3}.session_distance = sess_dist;
      channels{3}.variance = 0.05;
      % 6 minutes data
      dur = 60*6;
      data = pspm_testdata_gen(channels, dur, fn);
      options.splitpoints = splitpoints_for_missing;
      options.missing = [this.fn_missing,'.mat'];

      % generate artificial missing epoch file
      epochs = zeros(1,2);
      epochs(1,1)=3;
      epochs(1,2)=4;
      save([this.fn_missing,'.mat'],"epochs")
      newdatafile = pspm_split_sessions(fn, options);
      this.verifyTrue(isfile(newdatafile{1}));
      this.verifyTrue(isfile(newdatafile{2}));
      this.verifyTrue(isfile(newdatafile{3}));
      % clear
      delete(fn)
      delete([this.fn_data,'.mat']);
      delete([this.fn_missing,'.mat']);
      delete(newdatafile{1});
      delete(newdatafile{2});
      delete(newdatafile{3});
      delete([this.fn_missing,'_sn01.mat']);
      delete([this.fn_missing,'_sn02.mat']);
      delete([this.fn_missing,'_sn03.mat']);
    end
    function invalid_input(this)
      this.verifyWarning(@()pspm_split_sessions(), 'ID:invalid_input');
      this.verifyWarning(@()pspm_split_sessions(2), 'ID:invalid_input');
      this.verifyWarning(@()pspm_split_sessions('fn', 'foo'), 'ID:invalid_input');
    end
    function one_datafile(this)
      fn = [this.fn_data,'.mat'];
      channels{1}.chantype = 'scr';
      channels{2}.chantype = 'hb';
      channels{3}.chantype = 'marker';
      datastruct = pspm_testdata_gen(channels, 100);
      datastruct.data{3}.data = [1 4 9 12 30 31 34 41 43 59 65 72 74 80 89 96]';
      % with default values MAXSN=10 & BRK2NORM=3 the datafile should be split into 3 files
      datastruct.options = struct();
      pspm_load_data(fn, datastruct); %save datafile
      %datafile.data{3}.data = [0 1]';
      %save(fn, '-struct', 'datafile');
      newdatafile = pspm_split_sessions(fn, struct());
      this.verifyTrue(numel(newdatafile) == this.expected_number_of_files, ...
        sprintf('the testdatafile %s has been split into %i files and not like expected into %i files', ...
        fn, numel(newdatafile), this.expected_number_of_files));
      for k = 1:numel(newdatafile)
        [sts, ~, data] = pspm_load_data(newdatafile{k});
        this.verifyTrue(sts == 1, sprintf('couldn''t load file %s with pspm_load_data', newdatafile{k}));
        this.verifyTrue(numel(data) == numel(channels), ...
          sprintf('number of channels doesn''t match in file %s', newdatafile{k}));
        delete(newdatafile{k});
      end
      delete(fn);
    end
    function test_dynamic_sessions(this, nsessions)
      fn = pspm_find_free_fn(this.fn_data, '.mat');
      channels{1}.chantype = 'scr';
      channels{2}.chantype = 'hb';
      channels{3}.chantype = 'marker';
      channels{3}.sessions = nsessions;
      channels{3}.session_distance = 10;
      channels{3}.variance = 0.05;
      % 6 minutes data
      pspm_testdata_gen(channels, 60*6, fn);
      newdatafile = pspm_split_sessions(fn, struct());
      % check number of sessions
      this.verifyEqual(numel(newdatafile), nsessions);
      % check that all sessions (with the exception of the first) start at the marker onset  
      for i = 1:numel(newdatafile)
        if exist(newdatafile{i}, 'file')
          if i > 1
            [~, ~, d] = pspm_load_data(newdatafile{i});
            this.verifyEqual(d{3}.data(1), 0);
          end
          delete(newdatafile{i});
        end
      end
      if exist(fn, 'file')
        delete(fn);
      end
    end
    function test_appendices(this, prefix, suffix)
      fn = pspm_find_free_fn(this.fn_data, '.mat');
      channels{1}.chantype = 'scr';
      channels{2}.chantype = 'hb';
      channels{3}.chantype = 'marker';
      channels{3}.sessions = 10;
      channels{3}.session_distance = 10;
      channels{3}.variance = 0.05;
      % 6 minutes data
      data = pspm_testdata_gen(channels, 60*6, fn);
      options = struct('prefix', prefix, 'suffix', suffix);
      newdatafile = pspm_split_sessions(fn, options);
      this.verifyEqual(numel(newdatafile),10);
      for i = 1:numel(newdatafile)
        if exist(newdatafile{i}, 'file')
          % test suffix and prefix
          [~, info, d] = pspm_load_data(newdatafile{i});
          if i ~= 1
            this.verifyEqual(d{3}.data(1), -prefix);
          end
          if i ~= numel(newdatafile)
            this.verifyEqual(d{3}.data(end), info.duration - (suffix + mean(diff(d{3}.data))), 'RelTol', 5*10^-2);
          end
          % remove file
          delete(newdatafile{i});
        end
      end
      if exist(fn, 'file')
        delete(fn);
      end
    end
    function test_splitpoints(this, splitpoints)
      n_sess = 10;
      sess_dist = 10;
      fn = pspm_find_free_fn(this.fn_data, '.mat');
      channels{1}.chantype = 'scr';
      channels{2}.chantype = 'hb';
      channels{3}.chantype = 'marker';
      channels{3}.sessions = n_sess;
      channels{3}.session_distance = sess_dist;
      channels{3}.variance = 0.05;
      % 6 minutes data
      dur = 60*6;
      data = pspm_testdata_gen(channels, dur, fn);
      split_times = data.data{3}.data(splitpoints)';
      if isempty(splitpoints)
        sess_dur = repmat((dur - n_sess*sess_dist)/n_sess, 1, n_sess);
      else
        starts = [1 split_times];
        ends = [split_times dur];
        sess_dur = diff([starts; ends]);
      end
      % adapt the first and last session duration, as no trimming will be
      % performed towards file start/end
      if ~isempty(splitpoints)
        sess_dur(1) = split_times(1);
        sess_dur(end) = dur - split_times(end);
      end
      options.splitpoints = splitpoints;
      newdatafile = pspm_split_sessions(fn, options);
      if ~isempty(splitpoints)
        n_sess_exp = numel(splitpoints)+1;
      else
        n_sess_exp = 10;
      end
      this.verifyEqual(numel(newdatafile),n_sess_exp);
      for i = 1:numel(newdatafile)
        if exist(newdatafile{i}, 'file')
          % test session duration
          [~, info, ~] = pspm_load_data(newdatafile{i});
          this.verifyEqual(info.duration, sess_dur(i), 'RelTol', 0.5);
          % remove file
          delete(newdatafile{i});
        end
      end
      if exist(fn, 'file')
        delete(fn);
      end
    end
    
  end
end
