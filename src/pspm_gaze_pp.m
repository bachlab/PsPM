function [sts, out_channel] = pspm_gaze_pp(fn, options)

% DESCRIPTION
% pspm_gaze_pp preprocesses gaze signals
%
% FORMAT
% [sts, out_channel] = pspm_gaze_pp(fn)
% [sts, out_channel] = pspm_gaze_pp(fn, options)
%
% VARIABLES
% fn		[string] Path to the PsPM file which contains the gaze data.
% options
% 	channel	[numeric/string, optional] Channel ID to be preprocessed, default: 'gaze'.
%
% (C) 2021 Teddy Chao (WCHN, UCL)
% Supervised by Professor Dominik Bach (WCHN, UCL)

%% 1 Initialise
global settings;
if isempty(settings)
  pspm_init;
end
sts = -1;

%% 2 Create default arguments
if nargin == 1
	options = struct();
end
if ~isfield(options, 'channel')
	options.channel = 'gaze';
end
if ~isfield(options, 'channel_action')
	options.channel_action = 'add';
end
if ~isfield(options, 'channel_combine')
	options.channel_combine = 'none';
end
if ~isfield(options, 'plot_data')
	options.plot_data = false;
end
	[lsts, default_settings] = pspm_gaze_pp_options();
	if lsts ~= 1
		return
	end
	if isfield(options, 'custom_settings')
		default_settings = assign_fields_recursively(default_settings, options.custom_settings);
	end
	options.custom_settings = default_settings;
	if ~isfield(options, 'segments')
		options.segments = {};
	end

	%% 3 Input checks
	if ~ismember(options.channel_action, {'add', 'replace'})
		warning('ID:invalid_input', 'Option channel_action must be either ''add'' or ''replace''');
		return
	end
	for seg = options.segments
		if ~isfield(seg{1}, 'start') || ~isfield(seg{1}, 'end') || ~isfield(seg{1}, 'name')
			warning('ID:invalid_input', 'Each segment structure must have .start, .end and .name fields');
			return
		end
	end

	%% 4 Load
	action_combine = ~strcmp(options.channel_combine, 'none');
	addpath(pspm_path('backroom'));
	[lsts, data_x] = pspm_load_single_chan(fn, options.channel, 'last', 'gaze_x');
	[lsts, data_y] = pspm_load_single_chan(fn, options.channel, 'last', 'gaze_y');
	if lsts ~= 1
		return
	end
	if action_combine
		[lsts, data_combine_x] = pspm_load_single_chan(fn, options.channel_combine, 'last', 'gaze_x');
		[lsts, data_combine_y] = pspm_load_single_chan(fn, options.channel_combine, 'last', 'gaze_y');
		if lsts ~= 1
			return
		end
		if strcmp(get_eye(data{1}.header.chantype), get_eye(data_combine{1}.header.chantype))
			warning('ID:invalid_input', 'options.channel and options.channel_combine must specify different eyes');
			return;
		end
		if data{1}.header.sr ~= data_combine{1}.header.sr
			warning('ID:invalid_input', 'options.channel and options.channel_combine data have different sampling rate');
			return;
		end
		if ~strcmp(data{1}.header.units, data_combine{1}.header.units)
			warning('ID:invalid_input', 'options.channel and options.channel_combine data have different units');
			return;
		end
		if numel(data{1}.data) ~= numel(data_combine{1}.data)
			warning('ID:invalid_input', 'options.channel and options.channel_combine data have different lengths');
			return;
		end
		old_chantype = sprintf('%s and %s', data{1}.header.chantype, data_combine{1}.header.chantype);
	else
		data_combine{1}.data = [];
		old_chantype = data{1}.header.chantype;
	end
	rmpath(pspm_path('backroom'));

	%% 5 preprocess
	[lsts, smooth_signal_x] = preprocess(data_x, data_combine_x, options.segments, options.custom_settings, options.plot_data);
	[lsts, smooth_signal_y] = preprocess(data_y, data_combine_y, options.segments, options.custom_settings, options.plot_data);
	if lsts ~= 1
		return
	end

	%% 6 save
	channel_str = num2str(options.channel);
	o.msg.prefix = sprintf(...
	'Gaze X preprocessing :: Input channel: %s -- Input chantype: %s -- Output chantype: %s --', ...
	channel_str, ...
	old_chantype, ...
	smooth_signal_x.header.chantype);
	o.msg.prefix = sprintf(...
	'Gaze Y preprocessing :: Input channel: %s -- Input chantype: %s -- Output chantype: %s --', ...
	channel_str, ...
	old_chantype, ...
	smooth_signal_y.header.chantype);
	[lsts, out_id] = pspm_write_channel(fn, smooth_signal_x, options.channel_action, o);
	[lsts, out_id] = pspm_write_channel(fn, smooth_signal_y, options.channel_action, o);
	if lsts ~= 1
		return
	end
	out_channel = out_id.channel;
	sts = 1;
end
