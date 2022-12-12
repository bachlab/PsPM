function varargout = pspm_split_sessions(datafile, markerchannel, options)
% ● Description
%   pspm_split_sessions splits experimental sessions/blocks, based on
%   regularly incoming markers, for example volume or slice markers from an
%   MRI scanner, or based on a vector of split points that is defined in
%   terms of markers. The first and the last marker will define the start of
%   the first session and the end of the last session.
% ● Format
%   newdatafile = pspm_split_sessions(datafile, markerchannel, options)
% ● Arguments
%            datafile:  a file name
%       markerchannel:  (optional)
%                       number of the channel containing the relevant markers.
%   ┌─────────options:
%   ├──────.overwrite:  [logical] (0 or 1)
%   │                   Define whether to overwrite existing output files or not.
%   │                   Default value: determined by pspm_overwrite.
%   ├─────────.max_sn:  Define the maximum of sessions to look for.
%   │                   Default is 10 (defined by settings.split.max_sn)
%   ├.min_break_ratio:  Minimum for ratio
%   │                   [(session distance)/(maximum marker distance)]
%   │                   Default is 3 (defined by settings.split.min_break_ratio)
%   ├────.splitpoints:  Alternatively, directly specify session start
%   │                   (excluding the first session starting at the
%   │                   first marker) in terms of markers (vector of integer)
%   ├─────────.prefix:  [numeric, unit:second, default:0]
%   │                   Defines how long data before start trim point should
%   │                   also be included. First marker will be at
%   │                   t = options.prefix.
%   ├─────────.suffix:  [numeric, unit:second, default:0]
%   │                   Defines how long data after the end trim point should be
%   │                   included. Last marker will be at t = duration (of
%   │                   session) - options.suffix.
%   ├───────.randomITI: [default:0]
%   │                   Tell the function to use all the markers to evaluate
%   │                   the mean distance between them.
%   │                   Usefull for random ITI since it reduces the variance.
%   ├─────────.verbose: [default:1]
%   │                   printing processing messages
%   └─────────.missing: Optional name of an epoch file, e.g. containing a
%                       missing epochs definition in s. This is then split
%                       accordingly.
% ● Outputs
%          newdatafile: cell array of filenames for the individual sessions
%         newepochfile: cell array of missing epoch filenames for the individual
%                       sessions (empty if no options.missing not specified)
% ● Developer's notes
%   epochs have a fixed sampling rate of 10000
%   REMARK for suffix and prefix:
%   Markers in the prefix and suffix intervals are ignored. Only markers
%   between the splitpoints are considered for each session, to avoid
%   duplication of markers.
% ● History
%   Introduced in PsPM 5.1.1
%   Written in 2021 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Updated and maintained in 2022 by Teddy Chao (UCL)

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
newdatafile = [];

% 1.1 Check input arguments
if nargin<1
  warning('ID:invalid_input', 'No data.\n');
  return;
end

% 1.2 Set options
if ~exist('options','var') || isempty(options) || ~isstruct(options)
  options = struct();
end
options = pspm_options(options, 'split_sessions');
if options.invalid
  return
end
% 1.3 Handle data files
% 1.3.1 check data file argument
if ~ischar(datafile)
  warning('ID:invalid_input', 'Data file must be a char.');
  return;
end

% 1.4 Check if prefix is positiv and suffix is negative
if options.prefix > 0
  warning('ID:invalid_input', 'Prefix must be negative.');
  return;
elseif options.suffix < 0
  warning('ID:invalid_input', 'Suffix must be positive.');
  return;
end
if nargin < 2
  markerchannel = 0;
elseif isempty(markerchannel)
  markerchannel = 0;
elseif ~isnumeric(markerchannel)
  warning('ID:invalid_input', 'Marker channel needs to be a number.\n');
  return;
end

%% 2 Work on all data files

% 2.1 Obtain data
if options.verbose
  fprintf('Splitting %s ... \n', datafile);
end
[sts_load_data, ininfos, indata, filestruct] = pspm_load_data(datafile); % check and get datafile ---
if ~sts_load_data
  warning('ID:invalid_input', 'Could not load data.');
  return;
end

% 2.2 Handle missing epochs
if options.missing
  % makes sure the epochs are in seconds and not empty
  [sts_get_timing, missing_time] = pspm_get_timing('epochs', options.missing, 'seconds');
  if ~sts_get_timing
    warning('ID:invalid_input', 'Could not load missing epochs.');
  end
  missingsr = 10000; % dummy sample rate, should be higher than data sampling rates (but no need to make it dynamic)
  duration_index = round(missingsr * ininfos.duration);
  indx = zeros(1,duration_index); % indx should be a one-dimensional array?
  missing = pspm_time2index(missing_time, missingsr, duration_index); % convert epochs in sec to datapoints

  % allow splitting empty missing epochs
  if ~isempty(missing)
    indx(missing(:, 1)) = 1;
    indx(missing(:, 2)+1) = -1;
  end
  dp_epochs = (cumsum(indx(:)) == 1);
  % extract fileparts for later
  [p_epochs, f_epochs, ex_epochs] = fileparts(options.missing);
end

% 2.3 Handle markers

% 2.3.1 Define marker channel
if markerchannel == 0
  markerchannel = filestruct.posofmarker;
end
mrk = indata{markerchannel}.data;
newdatafile = cell(0);
newepochfile = cell(0);

% 2.3.2 Find split points
if isempty(options.splitpoints)
  imi = sort(diff(mrk), 'descend');
  if min(imi)*options.min_break_ratio > max(imi)
    fprintf('  The file won''t be split. No possible split points found in marker channel %i.\n', markerchannel);
  elseif numel(mrk) <=  options.max_sn
    fprintf('  The file won''t be split. Not enough markers in marker channel %i.\n', markerchannel);
  end
  imi(1:(options.max_sn-1)) = [];
  cutoff = options.min_break_ratio * max(imi);
  splitpoint = find(diff(mrk) > cutoff)+1;
else
  splitpoint = options.splitpoints;
  if numel(mrk) < max(splitpoint)
      warning('ID:invalid_input', 'Splitpoint definition assumes more markers than there are in the file.');
      return
  end
end

% 2.3.3 Define trim points and adjust suffix
if isempty(splitpoint)
  return;
else
  % initialise
  suffix = zeros(1,(numel(splitpoint)+1));
  for sn = 1:(numel(splitpoint)+1)
    if sn == 1
      trimpoint(sn, :) = [1, max(splitpoint(sn) - 1, 1)];
    elseif sn > numel(splitpoint)
      trimpoint(sn, :) = [max(splitpoint(sn - 1), 1), numel(mrk)];
    else
      trimpoint(sn, :) = [splitpoint(sn - 1), max(splitpoint(sn) - 1, 1)];
    end

    if sn > numel(splitpoint)
      trimpoint(sn, 2) = numel(mrk);
    else
      trimpoint(sn, 2) = max(1, splitpoint(sn) - 1);
    end

    if options.suffix == 0
      if trimpoint(sn, 1) == trimpoint(sn, 2) || options.randomITI
        suffix(sn) = mean(diff(mrk));
      else
        suffix(sn) = mean(diff(mrk(trimpoint(sn, 1):trimpoint(sn, 2))));
      end
    else
      suffix(sn) = options.suffix;
    end
  end

  % 2.4 Split files
  for sn = 1:size(trimpoint,1)
    % 2.4.1 Determine filenames
    [p, f, ex] = fileparts(datafile);
    newdatafile{sn} = fullfile(p, sprintf('%s_sn%02.0f%s', f, sn, ex));
    if ischar(options.missing)
      newepochfile{sn} = fullfile(p_epochs, sprintf('%s_sn%02.0f%s', f_epochs, sn, ex_epochs));
    end
    % 2.4.2 Split data
    trimoptions = struct('drop_offset_markers', 1);
    newdata = pspm_trim(struct('data', {indata}, 'infos', ininfos), ...
      options.prefix, suffix(sn), trimpoint(sn, 1:2), trimoptions);
		options.overwrite = pspm_overwrite(newdatafile{sn}, options);
    newdata.options = options;
    pspm_load_data(newdatafile{sn}, newdata);
    % 2.4.5 Split Epochs
    if options.missing
      dummydata{1,1}.header = struct('channeltype', 'custom', ...
        'sr', missingsr, ...
        'units', 'unknown');
      dummydata{1,1}.data   = dp_epochs;
      % add marker channel so that pspm_trim has a reference
      dummydata{2,1}      = indata{markerchannel};
      dummyinfos          = ininfos;
      newmissing = pspm_trim(struct('data', {dummydata}, 'infos', dummyinfos), ...
        options.prefix, suffix(sn), trimpoint(sn, 1:2), trimoptions);
      epochs = newmissing.data{1}.data;
      epoch_on = 1 + strfind(epochs.', [0 1]); % Return the start points of the excluded interval
      epoch_off = strfind(epochs.', [1 0]); % Return the end points of the excluded interval
      if numel(epoch_off) < numel(epoch_on) % if the epochs is in the middle of 2 blocks
        epoch_off(end+1) = numel(epochs);
      elseif numel(epoch_on) < numel(epoch_off)
        epoch_on = [0, epoch_on];
      elseif (numel(epoch_on) > 0 && numel(epoch_off > 0) && epoch_off(1) < epoch_on(1))
        epoch_on = [0, epoch_on];
        epoch_off(end+1) = numel(epochs);
      end
      epochs = [epoch_on.', epoch_off.']/missingsr; % convert back to seconds
      save(newepochfile{sn}, 'epochs');
    end
  end
sts = 1;
switch nargout
  case 1
    varargout{1} = newdatafile;
  case 2
    varargout{1} = newdatafile;
    varargout{2} = newepochfile;
  case 3
    varargout{1} = sts;
    varargout{2} = newdatafile;
    varargout{3} = newepochfile;
end
return
