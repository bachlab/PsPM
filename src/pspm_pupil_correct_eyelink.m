function [sts, outchannel] = pspm_pupil_correct_eyelink(fn, options)
% ● Description
%   pspm_pupil_correct_eyelink performs pupil foreshortening error (PFE)
%   correction specifically for data recorded and imported with an SR Research
%   Eyelink eyetracker, following the steps described in reference [1]. 
%   For details of the exact scaling, see pspm_pupil_correct.
%   In order to perform PFE, we need both pupil and gaze data. 
%   Gaze data must be provided in mm. If gaze data is not in mm, 
%   it needs to be convert first using pspm_convert_gaze.
% ● Format
%   [sts, channel_index] = pspm_pupil_correct_eyelink(fn, options)
% ● Arguments
%   *          fn : Path to a PsPM-imported EyeLink data file. Must be a char.
%   ┌─────options
%   ├────────mode : Conversion mode. Must be one of 'auto' or 'manual'. If 'auto', then
%   │               optimized conversion parameters in Table 3 of the reference will be used. In
%   │               'auto' mode, options struct must contain C_z parameter described
%   │               below. Further, C_z must be one of 495, 525 or 625. The other
%   │               parameters will be set according to which of these three C_z is equal to.
%   │               If 'manual', then all of C_x, C_y, C_z, S_x, S_y, S_z fields must be
%   │               provided according to your recording setup. Note that in order to
%   │               use 'auto' mode, your camera-screen-eye setup must match exactly one
%   │               of the three sample setups given in the reference.
%   ├─────────C_z : See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
%   ├─────────C_x : [optional] See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
%   ├─────────C_y : [optional] See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
%   ├─────────S_x : [optional] See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
%   ├─────────S_y : [optional] See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
%   ├─────────S_z : [optional] See <a href="matlab:help pspm_pupil_correct">pspm_pupil_correct</a>
%   ├────.channel : [optional][numeric/string] [Default: 'pupil'] Channel ID to be
%   │               preprocessed. To process a specific eye, use 'pupil_l' or 'pupil_r'.
%   │               To process the combined left and right eye, use 'pupil_c'. The default
%   │               identifier 'pupil' will use the first existing option out of the
%   │               following:
%   │               (1) L-R-combined pupil;
%   │               (2) non-lateralised pupil;
%   │               (3) best eye pupil;
%   │               (4) any pupil channel.
%   │               If there are multiple channels of the specified type, only last one
%   │               will be processed. You can also specify the number of a channel.
%   └channel_action:  [optional] ['add'/'replace'] Defines whether output data should be
%                   added or the corresponding preprocessed channel should be replaced.
%                   (Default: 'add')
% ● Outputs
%   *  channel_index: index of channel containing the processed data
% ● References
%   [1] Hayes TR & Petrov AA (2016). Mapping and correcting the influence of
%       gaze position on pupil size measurements. Behavior Research Methods, 48(2), 510–527.
% ● History
%   Introduced in PsPM 5.1.2
%   Written in 2019 by Eshref Yozdemir (University of Zurich)
%   Maintained in 2021-2022 by Teddy

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
outchannel = 0;

if nargin < 2 || isempty(options)
  options = struct();
end

%% Default values

all_fieldnames = {'C_x', 'C_y', 'C_z', 'S_x', 'S_y', 'S_z'};
default_params = containers.Map('KeyType', 'double', 'ValueType', 'any');
default_params(495) = [103, -215, 495, -142, 206, 736];
default_params(525) = [165, -239, 525, -87, 140, 851];
default_params(625) = [183, -230, 625, -76, 156, 937];

%% input checks

if ~ischar(fn)
  warning('ID:invalid_input', 'Data file must be a char.');
  return;
end

%% create default arguments
options = pspm_options(options, 'pupil_correct_eyelink');
if options.invalid
  return
end

if strcmp(options.mode, 'manual')
  for field = all_fieldnames
    if ~isfield(options, field{1}) || options.(field{1}) == 0
      warning('ID:invalid_input',...
        'In manual mode, options must contain all geometry parameters');
      return;
    end
  end
end
if strcmpi(options.mode, 'auto')
  if ismember(options.C_z, cell2mat(keys(default_params)))
    for i = 1:numel(all_fieldnames)
      name_i = all_fieldnames{i};
      values = default_params(options.C_z);
      options.(name_i) = values(i);
    end
  else
    warning('ID:invalid_input',...
      'options.C_z must be one of 495, 525 or 625 in auto mode');
    return;
  end
end


%% load data
alldata = struct();
[sts_load, alldata.infos, alldata.data] = pspm_load_data(fn);
if sts_load < 1, return, end

% get pupil and gaze channels
[lsts, pupil_data, infos, pos_of_channel] = pspm_load_channel(alldata, options.channel, 'pupil');
if lsts ~= 1, return, end
[lsts, gaze_x_data, gaze_y_data] = pspm_load_gaze(alldata, pupil_data.header.chantype);
if lsts ~= 1; return; end

%% conditionally mandatory input checks
old_channeltype = pupil_data.header.chantype;

if ~strcmp(gaze_x_data.header.units, 'mm') || ~strcmp(gaze_y_data.header.units, 'mm')
    warning('ID:invalid_input', ... % change the ID:
        'Gaze channels needs to be in (mm). Convert gaze first with pspm_convert_gaze and re-run pspm_pupil_correct_eyelink.');
    return
end

% gaze_x_mm = gaze_x_data.data;
% gaze_y_mm = gaze_y_data.data;
% pupil = pupil_data.data;

outdata.infos = infos;
outdata.data  = {pupil_data; gaze_x_data; gaze_y_data};

%% correction
[sts_pupil_correct, pupil_corrected] = pspm_pupil_correct(outdata, options);
if sts_pupil_correct ~= 1; return; end

%% save data
pupil_data.data = pupil_corrected;
pupil_data.header.chantype = old_channeltype;
channel_str = num2str(options.channel);
o.msg.prefix = sprintf(...
  'PFE correction :: Input channel: %s -- Input channeltype: %s -- Output channeltype: %s --', ...
  channel_str, ...
  old_channeltype, ...
  pupil_data.header.chantype);
o.channel = pos_of_channel;
[lsts, out_id] = pspm_write_channel(fn, pupil_data, options.channel_action, o);
if lsts ~= 1; return; end

outchannel = out_id.channel;
sts = 1;
return




