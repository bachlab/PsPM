function [sts, out] = pspm_simple_qa(data, sr, options)
	% pspm_simple_qa applies simple SCR quality assessment rulesets
	% Rule 1:       Microsiemens values must be within range (0.05 to 60)
	% Rule 2:       Absolute slope of value change must be less than 10 microsiemens per second
	%
	% FORMAT:
	%	[sts, out] = pspm_simple_qa(data, sr, options)
	%
	% INPUT ARGUMENTS:
	%	data:                           A numeric vector. Data should be in microsiemens.
	%	sr:                             Samplerate of the data. This is needed to determine the slopes unit.
	%	options:                        A struct with algorithm specific settings.
	%		min:                        Minimum value in microsiemens (default: 0.05).
	%		max:                        Maximum value in microsiemens (default: 60).
	%		slope:                      Maximum slope in microsiemens per sec (default: 10).
	%		missing_epochs_filename:	If provided will create a .mat file saving the epochs if it exists.
	%									The path can be specified, but if not the file will be saved in the current folder.
	%									For instance, abc will create abc.mat
	%		deflection_threshold:       Define an threshold in original data units for a slope to pass to be considerd in the filter.
	%									This is useful, for example, with oscillatory wave data due to limited A/D bandwidth.
	%									The slope may be steep due to a jump between voltages but we likely do not want to consider this to be filtered.
	%									A value of 0.1 would filter oscillatory behaviour with threshold less than 0.1v but not greater
	%									Default: 0.1
	%		data_island_threshold:      A float in seconds to determine the maximum length of data between NaN epochs.
	%									Islands of data shorter than this threshold will be removed.
	%									Default: 0 s - no effect on filter
	%		expand_epochs:              A float in seconds to determine by how much data on the flanks of artefact epochs will be removed.
	%									Default: 0.5 s
	%		change_data:				A numerical value to choose whether to change the data or not
	%									Default: 1 (true)
	%
	% OUTPUT ARGUMENTS:
	%	sts:							?
	%	out:							The final output of the processed data.
	%									Can be the changed to the data with epochs removed if options.change_data is set to be positive.
	%
	% FUNCTIONS:
	%	filter_to_epochs:				Return the start and end points of epoches (2D array) by the given filter (1D array).
	%
	% KEY VARIABLES:
	%	filt: 							A filtering array consisting of 0 and 1 for selecting data whose y and slope are both within the range of interest.
	%	filt_epochs:					A filtering array consisting of 0 and 1 for selecting epochs.
	%	filt_range: 					A filtering array consisting of 0 and 1 for selecting data within the range of interest.
	%	filt_slope: 					A filtering array consisting of 0 and 1 for selecting data whose slope is within the range of interest.
	%
	%__________________________________________________________________________
	% PsPM 5.0
	% 2009-2017 Tobias Moser (University of Zurich)
	% 2020 Samuel Maxwell & Dominik Bach (UCL)

	% $Id: pspm_pp.m 450 2017-07-03 15:17:02Z tmoser $
	% $Rev: 450 $

	%% Initialise
	global settings;
	if isempty(settings)
		pspm_init;
	end
	out = [];
	sts = -1;

	%% Set default values
	if ~exist('options', 'var')
		options = struct();
	end
	if ~isfield(options, 'min')
		options.min = 0.05;
	end
	if ~isfield(options, 'max')
		options.max = 60;
	end
	if ~isfield(options, 'slope')
		options.slope = 10;
	end
	if ~isfield(options, 'deflection_threshold')
		options.deflection_threshold = 0.1;
	end
	if ~isfield(options, 'data_island_threshold')
		options.data_island_threshold = nan;
	end
	if ~isfield(options, 'expand_epochs')
		options.expand_epochs = 0.5;
	end
	if ~isfield(options, 'change_data')
		options.change_data = 1;
	end

	%% Sanity checks
	if ~isnumeric(data)
		warning('ID:invalid_input', 'Argument ''data'' must be numeric.'); return;
	elseif ~isnumeric(sr)
		warning('ID:invalid_input', 'Argument ''sr'' must be numeric.'); return;
	elseif ~any(size(data) > 1)
		warning('ID:invalid_input', 'Argument ''data'' should contain > 1 data points.'); return;
	elseif ~isnumeric(options.min)
		warning('ID:invalid_input', 'Argument ''options.min'' must be numeric.'); return;
	elseif ~isnumeric(options.max)
		warning('ID:invalid_input', 'Argument ''options.max'' must be numeric.'); return;
	elseif ~isnumeric(options.slope)
		warning('ID:invalid_input', 'Argument ''options.slope'' must be numeric.'); return;
	elseif isfield(options, 'missing_epochs_filename')
		if ~ischar(options.missing_epochs_filename)
			warning('ID:invalid_input', 'Argument ''options.missing_epochs_filename'' must be char array.'); return;
		end
		[pth, ~, ext] = fileparts(options.missing_epochs_filename);
		if ~isempty(pth) && exist(pth,'dir')~=7
			warning('ID:invalid_input','Please specify a valid output directory if you want to save missing epochs.');
			return;
		end
		if ~isempty(ext)
			warning('ID:invalid_input','Please specify a valid filename (without extension) if you want to save missing epochs.');
			return;
		end
	end
	if options.change_data == 0 && ~isfield(options, 'missing_epochs_filename')
		warning('No changes will be recorded, as epochs are expected to be dismissed and data are expected to be unchanged');
	end

	%% Create filters
	data_changed = NaN(size(data));
	filt_range = data < options.max & data > options.min;
	filt_slope = true(size(data));
	filt_slope(2:end) = abs(diff(data)*sr) < options.slope;
	if (options.deflection_threshold ~= 0) && ~all(filt_slope==1)
		slope_epochs = filter_to_epochs(filt_slope);
		for r = slope_epochs' 
			if range(data(r(1):r(2))) < options.deflection_threshold
				filt_slope(r(1):r(2)) = 1;
			end
		end
	end
	% combine filters
	filt = filt_range & filt_slope;

	%% Find data islands and expand artefact islands
	if isempty(find(filt==0, 1))
		warning('Epoch was empty based on the current settings.');
	else
		if options.data_island_threshold > 0 || options.expand_epochs > 0
        
			% work out data epochs
			filt_epochs = filter_to_epochs(1-filt); % gives data (rather than artefact) epochs
        
			if options.expand_epochs > 0
				% remove data epochs too short to be shortened
				epoch_duration = diff(filt_epochs, 1, 2);
				filt_epochs(epoch_duration < 2 * ceil(options.expand_epochs * sr), :) = [];
				% shorten data epochs
				filt_epochs(:, 1) = filt_epochs(:, 1) + ceil(options.expand_epochs * sr);
				filt_epochs(:, 2) = filt_epochs(:, 2) - ceil(options.expand_epochs * sr);
			end
        
			% correct possibly negative values
			filt_epochs(filt_epochs(:, 2) < 1, 2) = 1;
        
			if options.data_island_threshold > 0
				epoch_duration = diff(filt_epochs, 1, 2);
				filt_epochs(epoch_duration < options.data_island_threshold * sr, :) = [];
			end
        
			% write back into data
			index(filt_epochs(:, 1)) = 1;
			index(filt_epochs(:, 2)) = -1;
			filt = (cumsum(index(:)) == 1); % (thanks Jan: https://www.mathworks.com/matlabcentral/answers/324955-replace-multiple-intervals-in-array-with-nan-no-loops)
		end
	end
	data_changed(filt) = data(filt);

	%% Write epochs to mat if missing_epochs_filename option is present
	if isfield(options, 'missing_epochs_filename')
		if ~isempty(find(filt == 0, 1))
			epochs = filter_to_epochs(filt);
		else
			epochs = [];
		end
		save(options.missing_epochs_filename, 'epochs');
	end

	% Change data if options.change_data is set positive
	if options.change_data == 1
		out = data_changed;
	else
		out = data;
	end
	sts = 1;
end

function epochs = filter_to_epochs(filt)	% Return the start and end points of the excluded interval
	epoch_on = find(diff(filt) == -1) + 1;	% Return the start points of the excluded interval
	epoch_off = find(diff(filt) == 1);		% Return the end points of the excluded interval
	if ~isempty(epoch_on) && ~isempty(epoch_off)
		if (epoch_on(end) > epoch_off(end))     % ends on
			epoch_off(end + 1) = length(filt);	% Include the end point of the whole data sequence
		end
		if (epoch_on(1) > epoch_off(1))         % starts on
			epoch_on = [ 1; epoch_on ];			% Include the start point of the whole data sequence
		end
	elseif ~isempty(epoch_on) && isempty(epoch_off)
		epoch_off = length(filt);
	elseif isempty(epoch_on) && ~isempty(epoch_off)
		epoch_on = 1;
	end
	epochs = [ epoch_on, epoch_off ];
end