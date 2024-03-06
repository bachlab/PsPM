classdef pspm_extract_segments_test < matlab.unittest.TestCase
  % ● Description
  % unittest class for pspm_extract_segments
  % ● Authorship
  % (C) 2019 Laure Ciernik (ETH Zurich)
  properties
    datafiles = {};
    testfile_prefix = 'datafile';
    nan_output_prefix = 'nan_output';
    outputfile_prefix = 'segments'
    options = struct('length', 5)
  end
  properties(TestParameter)
    % different NaN ratios
    nan_ratio = {0,0.25,0.50,0.75,1};
    % different nr. of trials
    nr_trial = {3,9};
    % nan-output possibilities
    nan_output = {'none','screen'};
    % generate outputfile
    outputfile = {0,1};
  end
  methods
    function [control_data,timing] = generate_segment_data_manual(this, fn,trials,nan_ratio)
      this.datafiles{end+1} = fn;
      % nr. of trials
      nr_trials = trials;
      % length one trial
      dur_trial = 3.5;
      % possibilities of intertrialinterval(ITI)
      iti_options = [11,13,15];
      % get randrom ITI between all trials
      iti_idx = randi([1 3],nr_trials,1);
      iti = iti_options(iti_idx)';
      % generate onsets when each trial begins
      onsets = cumsum(iti + 3.5)-3.5;
      % fix sample rate
      sr = 500;
      % fix duration of whole recording in seconds
      length_sec = 170;
      % choose basis function
      [bs,x] = pspm_bf_scrf(1/sr);
      % figure, plot(x,bs);
      signal_len = length(x);
      % change onsets values from seconds to sample idx
      onsets_idx = onsets .* sr;
      % generate trial matrix
      trial_mat = zeros(nr_trials,length_sec*sr);
      % fill matrix with signal shifted over time
      for i=1:nr_trials
        start = onsets_idx(i);
        stop = onsets_idx(i)+signal_len-1;
        if stop <=length_sec*sr
          trial_mat(i,start:stop) = bs';
        else
          trial_mat(i,start:length_sec*sr-1) = bs(1:length_sec*sr-start)';
        end
      end
      % generate final signal y
      y = sum(trial_mat,1);
      % manipulate Data with NaN vals
      NaN_idx = randperm(length(y),round(nan_ratio*length(y)));
      if ~isempty(NaN_idx)
        y(NaN_idx)=nan;
      end
      data{1}.data = y';
      data{1}.header.chantype = 'scr';
      data{1}.header.units = 'unknown';
      data{1}.header.sr = sr;
      infos.duration = length_sec;
      infos.durationsinfos ='Recording duration in seconds';
      save(fn, 'infos', 'data');
      trial_idx_perm = randi([1,3],nr_trials,1);
      samples_per_trial = dur_trial*sr;
      % 3 conditions A,B, and C. For each create an array holding the trials that
      % belong to that condition, the correspinding sample intervals for duration of 3.5
      conditions = {'conA','condB', 'condC'};
      cond_idx = cell(3,1);
      cond_idx{1} = sort(find(trial_idx_perm==1));
      cond_idx{2} = sort(find(trial_idx_perm==2));
      cond_idx{3} = sort(find(trial_idx_perm==3));
      val_cond = cellfun(@(x) ~isempty(x),cond_idx);
      val_idx = find(val_cond);
      nr_val_cond = numel(val_idx);
      control_data = cell(nr_val_cond,1);
      cond_names = conditions(val_idx);
      cond_onsets =  cell(numel(val_idx),1);
      cond_consets_idx = cell(nr_val_cond,1);
      cond_trial_data = cell(nr_val_cond,1);
      cond_durations = cell(nr_val_cond,1);
      cond_trial_mean = cell(nr_val_cond,1);
      cond_trial_std = cell(nr_val_cond,1);
      cond_nan_trial = cell(nr_val_cond,1);
      cond_nan_total = cell(nr_val_cond,1);
      for i = 1:nr_val_cond
        idx = cond_idx{val_idx(i)};
        cond_onsets{i} = onsets(idx);
        cond_consets_idx{i} = onsets_idx(idx);
        cond_trial_data{i} = zeros(samples_per_trial,numel(idx));
        cond_durations{i} = 3.5* ones(numel(idx),1);
        for k=1:numel(idx)
          cond_trial_data{i}(:,k) = y(cond_consets_idx{i}(k):min(length_sec*sr,(cond_consets_idx{i}(k)+samples_per_trial-1)));
        end
        cond_trial_mean{i} = nanmean(cond_trial_data{i}, 2);
        cond_trial_std{i}  = nanstd(cond_trial_data{i}, [], 2);
        cond_nan_trial{i}  = mean(isnan(cond_trial_data{i}),1);
        cond_nan_total{i}  = mean(cond_nan_trial{i});
      end
      timing{1}.onsets = cond_onsets;
      timing{1}.names = cond_names;
      timing{1}.durations = cond_durations;
      for i = 1:nr_val_cond
        control_data{i}.trial_idx         = cond_idx{val_idx(i)};
        control_data{i}.trial_data        = cond_trial_data{i}';
        control_data{i}.cond_name         = cond_names{i};
        control_data{i}.mean              = cond_trial_mean{i}';
        control_data{i}.std               = cond_trial_std{i}';
        control_data{i}.trial_nan_percent = cond_nan_trial{i}'*100;
        control_data{i}.total_nan_percent = cond_nan_total{i}*100;
      end
    end
  end
  methods(TestMethodTeardown)
    function cleanup(this)
      for i=1:length(this.datafiles)
        f = this.datafiles{i};
        if exist(f, 'file')
          delete(f);
        end
      end
    end
  end
  methods(Test)
    function invalid_input(this)
      % no input
      this.verifyWarning(@() pspm_extract_segments(), 'ID:invalid_input');
      % wrong input
      this.verifyWarning(@() pspm_extract_segments('a','b'), 'ID:invalid_input');
      % test invalid manual input
      fn = pspm_find_free_fn(this.testfile_prefix, '.mat');
      nr_t = 9;
      [~,timing] = generate_segment_data_manual(this, fn,nr_t,0);
      % not enough input elements
      this.verifyWarning(@() pspm_extract_segments('file',fn,0), 'ID:invalid_input');
      % wrong input elements
      this.verifyWarning(@() pspm_extract_segments('file',struct('a',10),0,timing), 'ID:invalid_input');
      this.verifyWarning(@() pspm_extract_segments('file',[1,3],logical(32),timing), 'ID:invalid_input');
      this.verifyWarning(@() pspm_extract_segments('file',fn,'a',timing), 'ID:invalid_input');
      this.verifyWarning(@() pspm_extract_segments('file',fn,{'a'},timing), 'ID:invalid_input');
      % test invalid auto input
      this.verifyWarning(@() pspm_extract_segments('auto',{1}), 'ID:invalid_input');
      this.verifyWarning(@() pspm_extract_segments('auto','some'), 'ID:invalid_input');
    end
    function test_manual_length(this,nr_trial,nan_ratio)
      % generate data
      fn = pspm_find_free_fn(this.testfile_prefix, '.mat');
      [control_data,timing] = generate_segment_data_manual(this, fn,nr_trial,nan_ratio);
      % do the actual test with options length all other option field
      % are set to default
      [sts,out] = this.verifyWarningFree(@() ...
        pspm_extract_segments('file', fn, 0, timing,struct('length',3.5)));
      this.verifyEqual(sts, 1);
      % check contains segments
      this.verifyTrue(isfield(out,'segments'));
      % out recieve same nr.of segments
      this.verifyEqual(numel(out.segments),numel(control_data));
      % for each segment check if function result is correct
      for i = 1:numel(control_data)
        control = control_data{i};
        seg = out.segments{i};
        % this.verifyEqual(seg.trial_idx,control.trial_idx);
        this.verifyTrue(isequaln(seg.data,control.trial_data));
        this.verifyEqual(seg.name,control.cond_name);
        this.verifyEqual(seg.mean,control.mean);
        this.verifyEqual(seg.std,control.std);
        this.verifyTrue(all(abs(seg.trial_nan_percent-control.trial_nan_percent)<1e-12));
        this.verifyTrue(abs(seg.total_nan_percent-control.total_nan_percent)<1e-12);
      end
    end
 function test_auto_mode_glm_with_markers(this)
      import matlab.unittest.constraints.IsEqualTo
      import matlab.unittest.constraints.RelativeTolerance
      load(['ImportTestData' filesep 'fitted_models' filesep 'glm_scr_cond_marker.mat'], 'glm');
      load(['ImportTestData' filesep 'fitted_models' filesep 'glm_orig_data.mat'], 'data');
      if ~isfield(glm.input, 'channel') && isfield(glm.input, 'chan')
        glm.input.channel = glm.input.chan;
        glm.input = rmfield(glm.input,'chan'); % rename the field channel to chan
      end
      marker = data{5}.data;
      assert(numel(glm.input.timing) == 1);
      input_data = glm.input.data{1};
      this.verifyTrue(all(input_data == data{1}.data));
      input_onset = glm.input.timing{1}.onsets;
      sr = glm.input.sr;
      newsr = glm.input.filter.down;
      for i = 1:numel(input_onset)
        signal_indices = round(marker(input_onset{i})) * sr;
        this.verifyTrue(all(signal_indices == round(glm.timing.onsets{i} * sr / newsr)));
      end
      for i = 1:numel(glm.timing.multi.durations)
        glm.timing.multi.durations{i} = 5*i*ones(1, numel(glm.timing.multi.durations{i}));
      end
      [sts, out] = pspm_extract_segments('model', glm, this.options);
      this.verifyEqual(sts, 1);
      seg = out.segments;
      this.verifyEqual(numel(seg), 3);
      this.verifyTrue(all(size(seg{1}.data) == [30, this.options.length * sr]));
      this.verifyTrue(all(size(seg{2}.data) == [15, this.options.length * sr]));
      this.verifyTrue(all(size(seg{3}.data) == [15, this.options.length * sr]));
       % consistency of returned data
      this.verifyThat(nanmean(seg{1}.data, 1), IsEqualTo(seg{1}.mean, 'Within', RelativeTolerance(1e-10)));
      this.verifyThat(nanstd(seg{1}.data, 0, 1), IsEqualTo(seg{1}.std, 'Within', RelativeTolerance(1e-10)));
      this.verifyThat(nanmean(seg{2}.data, 1), IsEqualTo(seg{2}.mean, 'Within', RelativeTolerance(1e-10)));
      this.verifyThat(nanstd(seg{2}.data, 0, 1), IsEqualTo(seg{2}.std, 'Within', RelativeTolerance(1e-10)));
      this.verifyThat(nanmean(seg{3}.data, 1), IsEqualTo(seg{3}.mean, 'Within', RelativeTolerance(1e-10)));
      this.verifyThat(nanstd(seg{3}.data, 0, 1), IsEqualTo(seg{3}.std, 'Within', RelativeTolerance(1e-10)));
      % compute statistics from scratch
      for i = 1:numel(glm.timing.multi.durations)
        all_vecs = [];
        seg_len = this.options.length * sr;
        onset_i = glm.timing.multi.onsets{i};
        for j = 1:numel(onset_i)
          onset = round(onset_i(j) * sr);
          all_vecs = [all_vecs, input_data(onset : onset + seg_len - 1)];
        end
        all_vecs = all_vecs';
        expected_mean = nanmean(all_vecs, 1);
        expected_std = nanstd(all_vecs, 0, 1);
        expected_sem = expected_std ./ sqrt(size(all_vecs, 1));
        nan_mat = isnan(all_vecs);
        expected_nan_perc = sum(nan_mat, 2) / size(all_vecs, 2);
        expected_total_nan_perc = sum(nan_mat(:)) / prod(size(all_vecs));
        this.verifyThat(expected_mean, IsEqualTo(seg{i}.mean, 'Within', RelativeTolerance(1e-10)));
        this.verifyThat(expected_std, IsEqualTo(seg{i}.std, 'Within', RelativeTolerance(1e-10)));
        this.verifyThat(expected_sem, IsEqualTo(seg{i}.sem, 'Within', RelativeTolerance(1e-10)));
        this.verifyThat(expected_nan_perc, IsEqualTo(seg{i}.trial_nan_percent, 'Within', RelativeTolerance(1e-10)));
        this.verifyThat(expected_total_nan_perc, IsEqualTo(seg{i}.total_nan_percent, 'Within', RelativeTolerance(1e-10)));
      end
    end
    function test_auto_mode_glm_with_seconds(this)
      import matlab.unittest.constraints.IsEqualTo
      import matlab.unittest.constraints.RelativeTolerance
      load(['ImportTestData' filesep 'fitted_models' filesep 'glm_scr_cond_second.mat'], 'glm');
      load(['ImportTestData' filesep 'fitted_models' filesep 'glm_orig_data.mat'], 'data');
      assert(numel(glm.input.timing) == 1);
      input_data = glm.input.data{1};
      this.verifyTrue(all(input_data == data{1}.data));
      input_onset = glm.input.timing{1}.onsets;
      sr = glm.input.sr;
      newsr = glm.input.filter.down;
      for i = 1:numel(input_onset)
        signal_indices = round(input_onset{i}) * sr;
        this.verifyTrue(all(signal_indices == round(glm.timing.onsets{i} * sr / newsr)));
      end
      for i = 1:numel(glm.timing.multi.durations)
        glm.timing.multi.durations{i} = 5*i*ones(1, numel(glm.timing.multi.durations{i}));
      end
      [sts, out] = pspm_extract_segments('model', glm, this.options);
      this.verifyEqual(sts, 1);
      seg = out.segments;
      this.verifyEqual(numel(seg), 3);
      this.verifyTrue(all(size(seg{1}.data) == [30, this.options.length * sr]));
      this.verifyTrue(all(size(seg{2}.data) == [15, this.options.length * sr]));
      this.verifyTrue(all(size(seg{3}.data) == [15, this.options.length * sr]));
      % consistency of returned data
      this.verifyThat(nanmean(seg{1}.data, 1), IsEqualTo(seg{1}.mean, 'Within', RelativeTolerance(1e-10)));
      this.verifyThat(nanstd(seg{1}.data, 0, 1), IsEqualTo(seg{1}.std, 'Within', RelativeTolerance(1e-10)));
      this.verifyThat(nanmean(seg{2}.data, 1), IsEqualTo(seg{2}.mean, 'Within', RelativeTolerance(1e-10)));
      this.verifyThat(nanstd(seg{2}.data, 0, 1), IsEqualTo(seg{2}.std, 'Within', RelativeTolerance(1e-10)));
      this.verifyThat(nanmean(seg{3}.data, 1), IsEqualTo(seg{3}.mean, 'Within', RelativeTolerance(1e-10)));
      this.verifyThat(nanstd(seg{3}.data, 0, 1), IsEqualTo(seg{3}.std, 'Within', RelativeTolerance(1e-10)));
      % compute statistics from scratch
      for i = 1:numel(glm.timing.multi.durations)
        all_vecs = [];
        seg_len = this.options.length * sr;
        onset_i = glm.timing.multi.onsets{i};
        for j = 1:numel(onset_i)
          onset = round(onset_i(j) * sr);
          all_vecs = [all_vecs, input_data(onset : onset + seg_len - 1)];
        end
        all_vecs = all_vecs';
        expected_mean = nanmean(all_vecs, 1);
        expected_std = nanstd(all_vecs, 0, 1);
        expected_sem = expected_std ./ sqrt(size(all_vecs, 1));
        nan_mat = isnan(all_vecs);
        expected_nan_perc = sum(nan_mat, 2) / size(all_vecs, 2);
        expected_total_nan_perc = sum(nan_mat(:)) / prod(size(all_vecs));
        this.verifyThat(expected_mean, IsEqualTo(seg{i}.mean, 'Within', RelativeTolerance(1e-10)));
        this.verifyThat(expected_std, IsEqualTo(seg{i}.std, 'Within', RelativeTolerance(1e-10)));
        this.verifyThat(expected_sem, IsEqualTo(seg{i}.sem, 'Within', RelativeTolerance(1e-10)));
        this.verifyThat(expected_nan_perc, IsEqualTo(seg{i}.trial_nan_percent, 'Within', RelativeTolerance(1e-10)));
        this.verifyThat(expected_total_nan_perc, IsEqualTo(seg{i}.total_nan_percent, 'Within', RelativeTolerance(1e-10)));
      end
    end
    function test_auto_mode_dcm(this)
      import matlab.unittest.constraints.IsEqualTo
      import matlab.unittest.constraints.RelativeTolerance
      load(['ImportTestData' filesep 'fitted_models' filesep 'dcm_scr_trial.mat'], 'dcm');
      input_data = dcm.input.scr;
      sr = dcm.input.sr;
      trial_sizes = cumsum([60, 60, 38, 21]);
      [sts, out] = pspm_extract_segments('model', dcm, this.options);
      this.verifyEqual(sts, 1);
      seg = out.segments;
      this.verifyEqual(numel(seg), 1);
      this.verifyEqual(sr * this.options.length, size(seg{1}.data, 2));
      % % consistency of returned data
      this.verifyThat(nanmean(seg{1}.data, 1), IsEqualTo(seg{1}.mean, 'Within', RelativeTolerance(1e-10)));
      this.verifyThat(nanstd(seg{1}.data, 0, 1), IsEqualTo(seg{1}.std, 'Within', RelativeTolerance(1e-10)));
      % compute statistics from scratch
      seg_len = this.options.length * sr;
      all_vecs = [];
      for i = 1:numel(input_data)
          onset_i = dcm.input.trlstart{i};
          for j = 1:numel(onset_i)
              onset = round(onset_i(j) * sr);
              all_vecs = [all_vecs, input_data{i}(onset : onset + seg_len - 1)];
          end
      end
      all_vecs = all_vecs';
      expected_mean = nanmean(all_vecs, 1);
      expected_std = nanstd(all_vecs, 0, 1);
      expected_sem = expected_std ./ sqrt(size(all_vecs, 1));
      nan_mat = isnan(all_vecs);
      expected_nan_perc = sum(nan_mat, 2) / size(all_vecs, 2);
      expected_total_nan_perc = sum(nan_mat(:)) / prod(size(all_vecs));
      i = 1;
      this.verifyThat(expected_mean, IsEqualTo(seg{i}.mean, 'Within', RelativeTolerance(1e-10)));
      this.verifyThat(expected_std, IsEqualTo(seg{i}.std, 'Within', RelativeTolerance(1e-10)));
      this.verifyThat(expected_sem, IsEqualTo(seg{i}.sem, 'Within', RelativeTolerance(1e-10)));
      this.verifyThat(expected_nan_perc, IsEqualTo(seg{i}.trial_nan_percent, 'Within', RelativeTolerance(1e-10)));
      this.verifyThat(expected_total_nan_perc, IsEqualTo(seg{i}.total_nan_percent, 'Within', RelativeTolerance(1e-10)));
    end
  end
end