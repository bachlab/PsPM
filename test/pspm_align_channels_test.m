classdef pspm_align_channels_test < pspm_testcase
  % PSPM_ALIGN_CHANNELS_TEST
  % unittest class for the pspm_align_channels function
  %__________________________________________________________________________
  % PsPM TestEnvironment
  % (C) 2019 Eshref Yozdemir (University of Zurich)

  properties(Constant)
    data_filename = ['ImportTestData' filesep 'ecg2hb' filesep 'tpspm_s102_s1.mat'];
  end

  properties
    orig_data = {};
  end

  methods(TestClassSetup)
    function prepare_data(this)
      [sts, ~, orig_data] = pspm_load_data(this.data_filename);
      assert(sts == 1);
      this.orig_data = orig_data;
    end
  end

  methods
    function verifyAllChannelsHaveSameDuration(this, data, channel_list, max_duration)
      for i=1:numel(channel_list)
        duration = calc_duration(data, channel_list(i));
        this.verifyEqual(duration, max_duration);
      end
    end
  end

  methods(Test)
    function invalid_input(this)
      % invalid induration
      this.verifyWarning(@()pspm_align_channels(this.orig_data, "5"), 'ID:invalid_input');
      this.verifyWarning(@()pspm_align_channels(this.orig_data, [5 10]), 'ID:invalid_input');
    end

    function lower_optional_duration(this)
      data = this.orig_data;
      optional_duration = 500;
      max_duration = calc_duration(data, 3);

      [sts, data_new, duration] = pspm_align_channels(data, optional_duration);
      assert(sts == 1);
      this.verifyEqual(max_duration, duration);
      this.verifyAllChannelsHaveSameDuration(data_new, 1:4, max_duration);
    end

    function same_optional_duration(this)
      data = this.orig_data;
      optional_duration = calc_duration(data, 3);

      [sts, data_new, duration] = pspm_align_channels(data, optional_duration);
      assert(sts == 1);
      this.verifyEqual(optional_duration, duration);
      this.verifyAllChannelsHaveSameDuration(data_new, 1:4, optional_duration);
    end

    function higher_optional_duration(this)
      data = this.orig_data;
      optional_duration = 5e3;

      [sts, data_new, duration] = pspm_align_channels(data, optional_duration);
      assert(sts == 1);
      this.verifyEqual(optional_duration, duration);
      this.verifyAllChannelsHaveSameDuration(data_new, 1:4, optional_duration);
    end

    function max_duration_is_given_in_events(this)
      data = this.orig_data;
      max_duration = 5e3;
      data{5}.data(end + 1) = max_duration;

      [sts, data_new, duration] = pspm_align_channels(data);
      assert(sts == 1);
      this.verifyEqual(max_duration, duration);
      this.verifyAllChannelsHaveSameDuration(data_new, 1:4, max_duration);
    end

    function only_one_channel_longer_others_same(this)
      data = this.orig_data;
      data{3}.data = [data{3}.data; data{3}.data(1:50000)];
      max_duration = calc_duration(data, 3);

      [sts, data_new, duration] = pspm_align_channels(data);
      assert(sts == 1);
      this.verifyEqual(duration, max_duration);
      this.verifyAllChannelsHaveSameDuration(data_new, 1:4, max_duration);
    end

    function only_one_channel_shorter_others_same(this)
      data = this.orig_data;
      data{1}.data = [data{1}.data; data{1}.data(1:3000)];
      data{2}.data = [data{2}.data; data{2}.data(1:3000)];
      data{3}.data = [data{3}.data; data{3}.data(1:3000)];
      max_duration = calc_duration(data, 3);

      [sts, data_new, duration] = pspm_align_channels(data);
      assert(sts == 1);
      this.verifyEqual(duration, max_duration);
      this.verifyAllChannelsHaveSameDuration(data_new, 1:4, max_duration);
    end

    function increasing_channel_lengths(this)
      data = this.orig_data;
      data{2}.data = [data{2}.data; data{2}.data(1:5242)];
      data{3}.data = [data{3}.data; data{3}.data(1:12427)];
      data{4}.data = [data{4}.data; data{4}.data(1:42543)];
      max_duration = calc_duration(data, 4);

      [sts, data_new, duration] = pspm_align_channels(data);
      assert(sts == 1);
      this.verifyEqual(duration, max_duration);
      this.verifyAllChannelsHaveSameDuration(data_new, 1:4, max_duration);
    end

    function two_same_others_shorter(this)
      data = this.orig_data;
      data{1}.data = [data{2}.data; data{2}.data(1:37500)];
      data{3}.data = [data{3}.data; data{3}.data(1:12500)];
      data{4}.data = [data{4}.data; data{4}.data(1:33000)];
      max_duration = calc_duration(data, 1);

      [sts, data_new, duration] = pspm_align_channels(data);
      assert(sts == 1);
      this.verifyEqual(duration, max_duration);
      this.verifyAllChannelsHaveSameDuration(data_new, 1:4, max_duration);
    end
  end
end

%% Calculate duration of a data channel. This only works with channels such as SCR, ECG that has a sampling rate.
function [duration] = calc_duration(data, chan)
duration = numel(data{chan}.data)/double(data{chan}.header.sr);
end
