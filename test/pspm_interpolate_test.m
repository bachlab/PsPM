classdef pspm_interpolate_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for the pspm_interpolate function
  % testEnvironment for PsPM version 6.0
  % ● Authorship
  % (C) 2015 Tobias Moser (University of Zurich)
  %			2022 Teddy Chao (UCL)
  properties
    datafile = 'interpolate_test';
    testdata = {};
  end
  properties (TestParameter)
    % interpolation test
    interp_method = {'linear', 'pchip', 'nearest', 'spline', 'previous', 'next'};
    nan_method = {'start', 'center', 'end'};
    extrap = {true, false};
    % valid input test
    amount = {1, 6};
    datatype = {'struct', 'inline', 'file', 'all'};
    chans = { ...
      {{'scr'}, []}, ...
      {{'scr', 'hb', 'scr'},[]}, ... % hb channels shouldn't be interpolated (events)
      {{'scr', 'scr', 'scr'}, [1,3]} ... % all channels except first should be interpolated
      };
    newfile = {true, false};
    overwrite = {true, false};
    replace_channels = {true, false};
  end
  methods
    function [data, opt_chans] = generate_data(this, datatype, amount, nan_method, chans, extrap)
      opt_chans = cell(1,amount);
      if strcmpi(datatype, 'all')
        expand = {1, 2, 3};
        if amount < numel(expand)
          expand = {1:amount};
        end
      else
        expand = {find(strcmpi(datatype, this.datatype))};
      end
      data = repmat(expand, 1, ceil(amount/numel(expand)));
      % force cell
      if numel(data) == 1 && ~iscell(data)
        data = {data};
      end
      for i = 1:amount
        % generate data
        if strcmpi(this.datatype{data{i}}, 'inline')
          % inline is always just one channel
          c{1}.chantype = 'scr';
          if amount > 1
            opt_chans{i} = {};
          end
        else
          % not inline is with chans option
          c = cell(1,numel(chans{1}));
          for j=1:numel(chans{1})
            c{j}.chantype = chans{1}{j};
          end
          opt_chans{i} = chans{2};
        end
        d = pspm_testdata_gen(c, 10);
        % put nans
        for j=1:numel(d.data)
          d.data{j}.data = this.put_nan(d.data{j}.data, nan_method, extrap);
        end
        if strcmpi(this.datatype{data{i}}, 'file')
          % find filename
          fn = pspm_find_free_fn(this.datafile, '.mat');
          % save data
          pspm_load_data(fn, d);
          data{i} = fn;
        elseif strcmpi(this.datatype{data{i}}, 'struct')
          data{i} = d;
        elseif strcmpi(this.datatype{data{i}}, 'inline')
          data{i} = d.data{1}.data;
        end
      end
      this.testdata{end+1} = data;
    end
    function outdata = put_nan(~, indata, method, extrap)
      middle = floor(numel(indata)/2);
      % if extrapolation is given we can delete to the end and
      % beginning of the file; otherwise not
      if extrap
        offset = 0;
      else
        offset = 1;
      end
      mdl = middle-1-offset;
      switch method
        case 'start'
          s = 1+offset;
          e = 1+offset+round(rand * mdl);
        case 'center'
          s = 1+ceil(rand * mdl);
          e = floor(rand * mdl) + middle;
        case 'end'
          s = ceil(rand * mdl) + middle;
          e = numel(indata) - offset;
      end
      outdata = indata;
      outdata(s:e) = NaN;
    end
    function verify_nan_free(this, data, channels)
      if isnumeric(data)
        % only one channel to interpolate
        this.verifyTrue(~any(isnan(data)));
      else
        [~, ~, d] = pspm_load_data(data, 0);
        for i = 1:numel(d)
          % only test non-event channels
          if ~strcmpi(d{i}.header.units, 'events')
            if (isempty(channels) || ismember(i, channels))
              this.verifyTrue(~any(isnan(d{i}.data)));
            else
              % data should contain nans because
              % channels is not empty and i is not member of
              % channels -> should not be interpolated
              %
              % only in this case where data is always
              % generated with NaNs inside (expect events
              % channels)
              this.verifyTrue(any(isnan(d{i}.data)));
            end
          end
        end
      end
    end
  end
  methods (TestMethodTeardown)
    function cleanup_data(this)
      data = this.testdata;
      % if datafield is a file, delete it
      for i = 1:numel(data)
        for j = 1:numel(data{i})
          if ischar(data{i}{j}) && exist(data{i}{j}, 'file')
            delete(data{i}{j});
          end
        end
      end
      this.testdata = {};
    end
  end
  methods (Test)
    function invalid_input(this)
      c{1}.chantype = 'scr';
      valid_data = pspm_testdata_gen(c, 10);
      valid_data = {valid_data, valid_data};
      % no input
      this.verifyWarning(@() pspm_interpolate(), 'ID:missing_data');
      % data ist not (char, struct, numeric)
      invalid_data = {{}};
      this.verifyWarning(@() pspm_interpolate(invalid_data), 'ID:invalid_input');
      % empty data
      invalid_data = {};
      this.verifyWarning(@() pspm_interpolate(invalid_data), 'ID:missing_data');
      % invalid struct
      invalid_data = struct();
      this.verifyWarning(@() pspm_interpolate(invalid_data), 'ID:invalid_data_structure');
      % invalid filename
      invalid_data = {'file_does_not_exist'};
      this.verifyWarning(@() pspm_interpolate(invalid_data), 'ID:nonexistent_file');
      % invalid amount of channels
      options.chans = cell(size(valid_data)+1);
      this.verifyWarning(@() pspm_interpolate(valid_data, options), 'ID:invalid_size');
      % invalid data in channels
      options.chans = 'ab';
      this.verifyWarning(@() pspm_interpolate(valid_data, options), 'ID:invalid_input');
      % invalid interpolation method
      options = struct('method', 'invalid_method');
      this.verifyWarning(@() pspm_interpolate(valid_data, options), 'ID:invalid_input');
      % invalid newfile
      options = struct('newfile', 'bla');
      this.verifyWarning(@() pspm_interpolate(valid_data, options), 'ID:invalid_input');
      % invalid extrapolate
      options = struct('extrapolate', 'bla');
      this.verifyWarning(@() pspm_interpolate(valid_data, options), 'ID:invalid_input');
      % invalid overwrite
      options = struct('overwrite', 'bla');
      this.verifyWarning(@() pspm_interpolate(valid_data, options), 'ID:invalid_input');
      % invalid chan_action
      options = struct('chan_action', 'bla');
      this.verifyWarning(@() pspm_interpolate(valid_data, options), 'ID:invalid_input');
      % try to interpolate an events channel
      c{1}.chantype = 'hb';
      invalid_data = pspm_testdata_gen(c, 10);
      options = struct('channels', 1);
      this.verifyWarning(@() pspm_interpolate(invalid_data, options), 'ID:invalid_channeltype');
      % try to interpolate with nan from beginning; without
      % extrapolation
      c{1}.chantype = 'scr';
      invalid_data = pspm_testdata_gen(c, 10);
      backup = invalid_data.data{1}.data(1);
      invalid_data.data{1}.data(1) = NaN;
      this.verifyWarning(@() pspm_interpolate(invalid_data), 'ID:option_disabled');
      options = struct('extrapolate', true, 'method', 'previous');
      this.verifyWarning(@() pspm_interpolate(invalid_data, options), 'ID:out_of_range');
      % finalise
      invalid_data.data{1}.data(1) = backup;
      invalid_data.data{1}.data(end) = NaN;
      this.verifyWarning(@() pspm_interpolate(invalid_data), 'ID:option_disabled');
      options = struct('extrapolate', true, 'method', 'next');
      this.verifyWarning(@() pspm_interpolate(invalid_data, options), 'ID:out_of_range');
    end
    function test_datatypes(this, datatype, amount, chans)
      % generate data
      [data, opt_chans] = generate_data(this, datatype, amount, 'center', chans, false);
      % define options
      options.method = 'linear';
      options.chans = opt_chans;
      options.extrapolate = false;
      % call function
      [sts, outdata] = this.verifyWarningFree(@() pspm_interpolate(data, options));
      %% test if function works as expected
      % sts should be 1
      this.verifyEqual(sts, 1);
      % output data should have same size as input data
      this.verifyEqual(size(data), size(outdata));
      % but data shouldn't be the same
      this.verifyNotEqual(data, outdata);
      % test for nans:
      % * interpolated channels should contain no more nans
      % * not interpolated channels (specified by options.chans)
      %   should still contain nans
      if iscell(outdata)
        for i = 1:numel(outdata)
          if strcmpi(datatype, 'file')
            % will return new channels which have been added to
            % the existing file so we need to get the
            % filenames out of the generated data
            check_data = data{i};
            check_chans = outdata{i};
          else
            check_data = outdata{i};
            if iscell(options.chans) && numel(options.chans) > 0
              check_chans = options.chans{i};
            else
              check_chans = {};
            end
          end
          % verify
          this.verify_nan_free(check_data, check_chans);
        end
      else
        this.verify_nan_free(outdata, options.chans);
      end
    end
    function test_interpolation_variations(this, interp_method, extrap, nan_method)
      % generate data
      [data, opt_chans] = generate_data(this, 'inline', 1, nan_method, {{'scr'}, []}, extrap);
      % define options
      options.method = interp_method;
      options.chans = opt_chans;
      options.extrapolate = extrap;
      if extrap && (...
          (strcmpi(nan_method, 'start') && strcmpi(interp_method, 'previous')) || ...
          (strcmpi(nan_method, 'end') && strcmpi(interp_method, 'next')))
        % this makes no sense -> should give warning
        [~, ~] = this.verifyWarning(@() pspm_interpolate(data, options), 'ID:out_of_range');
      else
        % call function
        [sts, outdata] = this.verifyWarningFree(@() pspm_interpolate(data, options));
        % sts should be 1
        this.verifyEqual(sts, 1);
        % output data should have same size as input data
        this.verifyEqual(size(data), size(outdata));
        % but data shouldn't be the same
        this.verifyNotEqual(data, outdata);
        % test for nans:
        this.verify_nan_free(outdata{1}, options.chans);
      end
    end
    function test_no_nan(this)
      %% try to interpolate without nans
      % generate data
      c{1}.chantype = 'scr';
      data = pspm_testdata_gen(c, 10);
      % interpolate
      [sts, outdata] = this.verifyWarningFree(@() pspm_interpolate(data));
      % sts should be 1
      this.verifyEqual(sts, 1);
      % output data should have same size as input data
      this.verifyEqual(size(data), size(outdata));
      % data should be the same (nothing to interpolate)
      this.verifyEqual(data.data{1,1}.data, outdata.data{1,1}.data);
      % because load_data will add "flank" property to the original
      % header, currently only data is verified here.
      % test for nans
      this.verify_nan_free(outdata, {});
    end
    function test_write(this, newfile)
      % test whether data is added to a new channel or a new file is
      % created
      c_info = {{'scr', 'scr', 'scr'}, [1,3]};
      % generate data
      [data, opt_chans] = generate_data(this, 'file', 2, 'center', c_info, false);
      % define options
      options.method = 'linear';
      options.chans = opt_chans;
      options.extrapolate = false;
      % don't care about that right now
      options.overwrite = 1;
      options.newfile = newfile;
      % call function
      [sts, outdata] = this.verifyWarningFree(@() pspm_interpolate(data, options));
      % sts should be 1
      this.verifyEqual(sts, 1);
      % output data should have same size as input data
      this.verifyEqual(size(data), size(outdata));
      % data shouldn't be the same
      this.verifyNotEqual(data, outdata);
      if newfile
        % check if files exist and delete them
        for i=1:numel(outdata)
          file_exist = exist(outdata{i}, 'file');
          this.verifyTrue(file_exist > 0);
          [~, ~, olddata] = pspm_load_data(data{i});
          [~, ~, newdata] = pspm_load_data(outdata{i});
          this.verifyEqual(size(olddata), size(newdata));
          this.verify_nan_free(outdata{i}, options.chans{i});
          if file_exist
            delete(outdata{i});
          end
        end
      else
        this.verifyTrue(sum(cellfun(@(f) isnumeric(f), outdata)) == numel(outdata));
        % check if last channels match the size of the announced channels
        % verify nan is already done by datatype
        for i = 1:numel(outdata)
          this.verify_nan_free(data{i}, outdata{i});
          [~, ~, d] = pspm_load_data(data{i});
          c = options.chans{i};
          for j=1:numel(c)
            this.verifyEqual(size(d{c(j)}), size(d{outdata{i}(j)}));
          end
        end
      end
    end
    function test_overwrite(this, overwrite)
      % generate data
      [data, ~] = generate_data(this, 'file', 2, 'center', ...
        {{'scr', 'scr', 'scr'}, [1,2,3]} , false);
      % create files beforehand
      for i = 1:numel(data)
        fclose(fopen(['i', data{i}], 'w'));
      end
      options = struct('overwrite', overwrite, 'newfile', true);
      % call function
      if overwrite
        [sts, ~] = this.verifyWarningFree(@() pspm_interpolate(data, options));
      else
        [sts, ~] = this.verifyWarning(@() pspm_interpolate(data, options), 'ID:data_loss');
      end
      % sts should be 1
      this.verifyEqual(sts, 1);
      % test if cannot btw. can be loaded
      for i = 1:numel(data)
        if overwrite
          this.verifyWarningFree(@() pspm_load_data(['i', data{i}], 0));
        else
          this.verifyWarning(@() pspm_load_data(['i', data{i}], 0), 'ID:invalid_file_type');
        end
        if exist(['i', data{i}], 'file')
          delete(['i', data{i}]);
        end
      end
    end
    function test_replace_channel(this, replace_channels)
      % generate data (this, datatype, amount, nan_method, chans, extrap)
      [data, opt_chans] = generate_data(this, 'file', 2, 'center', ...
        {{'scr', 'scr', 'scr'}, [1,2,3]} , false);
      if replace_channels
        options = struct('chan_action', 'replace');
      else
        options = struct('chan_action', 'add');
      end
      % call function
      [sts, outdata] = this.verifyWarningFree(@() pspm_interpolate(data, options));
      % sts should be 1
      this.verifyEqual(sts, 1);
      % output data should have same size as input data
      this.verifyEqual(size(data), size(outdata));
      % data shouldn't be the same
      this.verifyNotEqual(data, outdata);
      if replace_channels
        % transpose opt_chans to compare with outdata
        this.verifyEqual(outdata, opt_chans);
      else
        % transpose and add amount of interpolated channels (in
        % this case all)
        opt_chans  = cellfun(@(f) f+numel(f), opt_chans, 'un', 0);
        this.verifyEqual(outdata, opt_chans);
      end
    end
  end
end