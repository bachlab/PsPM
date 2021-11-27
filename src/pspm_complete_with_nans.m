function data = pspm_complete_with_nans(data, t_beg, sr, output_samples)
% Complete the given data that possibly has missing samples at the
% beginning and at the end. The amount of missing samples is determined
% by sampling rate and the data beginning second t_beg.
sec_between_upsampled_samples = 1 / sr;
n_missing_at_the_beg = round(t_beg / sec_between_upsampled_samples);
n_missing_at_the_end = output_samples - numel(data) - n_missing_at_the_beg;
data = [NaN(n_missing_at_the_beg, 1) ; data ; NaN(n_missing_at_the_end, 1)];
end
