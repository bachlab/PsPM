function [sts, outdata] = pspm_interpolate(varargin)
% ● Description
%   pspm_interpolate interpolates NaN values passed with the indata parameter.
%   The behaviour of the function can furthermore be adjusted with the
%   combination of different options.
%   The function works either on single data sets such as a filename, a
%   numeric array or a pspm data struct. Alternatively it is possible to pass
%   a cell containing all these possible datatypes. The function then
%   iterates through the whole data set and replaces the passed data with the
%   interpolated data. For filenames the interpolated data will, depending on
%   option.newfile, be written to the existing file or can also be added to a
%   new file with filename 'i'+<old filename>. The corresponding cell
%   (in outdata) will then contain the filename of the new file
%   (if newfile = 1) or will contain the channel id where the interpolated
%   data can be found in the existing file (because it has been added or
%   replaced). The edited data set will then be returned as parameter outdata.
% ● Format
%   [sts, outdata] = pspm_interpolate(indata, options)
% ● Arguments
%          indata:  [struct/char/numeric] or [cell array of struct/char/numeric]
%                   contains the data to be interpolated
%   ┌─────options:
%   ├──.overwrite:  Defines if existing datafiles should be overwritten.
%   │               [logical] (0 or 1)
%   │               Define whether to overwrite existing output files or not.
%   │               Default value: determined by pspm_overwrite.
%   ├─────.method:  Defines the interpolation method, see interp1() for
%   │               possible interpolation methods.
%   │               [optional; default: linear]
%   ├─.extrapolate: Determine should extrapolate for data out of the data
%   │               range.
%   │               [optional; not recommended; accept: 1, 0; default: 0]
%   ├─────.channel: If passed, should have the same size as indata and
%   │               contains for each entry in indata the channel(s) to
%   │               be interpolated. If options.channel is empty or a
%   │               certain cell is empty the function then tries to
%   │               interpolate all continuous data channels. This
%   │               works only on files or structs.
%   │               [optional; default: empty]
%   ├.channel_action:
%   │               Defines whether the interpolated data should be added
%   │               or the corresponding channel should be replaced.
%   │               [optional; accept: 'add', 'replace'; default: 'add']
%   └────.newfile:  This is only possible if data is loaded from a file.
%                   If 0 the data will be added to the file where
%                   the data was loaded from. If 1 the data will be
%                   written to a new file called 'i'+<old filename>.
%                   [optional; default: 0]
% ● Output
%             sts:  Returns the status of the function
%                   -1: function did not work properly
%                    1: the function went through properly
%         outdata:  Has the same format as indata but contains the interpolated
%                   data (or the filename(s) where the interpolated data can be
%                   found).
% ● History
%   Introduced in PsPM 3.0
%   Written in 2015 by Tobias Moser (University of Zurich)
%   Maintained in 2022 by Teddy Chao (UCL)

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
outdata = {}; % will return a cell of the same size as the indata
sts = -1;
switch length(varargin)
  case 1
    indata = varargin{1};
    options = struct();
  case 2
    indata = varargin{1};
    options = varargin{2};
  case 3
    warning('Up to two variables are accepted by pspm_interpolate.');
    return
end
% 1.1 check input arguments
if nargin<1
  warning('ID:missing_data', 'No data.\n');
  return;
end
if isempty(indata)
  warning('ID:missing_data', 'Input data is empty, nothing to do.');
  return;
end
% 1.2 initialise options
options = pspm_options(options, 'interpolate');
if options.invalid
  return
end
% try options.method; catch, options.method = 'linear'; end
try options.channel; catch, options.channel = []; end
% try options.newfile; catch, options.newfile = 0; end
%try options.extrapolate; catch, options.extrapolate = 0; end
% 1.3 check channel size
if numel(options.channel) > 0
  if numel(options.channel) ~= numel(indata)
    warning('ID:invalid_size', 'options.channel must have same size as indata');
    return;
  elseif (numel(options.channel) == 1) && ~iscell(options.channel)
    options.channel = {options.channel};
  end
end
% 1.4 check if valid data in options
if ~ismember(options.method, {'linear', 'nearest', 'next', 'previous', 'spline', 'pchip', 'cubic'})
  warning('ID:invalid_input', 'Invalid interpolation method.');
  return;
elseif ~(isnumeric(options.channel) || isempty(options.channel) || ...
    (iscell(options.channel) && sum(cellfun(@(f) (isnumeric(f) || ...
    isempty(f)), options.channel)) == numel(options.channel)))
  warning('ID:invalid_input', 'options.channel must be numeric or a cell of numerics');
  return;
elseif ~islogical(options.newfile) && ~isnumeric(options.newfile)
  warning('ID:invalid_input', 'options.newfile must be numeric or logical');
  return;
elseif ~islogical(options.overwrite) && ~isnumeric(options.overwrite)
   warning('ID:invalid_input', 'options.overwrite must be numeric (0 or 1) or logical');
elseif ~islogical(options.extrapolate) && ~isnumeric(options.extrapolate)
  warning('ID:invalid_input', 'options.extrapolate must be numeric or logical');
  return;
end
% 1.3 check data file argument
% 1.3.1 define D
if ischar(indata) || isstruct(indata) || isnumeric(indata)
  D = {indata};
elseif iscell(indata) ...
    && sum(cellfun(@(f) isstruct(f), indata) | ...
    cellfun(@(f) isnumeric(f), indata) | ...
    cellfun(@(f) ischar(f), indata)) == numel(indata)
  D = indata;
else
  warning('ID:invalid_input', ...
    'Data must be either char, numeric, struct or cell array of char, numeric or struct.');
  return;
end
% 1.3.2 define outdata
if iscell(indata)
  outdata = cell(size(D));
else
  outdata = {}; % initialise
end
%% 2 work on all data files
for d = 1:numel(D)
  % 2.1 load data
  fn = D{d}; % determine file names
  inline_flag = 0; % flag to decide what kind of data should be handled
  if ischar(fn)
    fprintf('\nInterpolating %s, ', fn); % user output
  elseif isnumeric(fn)
    inline_flag = 1;
  end
  if ~inline_flag % check and get datafile (not inline data must be loaded first)
    if ischar(fn) && ~exist(fn, 'file')
      warning('ID:nonexistent_file', 'The file ''%s'' does not exist.', fn);
      outdata = {};
      return;
    end
    % struct get checked if structure is okay; files get loaded
    [lsts, infos, data] = pspm_load_data(fn, 0);
    if any(lsts == -1)
      warning('ID:invalid_data_structure', 'Cannot load data from data');
      outdata = {};
      break;
    end
    if numel(options.channel) > 0 && numel(options.channel{d}) > 0
      % channel passed; try to get appropriate channel
      work_channels = options.channel{d};
      channel = data(work_channels);
    else
      % no channel passed; try to search appropriate channel
      work_channels = find(cellfun(@(f) ~strcmpi(f.header.units, 'events'), data))';
      channel = data(work_channels);
    end
    % sanity check channel should be a cell
    if ~iscell(channel) && numel(channel) == 1
      channel = {channel};
    end
    % look for event channel
    ev = cellfun(@(f) strcmpi(f.header.units, 'events'), channel);
    if any(ev)
      warning('ID:invalid_chantype', 'Cannot interpolate event channel.');
      return;
    end
  else
    channel = {fn};
  end
  interp_frac = ones(numel(channel), 1);
  for k = 1:numel(channel)
    if inline_flag
      dat = channel{k};
    else
      dat = channel{k}.data;
    end
    if numel(find(~isnan(dat))) < 2
      warning('ID:invalid_input',...
        'Need at least two sample points to run interpolation (Channel %i). Skipping.', k);
    else
      x = 1:length(dat);
      v = dat;
      % add some other checks here if you want to filter out other data
      % features (e. g. out-of-range values)
      filt = isnan(v);
      xq = find(filt);
      % remember how many data is being interpolated
      interp_frac(k) = numel(xq)/numel(v);
      % throw away data matching 'filt'
      x(xq) = [];
      v(xq) = [];
      % check for overlaps
      if numel(xq) < 1
        e_overlap = 0;
        s_overlap = 0;
      else
        e_overlap = max(xq) > max(x);
        s_overlap = min(xq) < min(x);
      end
      if s_overlap || e_overlap
        if ~options.extrapolate
          warning('ID:option_disabled', ...
            'Extrapolating was forced because interpolate without extrapolating cannot be done');
          vq = interp1(x, v, xq, options.method, 'extrap');
        elseif s_overlap && strcmpi(options.method, 'previous')
          warning('ID:out_of_range', ['Cannot extrapolate with ', ...
            'method ''previous'' and overlap at the beginning.']);
          return;
        elseif e_overlap && strcmpi(options.method, 'next')
          warning('ID:out_of_range', ['Cannot extrapolate with ', ...
            'method ''next'' and overlap at the end.']);
          return;
        else
          % extrapolate because of overlaps
          vq = interp1(x, v, xq, options.method, 'extrap');
        end
      else
        % no overlap
        vq = interp1(x, v, xq, options.method);
      end
      dat(xq) = vq;
      if inline_flag
        channel{k} = dat;
      else
        channel{k}.data = dat;
      end
    end
  end
  if ~inline_flag
    clear savedata
    savedata.data = data;
    savedata.data(work_channels) = channel(:);
    savedata.infos = infos;
    if isfield(savedata.infos, 'history')
      nhist = numel(savedata.infos.history);
    else
      nhist = 0;
    end
    savedata.infos.history{nhist + 1} = ['Performed interpolation: ', ...
      sprintf('Channel %i: %.3f interpolated\n', [work_channels; interp_frac']), ...
      ' on ', datestr(now, 'dd-mmm-yyyy HH:MM:SS')];
    if isstruct(fn)
      % check datastructure
      sts = pspm_load_data(savedata, 'none');
      outdata{d} = savedata;
    else
      if options.newfile
        % save as a new file preprended with 'i'
        [pth, fn, ext] = fileparts(fn);
        newdatafile    = fullfile(pth, ['i', fn, ext]);
        savedata.infos.interpolatefile = newdatafile;
        % pass options
        o.overwrite = pspm_overwrite(newdatafile, options);
        savedata.options = o;
        sts = pspm_load_data(newdatafile, savedata);
        if sts == 1
          outdata{d} = newdatafile;
        end
      else
        o = struct();
        % add to existing file
        if strcmp(options.channel_action, 'replace')
          o.channel = work_channels;
        end
        o.msg.prefix = 'Interpolated channel';
        [sts, infos] = pspm_write_channel(fn, savedata.data(work_channels), options.channel_action, o);
        % added channel ids are in infos.channel
        outdata{d} = infos.channel;
      end
    end
  else
    outdata{d} = channel{1};
  end
  if ischar(fn)
    fprintf('done.')
  end
end
% format output same as input
if (numel(outdata) == 1) && ~iscell(indata)
  outdata = outdata{1};
end
sts = 1;
return
