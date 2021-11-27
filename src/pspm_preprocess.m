function [sts, smooth_signal] = pspm_preprocess(data, data_combine, segments, custom_settings, plot_data, channel_type)
sts = 0;

% 1 definitions
combining = ~isempty(data_combine{1}.data);
data_is_left = strcmpi(pspm_get_eye(data{1}.header.chantype), 'l');
n_samples = numel(data{1}.data);
sr = data{1}.header.sr;
diameter.t_ms = transpose(linspace(0, 1000 * (n_samples-1) / sr, n_samples));

if data_is_left
	diameter.L = data{1}.data;
	diameter.R = data_combine{1}.data;
else
	diameter.L = data_combine{1}.data;
	diameter.R = data{1}.data;
end
if size(diameter.L, 1) == 1
	diameter.L = transpose(diameter.L);
end
if size(diameter.R, 1) == 1
	diameter.R = transpose(diameter.R);
end
segmentStart = transpose(cell2mat(cellfun(@(x) x.start, segments, 'uni', false)));
segmentEnd = transpose(cell2mat(cellfun(@(x) x.end, segments, 'uni', false)));
segmentName = transpose(cellfun(@(x) x.name, segments, 'uni', false));
segmentTable = table(segmentStart, segmentEnd, segmentName);
new_sr = custom_settings.valid.interp_upsamplingFreq;
upsampling_factor = new_sr / sr;
desired_output_samples = round(upsampling_factor * numel(data{1}.data));

% 2 load lib
libbase_path = pspm_path('ext',[channel_type, '-size'], 'code');
libpath = {fullfile(libbase_path, 'dataModels'), fullfile(libbase_path, 'helperFunctions')};
addpath(libpath{:});

% 3 filtering
model = PupilDataModel(data{1}.header.units, diameter, segmentTable, 0, custom_settings);
model.filterRawData();
if combining
	smooth_signal.header.chantype = [channel_type, '_pp_c'];
elseif contains(data{1}.header.chantype, '_pp')
	smooth_signal.header.chantype = data{1}.header.chantype;
else
	marker = strfind(data{1}.header.chantype, '_');
	marker = marker(1);
	smooth_signal.header.chantype = ...
		[data{1}.header.chantype(1:marker-1),...
		'_pp_',...
		data{1}.header.chantype(marker+1:end)];
end
smooth_signal.header.units = data{1}.header.units;
smooth_signal.header.sr = new_sr;
smooth_signal.header.segments = segments;

% 4 store signal and valid samples
try
	model.processValidSamples();
	if combining
		validsamples_obj = model.meanPupil_ValidSamples;
		smooth_signal.header.valid_samples.data_l = model.leftPupil_ValidSamples.samples.pupilDiameter;
		smooth_signal.header.valid_samples.sample_indices_l = model.leftPupil_RawData.isValid;
		smooth_signal.header.valid_samples.valid_percentage_l = model.leftPupil_ValidSamples.validFraction;
		smooth_signal.header.valid_samples.data_r = model.rightPupil_ValidSamples.samples.pupilDiameter;
		smooth_signal.header.valid_samples.sample_indices_r = model.rightPupil_RawData.isValid;
		smooth_signal.header.valid_samples.valid_percentage_r = model.rightPupil_ValidSamples.validFraction;
	else
		if data_is_left
			validsamples_obj = model.leftPupil_ValidSamples;
			rawdata_obj = model.leftPupil_RawData;
		else
			validsamples_obj = model.rightPupil_ValidSamples;
			rawdata_obj = model.rightPupil_RawData;
		end
		smooth_signal.header.valid_samples.data = validsamples_obj.samples.pupilDiameter;
		smooth_signal.header.valid_samples.sample_indices = find(rawdata_obj.isValid);
		smooth_signal.header.valid_samples.valid_percentage = validsamples_obj.validFraction;
	end

	smooth_signal.data = validsamples_obj.signal.pupilDiameter;
	smooth_signal.data = complete_with_nans(smooth_signal.data, validsamples_obj.signal.t(1), ...
		new_sr, desired_output_samples);

	% 5 store segment information
	if ~isempty(segments)
		seg_results = model.analyzeSegments();
		seg_results = seg_results{1};
		if combining
			seg_eyes = {'left', 'right', 'mean'};
		elseif data_is_left
			seg_eyes = {'left'};
		else
			seg_eyes = {'right'};
		end
		smooth_signal.header.segments = pspm_store_segment_stats(smooth_signal.header.segments, seg_results, seg_eyes, channel_type);
	end

	if plot_data
		model.plotData();
	end
catch err
	% https://www.mathworks.com/matlabcentral/answers/225796-rethrow-a-whole-error-as-warning
	warning('ID:invalid_data_structure', getReport(err, 'extended', 'hyperlinks', 'on'));
	smooth_signal.data = NaN(desired_output_samples, 1);
	sts = -1;
end
rmpath(libpath{:});
if sts == 0
	sts = 1;
end
end
