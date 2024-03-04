classdef pspm_dcm_test < pspm_testcase
  % ● Description
  % unittest class for the pspm_dcm function
  % ● Authorship
  % (C) 2017 Tobias Moser (University of Zurich)
  properties
    modelfile_prfx = 'dcm_testmodel';
    hra_path = 'ImportTestData/dcm/HRA1';
    hra_file_prfx = 'HRA_1_';
    datafiles = {};
  end
  methods(TestClassTeardown)
    function cleanup_testfile(this)
      for i=1:numel(this.datafiles)
        d = this.datafiles{i};
        if exist(d, 'file')
          % recopy backup file to data file
          % and delete backup file
          delete(d);
        else
          warning(['Could not clean up datafile ''%s'' ', ...
            'because file was found'], d)
        end
      end
    end
  end
  methods (Test)
    function invalid_input(this)
      % empty arguments
      this.verifyWarning(@() pspm_dcm(), 'ID:invalid_input');
      % get new fn
      fn = pspm_find_free_fn(this.modelfile_prfx, '.mat');
      % wrong model
      [s, ~] = this.get_hra_files(1);
      timing = this.extract_hra_timings(1);
      correct_model = struct(...
        'modelfile', fn, ...
        'datafile', s, ...
        'timing', {timing} ...
        );
      wrong_model = correct_model;
      % invalid_data file
      wrong_model.datafile = '';
      this.verifyWarning(@() pspm_dcm(wrong_model), 'ID:nonexistent_file');
      % not all mandatory fields
      % modelfiles
      wrong_model = rmfield(correct_model, 'modelfile');
      this.verifyWarning(@() pspm_dcm(wrong_model), 'ID:invalid_input');
      % datafile
      wrong_model = rmfield(correct_model, 'datafile');
      this.verifyWarning(@() pspm_dcm(wrong_model), 'ID:invalid_input');
      % timing
      wrong_model = rmfield(correct_model, 'timing');
      this.verifyWarning(@() pspm_dcm(wrong_model), 'ID:invalid_input');
      % invalid timing
      wrong_model = correct_model;
      wrong_model.timing = {};
      this.verifyWarning(@() pspm_dcm(wrong_model), 'ID:number_of_elements_dont_match');
      % model settings
      % invalid filter
      wrong_model = correct_model;
      wrong_model.filter = '';
      this.verifyWarning(@() pspm_dcm(wrong_model), 'ID:invalid_input');
      % invalid channel
      wrong_model = correct_model;
      wrong_model.channel = '';
      this.verifyWarning(@() pspm_dcm(wrong_model), 'ID:invalid_input');
      % invalid norm
      wrong_model = correct_model;
      wrong_model.norm = '';
      this.verifyWarning(@() pspm_dcm(wrong_model), 'ID:invalid_input');
      % wrong options
      this.verifyWarning(@() pspm_dcm(correct_model, 'a'), ...
        'ID:invalid_input');
      % options
      % numeric fields
      num_fields = {'depth', 'sfpre', 'sfpost', 'sffreq', 'sclpre', ...
        'sclpost', 'aSCR_sigma_offset'};
      for f = 1:numel(num_fields)
        fl = num_fields{f};
        values = {'a', {}};
        for v = 1:numel(values)
          options = struct(fl, values(v));
          this.verifyWarning(@() pspm_dcm(correct_model, options), ...
            'ID:invalid_input');
        end
      end
      % boolean fields
      bool_fields = {'crfupdate', 'indrf', 'getrf', 'dispwin', ...
        'dispsmallwin', 'nosave'};
      for f = 1:numel(bool_fields)
        fl = bool_fields{f};
        values = {'a', 2};
        for v = 1:numel(values)
          options = struct(fl, values(v));
          this.verifyWarning(@() pspm_dcm(correct_model, options), ...
            'ID:invalid_input');
        end
      end
      % cell fields
      cell_fields = {'trlnames', 'eventnames'};
      for f = 1:numel(cell_fields)
        fl = cell_fields{f};
        values = {'a', 2};
        for v = 1:numel(values)
          options = struct(fl, values{v});
          this.verifyWarning(@() pspm_dcm(correct_model, options),...
            'ID:invalid_input');
        end
      end
      % string or 0
      %rf
      spec_fields = {'rf'};
      for f = 1:numel(spec_fields)
        fl = spec_fields{f};
        values = {{}, 2};
        for v = 1:numel(values)
          options = struct(fl, values{v});
          this.verifyWarning(@() pspm_dcm(correct_model, options), ...
            'ID:invalid_input');
        end
      end
    end
    function valid_input(this)
      test_hra1_flex_cs(this);
      test_hra1_flex_cs_missing(this);
    end
  end
  methods 
    function test_hra1_flex_cs(this)
      for i=1:1
        % find free filename
        fn = pspm_find_free_fn(this.modelfile_prfx, '_simplified.mat');
        % do not delete model file
        % this.datafiles{end+1} = fn;
        [df, ~] = this.get_hra_files(i);
        [timing, eventnames, trialnames] = this.extract_hra_timings(i);
        model = struct(...
          'modelfile', fn, ...
          'datafile', df, ...
          'timing', {timing} ...
          );
        options = struct( ...
          'dispwin', 0,...
          'trlnames', {trialnames},...
          'eventnames', {eventnames} ...
          );
        this.verifyWarningFree(@() pspm_dcm(model, options));
      end
    end
    function test_hra1_flex_cs_missing(this)
      for i=1:1
        % find free filename
        fn = pspm_find_free_fn(this.modelfile_prfx, '_simplified.mat');
        % do not delete model file
        % this.datafiles{end+1} = fn;
        [df, ~] = this.get_hra_files(i);
        [timing, eventnames, trialnames] = this.extract_hra_timings(i);
        model = struct(...
          'modelfile', fn, ...
          'datafile', df, ...
          'timing', {timing}, ...
          'missing', {[13.491,16.551]} ...
          );
        options = struct( ...
          'dispwin', 0,...
          'trlnames', {trialnames},...
          'eventnames', {eventnames} ...
          );
        this.verifyWarningFree(@() pspm_dcm(model, options));
      end
    end
    function [timing, eventnames, trialnames] = ...
        extract_hra_timings(this, subject)
      [s, c] = this.get_hra_files(subject);
      cg_data = load(c);
      [~, ~, sp_data] = pspm_load_data(s);
      timing = cell(1,2);
      cs_onset = sp_data{1}.data;
      % use SOA=0.1 for simplified test
      % use SOA=3.5 for realworld test
      SOA = 0.1; 
      us_onset = sp_data{1}.data + SOA; 
      timing{1} = [cs_onset us_onset];
      timing{2} = us_onset;
      eventnames = {'CS', 'US'};
      trialnames = cell(size(cg_data.data, 1), 1);
      trialnames(cg_data.data == 1,1) = {'CS-'};
      trialnames(cg_data.data == 2,1) = {'CS+'};
    end
    function [spike, cogent] = get_hra_files(this, subject)
      spike = [this.hra_path '/' this.hra_file_prfx 'spike_' ...
        sprintf('%02i', subject) '_simplified.mat'];
      cogent = [this.hra_path '/' this.hra_file_prfx 'cogent_' ...
        sprintf('%02i', subject) '_simplified.mat'];
    end
  end
end
