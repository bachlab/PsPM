function [sts, import, sourceinfo] = pspm_get_smi(datafile, import)
% ● Description
%   pspm_get_smi is the main function for import of SensoMotoric Instruments
%   iView X EyeTracker files.
% ● Format
%   [sts, import, sourceinfo] = pspm_get_smi(datafile, import);
% ● Arguments
%       datafile: String or cell array of strings. The size of the cell
%                 array can be 1 or 2. If datafile is string, it must be the
%                 path to the sample file containing eye measuremnts. The file
%                 must be stored in ASCII format. If datafile is a cell array,
%                 the first element must be the path to the sample file defined
%                 above. The optional second string in the cell array can be
%                 the event file containing blink/saccade events.
%                 The file must be stored in ASCII format.
%  ┌──────import: [struct] import job structure
%  │              [mandatory fields]
%  ├───────.type: Type of the channel. Must be one of pupil_l, pupil_r,
%  │              gaze_x_l, gaze_y_l, gaze_x_r, gaze_y_r, blink_l, blink_r,
%  │              saccade_l, saccade_r, marker, custom. If the given
%  │              channel type does not exist in the given datafile, it
%  │              will be filled with NaNs and a warning will be emitted.
%  │              Specified custom channels must correspond to some form of
%  │              pupil/gaze channels. In addition, when the channel type
%  │              is custom, no postprocessing/conversion is performed by
%  │              pspm_get_smi and the channel is returned directly as it
%  │              is in the given datafile.
%  │              The gaze values returned are in the given target_unit.
%  │              (x, y) = (0, 0) coordinate represents the top left corner
%  │              of the calibration area. x coordinates grow towards right
%  │              and y coordinates grow towards bottom. The gaze
%  │              coordinates can be negative or larger than calibration
%  │              area axis length. These correspond to gaze positions
%  │              outside the calibration area.
%  │              Since there are multiple ways to specify pupil size in
%  │              SMI files, pspm_get_smi selects the channel according to
%  │              the following precendence order (earlier items have
%  │              precedence):
%  │              1. Mapped Diameter (mm)
%  │              2. Dia X (mm)
%  │              3. Dia (mm2)
%  │              4. Dia X (pixel)
%  │              5. Dia (pixel2)
%  │              If a pixel/pixel2 channels is chosen, it is NOT converted
%  │              to a mm/mm2 channel. It is returned as it is. In
%  │              mm2/pixel2 case, the pupil is assumed to be a circle.
%  │              Therefore, diameter d from area a is calculated as
%  │              2*sqrt(a/pi).
%  │              [optional fields]
%  ├────.channel: If .type is custom, the index of the channel to import
%  │              must be specified using this option.
%  ├.stimulus_resolution:
%  │              An array of length 2 storing the screen resolution of
%  │              the whole stimulus window in pixels. This resolution is
%  │              required in order to perform pixel to mm conversions. If
%  │              not given, no manual conversion is performed by get_smi
%  │              and all the values are returned as they are in the datafile.
%  ├.target_unit: the unit to which the gaze data should be converted. Used
%  │              only if stimulus_resolution is specified. (Default: mm)
%  │              [Each import structure will get the following output fields]
%  ├───────.data: Data channel corresponding to the input channel type or
%  │              custom channel id.
%  ├──────.units: Units of the channel.
%  ├─────────.sr: Sampling rate.
%  └────.chan_id: Channel index of the imported channel in the raw data columns.
% ● History
%   Written in 2019 by Eshref Yozdemir (University of Zurich)
%   Maintained in 2022 by Teddy

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];
addpath(pspm_path('Import','smi'));
if ~iscell(import)
  import = {import};
end
for i = 1:numel(import)
  not_custom = ~strcmpi(import{i}.type, 'custom');
  not_marker = ~strcmpi(import{i}.type, 'marker');
  if ~isfield(import{i}, 'target_unit') && not_custom && not_marker
    import{i}.target_unit = 'mm';
  end
  is_gaze = contains(lower(import{i}.type), 'gaze');
  if is_gaze && ~isfield(import{i}, 'stimulus_resolution')
    import{i}.stimulus_resolution = [-1 -1];
  end
end
if ischar(datafile)
  datafile = {datafile};
end
if ~assert_proper_datafile_format(datafile); return; end
if ~assert_custom_import_channels_has_channel_field(import); return; end
if ~assert_all_channeltypes_are_supported(settings, import); return; end
try
  if numel(datafile) == 2
    data = import_smi(datafile{1}, datafile{2});
    experiment_begin_time = data{1}.raw(1, 1);
    for i = 1:numel(data)
      data{i}.raw(:, 1) = data{i}.raw(:, 1) - experiment_begin_time;
      data{i}.markers = max(0, data{i}.markers - experiment_begin_time);
    end
  else
    warning(['get_smi will only read pupil and/or gaze data. ',...
      'No information about blinks or saccades will be generated. ',...
      'In order to generate this information you have to specify an event file.']);
    data = import_smi(datafile{1});
  end
catch err
  warning(err.identifier, err.message);
  return;
end
if numel(data) > 1
  if ~assert_same_sample_rate(data); return; end
  if ~assert_same_eyes_observed(data); return; end
  if ~assert_sessions_are_one_after_another(data); return; end
end
[data_concat, markers, mi_values, mi_names] = concat_sessions(data);
addpath(pspm_path('Import','eyelink'));
chan_struct = data{1}.channel_columns;
eyes_observed = lower(data{1}.eyesObserved);
if strcmpi(eyes_observed, settings.lateral.char.l)
  mask_chans = {'L Blink', 'L Saccade'};
elseif strcmpi(eyes_observed, settings.lateral.char.r)
  mask_chans = {'R Blink', 'R Saccade'};
else
  mask_chans = {'L Blink', 'L Saccade', 'R Blink', 'R Saccade'};
end
data_concat = set_blinks_saccades_to_nan(...
  data_concat,...
  chan_struct,...
  mask_chans,...
  @(x) contains(x, 'L '));
rmpath(pspm_path('Import','eyelink'));
sampling_rate = data{1}.sampleRate;
units = data{1}.units;
raw_columns = data{1}.raw_columns;
screen_size_mm = data{1}.stimulus_dimension;
calib_area_px = [data{1}.gaze_coords.xmax, data{1}.gaze_coords.ymax];
viewing_dist = data{1}.head_distance;
num_import_cells = numel(import);
for k = 1:num_import_cells
  import{k}.data = [];
  chan_id = NaN;
  import{k}.units = 'N/A';
  import{k}.sr = sampling_rate;
  channeltype = lower(import{k}.type);
  channellateral = pspm_eye(channeltype, 'channel2lateral');
  if isempty(channellateral)
    flag_channeltype_hasnt_eyes_obs = 0;
  else
    flag_channeltype_hasnt_eyes_obs = ~contains(eyes_observed,channellateral) && ~strcmp(eyes_observed, settings.lateral.char.c);
  end
  if flag_channeltype_hasnt_eyes_obs
    % no import
  elseif strcmpi(channeltype, 'marker')
    [import{k}, chan_id] = import_marker_chan(import{k}, markers, mi_values, mi_names, size(data_concat, 1), sampling_rate);
  elseif contains(channeltype, 'pupil')
    [import{k}, chan_id] = import_pupil_chan(import{k}, data_concat, viewing_dist, raw_columns, chan_struct, units, sampling_rate);
  elseif contains(channeltype, 'gaze')
    [import{k}, chan_id] = import_gaze_chan(import{k}, data_concat, screen_size_mm, calib_area_px, raw_columns, chan_struct, sampling_rate);
  elseif contains(channeltype, 'blink') || contains(channeltype, 'saccade')
    [import{k}, chan_id] = import_blink_or_saccade_chan(import{k}, data_concat, raw_columns, chan_struct, units, sampling_rate);
  elseif strcmpi(channeltype, 'custom')
    [import{k}, chan_id] = import_custom_chan(import{k}, data_concat, raw_columns, chan_struct, units, sampling_rate);
  else
    warning('ID:pspm_error', 'This branch should not have been taken. Please report this error to PsPM dev team'); return;
  end
  if isempty(import{k}.data)
    import{k}.data = NaN(size(data_concat, 1), 1);
    warning('ID:channel_not_contained_in_file', ...
      sprintf(['Cannot import channel type %s, as data for this eye', ...
      ' does not seem to be present in the datafile. ', ...
      'Will create artificial channel with NaN values.'], import{k}.type));
  end
  sourceinfo.channel{k, 1} = sprintf('Column %02.0f', chan_id);
  sourceinfo.chan_stats{k,1} = struct();
  n_nan = sum(isnan(import{k}.data));
  n_data = numel(import{k}.data);
  sourceinfo.chan_stats{k}.nan_ratio = n_nan / n_data;
end
sourceinfo.date = data{1}.record_date;
sourceinfo.time = data{1}.record_time;
sourceinfo.screen_size_mm = screen_size_mm;
sourceinfo.calib_area_px = calib_area_px;
sourceinfo.viewing_distance_mm = viewing_dist;
sourceinfo.eyes_observed = eyes_observed;
sourceinfo.best_eye = eye_with_smaller_nan_ratio(import, eyes_observed);
rmpath(pspm_path('Import','smi'));
sts = 1;
return

function proper = assert_proper_datafile_format(datafile)
proper = is_proper_datafile_format(datafile);
if ~proper
  warning('ID:invalid_input', 'Given datafile is not valid. Please check the documentation');
end

function proper = is_proper_datafile_format(datafile)
proper = true;
if ~iscell(datafile)
  proper = false;
  return;
end
if numel(datafile) ~= 1 && numel(datafile) ~= 2
  proper = false;
  return;
end
if ~isstr(datafile{1})
  proper = false;
  return;
end
if numel(datafile) == 2 && ~isstr(datafile{2})
  proper = false;
  return;
end

function proper = assert_same_sample_rate(data)
proper = true;
sample_rates = [];
for i = 1:numel(data)
  sample_rates(end + 1) = data{i}.sampleRate;
end
if any(diff(sample_rates))
  sample_rates_str = sprintf('%d ', sample_rates);
  error_msg = sprintf(['Cannot concatenate multiple sessions with', ...
    ' different sample rates. Found sample rates: %s'], sample_rates_str);
  warning('ID:invalid_data_structure', error_msg);
  proper = false;
  return;
end

function equal = all_strs_in_cell_array_are_equal(cell_arr)
equal = true;
for i = 1:numel(cell_arr) - 1
  if ~all(strcmpi(cell_arr{i}, cell_arr{i+1}))
    equal = false;
    break;
  end
end

function proper = assert_same_eyes_observed(data)
proper = true;
eyes_observed = cellfun(@(x) x.eyesObserved, data, 'UniformOutput', false);
same_eyes = all_strs_in_cell_array_are_equal(eyes_observed);
channel_headers = cellfun(@(x) x.channel_columns, data, 'UniformOutput', false);
same_headers = all_strs_in_cell_array_are_equal(channel_headers);
if ~(same_eyes && same_headers)
  error_msg = 'Cannot concatenate multiple sessions with different eye observation or channel headers';
  warning('ID:invalid_data_structure', error_msg);
  proper = false;
  return;
end

function proper = assert_sessions_are_one_after_another(data)
proper = true;
timesteps_concat = cell2mat(cellfun(@(x) x.raw(:, 1), data, 'UniformOutput', false));
neg_diff_indices = find(diff(timesteps_concat) < 0);
if ~isempty(neg_diff_indices)
  first_neg_idx = neg_diff_indices(1);
  error_msg = sprintf('Cannot concatenate multiple sessions with decreasing timesteps: samples %d and %d', first_neg_idx, first_neg_idx + 1);
  warning('ID:invalid_data_structure', error_msg);
  proper = false;
  return;
end

function proper = assert_custom_import_channels_has_channel_field(import)
proper = true;
for i = 1:numel(import)
  if strcmpi(import{i}.type, 'custom') && ~isfield(import{i}, 'channel')
    warning('ID:invalid_input', sprintf('Custom channel in import{%d} has no channel id to import', i));
    proper = false;
    return;
  end
end

function proper = assert_all_channeltypes_are_supported(settings, import)
proper = true;
viewpoint_idx = find(strcmpi('smi', {settings.import.datatypes.short}));
viewpoint_types = settings.import.datatypes(viewpoint_idx).channeltypes;
for k = 1:numel(import)
  input_type = import{k}.type;
  if ~any(strcmpi(input_type, viewpoint_types))
    error_msg = sprintf('Channel %s is not an SMI supported type', input_type);
    warning('ID:channel_not_contained_in_file', error_msg);
    proper = false;
    return;
  end
end

function expect_list = map_pspm_header_to_smi_headers(pspm_channeltype)
type_parts = split(pspm_channeltype, '_');
if strcmpi(type_parts{1}, 'pupil')
  which_eye = upper(type_parts{2});
  expect_list = {[which_eye ' Dia'], [which_eye ' Dia X'], [which_eye ' Area'], [which_eye ' Mapped Diameter']};
elseif strcmpi(type_parts{1}, 'gaze')
  coord = upper(type_parts{2});
  which_eye = upper(type_parts{3});
  expect_list = {[which_eye ' POR ' coord]};
elseif strcmpi(type_parts{1}, 'blink')
  which_eye = upper(type_parts{2});
  expect_list = {[which_eye, ' Blink']};
elseif strcmpi(type_parts{1}, 'saccade')
  which_eye = upper(type_parts{2});
  expect_list = {[which_eye ' Saccade']};
end

function [import_cell, chan_id] = import_marker_chan(import_cell, markers, mi_values, mi_names, n_rows, sampling_rate)
import_cell.marker = 'continuous';
% by default use 'ascending' flank for SMI data
if ~isfield(import_cell,'flank')
  import_cell.flank = 'ascending';
end
import_cell.sr     = sampling_rate;
import_cell.data = false(n_rows, 1);
marker_indices = 1 + markers * sampling_rate;
import_cell.data(int64(marker_indices)) = true;
import_cell.units = 'unknown';
markerinfo.name = mi_names;
markerinfo.value = mi_values;
import_cell.markerinfo = markerinfo;
chan_id = -1;

function [import_cell, chan_id] = import_pupil_chan(import_cell, data_concat, viewing_dist, raw_columns, chan_struct, units, sampling_rate)
smi_headers = map_pspm_header_to_smi_headers(import_cell.type);

% try mapped diameter method first
mapped_diam_header = smi_headers(contains(smi_headers, 'Mapped Diameter'));
mapped_diam_idx_in_data = find(contains(chan_struct, mapped_diam_header));
if ~isempty(mapped_diam_idx_in_data)
  import_cell.data = data_concat(:, mapped_diam_idx_in_data);
  chan_id_concat = mapped_diam_idx_in_data;
  import_cell.units = 'mm';
else
  all_channels = [];
  for i = 1:numel(smi_headers)
    possible_pupil_indices = find(contains(chan_struct, smi_headers{i}));
    all_channels = [all_channels possible_pupil_indices];
  end
  all_channels = unique(all_channels);
  if isempty(all_channels)
    chan_id = NaN;
    return;
  else
    % check if there is any channel in mm
    channel_indices_in_mm = find(contains(units(all_channels), 'mm'));
    all_channels_in_mm = all_channels(channel_indices_in_mm);
    if ~isempty(all_channels_in_mm)
      % prefer diameter to area
      mm_units = units(all_channels_in_mm);
      mm_diameter_indices = find(contains(mm_units, 'diameter'));
      if ~isempty(mm_diameter_indices)
        chan_id_concat = all_channels_in_mm(mm_diameter_indices(1));
        import_cell.data = data_concat(:, chan_id_concat);
      else
        chan_id_concat = all_channels_in_mm(1);
        area_mm2 = data_concat(:, chan_id_concat);
        import_cell.data = (2 / sqrt(pi)) * sqrt(area_mm2);
      end
      import_cell.units = 'mm';
    else
      % prefer diameter to area
      all_channels_in_px = all_channels;
      px_units = units(all_channels_in_px);
      px_diameter_indices = find(contains(px_units, 'diameter'));
      if ~isempty(px_diameter_indices)
        chan_id_concat = all_channels_in_px(px_diameter_indices(1));
        dia_px = data_concat(:, chan_id_concat);
        import_cell.data = dia_px;
      else
        chan_id_concat = all_channels_in_px(1);
        area_px2 = data_concat(:, chan_id_concat);
        import_cell.data = (2 / sqrt(pi)) * sqrt(area_px2);
      end
      import_cell.units = 'pixel';
    end
  end
end
chan_id = find(contains(raw_columns, chan_struct{chan_id_concat}));
import_cell.sr = sampling_rate;

function [import_cell, chan_id] = import_gaze_chan(import_cell, data_concat, screen_size_mm, calib_area_px, raw_columns, chan_struct, sampling_rate)
screen_size_px = import_cell.stimulus_resolution;
smi_headers = map_pspm_header_to_smi_headers(import_cell.type);
% in case of gaze, there is only one possible header
smi_header = smi_headers{1};

chan_id_concat = find(contains(chan_struct, smi_header), 1, 'first');
if isempty(chan_id_concat)
  chan_id = NaN;
  return;
end
gaze_px = data_concat(:, chan_id_concat);

if contains(lower(smi_header), ' x')
  axis_id = 1;
elseif contains(lower(smi_header), ' y')
  axis_id = 2;
else
  error('ID:pspm_error', 'This branch should not have been taken. Please report this error to PsPM dev team');
end

n_pixels_along_axis = screen_size_px(axis_id);
axis_len_mm = screen_size_mm(axis_id);

if n_pixels_along_axis == -1
  import_cell.data = gaze_px;
  import_cell.units = 'pixel';
  import_cell.range = [0, calib_area_px(axis_id)];
else
  mm_over_px = axis_len_mm / n_pixels_along_axis;
  import_cell.data = gaze_px * mm_over_px;
  [~, import_cell.data] = pspm_convert_unit(import_cell.data, 'mm', import_cell.target_unit);
  [~, rangemax] = pspm_convert_unit(calib_area_px(axis_id) * mm_over_px, 'mm', import_cell.target_unit);
  import_cell.range = [0, rangemax];
  import_cell.units = import_cell.target_unit;
end
chan_id = find(contains(raw_columns, chan_struct{chan_id_concat}));
import_cell.sr = sampling_rate;

function [import_cell, chan_id] = import_blink_or_saccade_chan(import_cell, data_concat, raw_columns, chan_struct, units, sampling_rate)
smi_headers = map_pspm_header_to_smi_headers(import_cell.type);
% in case of blink/saccade, there is only one possible header
smi_header = smi_headers{1};

chan_id_concat = find(contains(chan_struct, smi_header), 1, 'first');
if isempty(chan_id_concat)
  chan_id = NaN;
  return;
end
chan_id = -1;
import_cell.data = data_concat(:, chan_id_concat);
import_cell.units = units{chan_id_concat};
import_cell.sr = sampling_rate;

function [import_cell, chan_id] = import_custom_chan(import_cell, data_concat, raw_columns, chan_struct, units, sampling_rate)
n_cols = size(raw_columns, 2);
chan_id = import_cell.channel;
if chan_id < 1
  warning('ID:invalid_input', sprintf('Custom channel id %d is less than 1', chan_id));
  return
end
if chan_id > n_cols
  warning('ID:invalid_input', sprintf('Custom channel id (%d) is greater than number of columns (%d) in sample file', chan_id, n_cols));
  return;
end
custom_channel_header = raw_columns{chan_id};
chan_id_in_concat = find(strcmpi(custom_channel_header, chan_struct));
if isempty(chan_id_in_concat)
  warning('ID:invalid_input', sprintf('Custom channel %s cannot be imported using get_smi', custom_channel_header));
  return;
end
import_cell.data = data_concat(:, chan_id_in_concat);
import_cell.units = units{chan_id_in_concat};
import_cell.data_header = chan_struct{chan_id_in_concat};
import_cell.sr = sampling_rate;


function [data_concat, markers, mi_values, mi_names] = concat_sessions(data)
% Concatenate multiple sessions into contiguous arrays, inserting NaN or N/A fields
% in between two sessions when there is a time gap.
%
% data: Cell array containing data for multiple sessions.
%
% data_concat : Matrix formed by concatenating data{i}.channels arrays according to
%               timesteps. If end and begin of consecutive channels are far apart,
%               NaNs are inserted.
% markers     : Array of marker seconds, formed by simply concatening data{i}.marker.times.
% mi_values   : Array of marker values, formed by simply concatening data{i}.marker.value.
% mi_names    : Array of marker names, formed by simply concatening data{i}.marker.name.
%
data_concat = [];
markers = [];
mi_values = [];
mi_names = {};

microsecond_col_idx = 1;
n_cols = size(data{1}.channels, 2);
sr = data{1}.sampleRate;
last_time = data{1}.raw(1, microsecond_col_idx);
microsec_to_sec = 1e-6;

for c = 1:numel(data)
  start_time = data{c}.raw(1, microsecond_col_idx);
  end_time = data{c}.raw(end, microsecond_col_idx);

  n_missing = round((start_time - last_time) * microsec_to_sec * sr);
  if n_missing > 0
    curr_len = size(data_concat, 1);
    data_concat(end + 1:(end + n_missing), 1:n_cols) = NaN(n_missing, n_cols);
  end

  n_data_in_session = size(data{c}.channels, 1);
  n_markers_in_session = numel(data{c}.markerinfos.name);

  data_concat(end + 1:(end + n_data_in_session), 1:n_cols) = data{c}.channels;
  markers(end + 1:(end + n_markers_in_session), 1) = data{c}.markers' * microsec_to_sec;
  mi_values(end + 1:(end + n_markers_in_session),1) = data{c}.markerinfos.value';
  mi_names(end + 1:(end + n_markers_in_session),1) = data{c}.markerinfos.name';

  last_time = end_time;
end

function best_eye = eye_with_smaller_nan_ratio(import, eyes_observed)
if numel(eyes_observed) == 1
  best_eye = lower(eyes_observed);
else
  eye_L_max_nan_ratio = 0;
  eye_R_max_nan_ratio = 0;
  for i = 1:numel(import)
    left_data = ~isempty(regexpi(import{i}.type, '_l', 'once'));
    right_data = ~isempty(regexpi(import{i}.type, '_r', 'once'));
    if left_data
      eye_L_max_nan_ratio = max(eye_L_max_nan_ratio, sum(isnan(import{i}.data)));
    elseif right_data
      eye_R_max_nan_ratio = max(eye_R_max_nan_ratio, sum(isnan(import{i}.data)));
    end
  end
  if eye_L_max_nan_ratio > eye_R_max_nan_ratio
    best_eye = 'r';
  else
    best_eye = 'l'; % if equal, set left
  end
end
