function varargout = pspm_sf(model, options)
% ● Description
%   pspm_sf is a wrapper function for analysis of tonic SC measures.
% ● Format
%   outfile = pspm_sf(model, options)
% ● Arguments
%   ┌───────────model
%   │ Mandantory
%   ├───────.datafile:  one data filename or cell array of filenames.
%   ├──────.modelfile:  one data filename or cell array of filenames.
%   ├─────────.timing:  can be one of the following
%   │                   - an SPM style onset file with two event types: onset &
%   │                     offset (names are ignored)
%   │                   - a .mat file with a variable 'epochs', see below
%   │                   - a two-column text file with on/offsets
%   │                   - e x 2 array of epoch on- and offsets, with
%   │                   e: number of epochs
%   │                   or cell array of any of these, for multiple files
%   ├──────.timeunits:  seconds, samples, markers, whole (in the last case,
%   │                   'timing' will be ignored and the entire file will be
%   │                   used).
%   │ Optional
%   ├──────────method:  [string/cell_array]
%   │                   [string] accept 'auc', 'scl', 'dcm', or 'mp', default
%   │                   as 'dcm'
%   │                   [cell_array] a cell array of methods mentioned above.
%   ├─────────.filter:  filter settings; modality specific default
%   ├────────.missing:  [string/cell_array] [default: no missing values]
%   │                   Allows to specify missing (e.g. artefact) epochs in the
%   │                   data file. See pspm_get_timing for epoch definition; specify
%   │                   a cell array for multiple input files. This must always be
%   │                   specified in SECONDS.
%   └────────.channel:  [integer] [default: first SCR channel]
%                       channel number.
%   ┌─────────options
%   ├──────.overwrite:  [logical] [default: determined by pspm_overwrite]
%   │                   Define whether to overwrite existing output files or not.
%   ├.marker_chan_num:  [integer]
%   │                   marker channel number
%   │                   if undefined or 0, first marker channel is used.
%   │ * Additional options for individual methods:
%   │ dcm related options
%   ├──────.threshold:  [numeric] [default: 0.1] [unit: mcS]
%   │                   threshold for SN detection (default 0.1 mcS)
%   ├──────────.theta:  [vector] [default: read from pspm_sf_theta]
%   │                   A (1 x 5) vector of theta values for f_SF.
%   ├──────────.fresp:  [numeric] [unit: Hz] [default: 0.5]
%   │                   frequency of responses to model.
%   ├────────.dispwin:  [logical] [default: 1]
%   │                   display progress window.
%   ├───.dispsmallwin:  [logical] [default: 0]
%   │                   display intermediate windows.
%   └──.missingthresh:  [numeric] [default: 2] [unit: second]
%                       threshold value for controlling missing epochs.
% ● References
%   1.[DCM for SF]
%     Bach DR, Daunizeau J, Kuelzow N, Friston KJ, Dolan RJ (2010). Dynamic
%     causal modelling of spontaneous fluctuations in skin conductance.
%     Psychophysiology, 48, 252-257.
%   2.[AUC measure]
%     Bach DR, Friston KJ, Dolan RJ (2010). Analytic measures for the
%     quantification of arousal from spontanaeous skin conductance
%     fluctuations. International Journal of Psychophysiology, 76, 52-55.
% ● Developer's Note
%   the output also contains a field .time that contains the inversion time
%   in ms (for DCM and MP)
% ● Copyright
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (WCHN, UCL and UZH)
%   Maintained in 2022 by Teddy Chao (UCL)

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
outfile = [];
sts = -1;
switch nargout
  case 1
    varargout{1} = outfile;
  case 2
    varargout{1} = sts;
    varargout{2} = outfile;
end
%% 2 Check input
% 2.1 check missing input --
if nargin < 1; errmsg = 'Nothing to do.'; warning('ID:invalid_input', errmsg); return
elseif nargin < 2; options = struct(); end

% 2.2 check model
model = pspm_check_model(model, 'glm');
if model.invalid
    return
end

% 2.3 check options 
options = pspm_options(options, 'glm');
if options.invalid
  return
end

% 2.4 check files
% stop the script if files are not allowed to overwrite
if ~pspm_overwrite(model.modelfile, options)
  warning('ID:invalid_input', 'Model file exists, and overwriting not allowed by user.');
  return
end

%% 3. Parse methods
method = cell(numel(model.method), 1);
fhandle = method;
datatype = NaN(numel(model.method));
for k = 1:numel(model.method)
switch model.method{k}
  case {'auc', 'AUC'}
    method{k} = 'auc';
    fhandle{k} = @pspm_sf_auc;
    datatype(k) = 2; % filtered
  case {'DCM', 'dcm'}
    method{k} = 'dcm';
    fhandle{k} = @pspm_sf_dcm;
    datatype(k) = 2; % filtered
  case {'MP', 'mp'}
    method{k} = 'mp';
    fhandle{k} = @pspm_sf_mp;
    datatype(k) = 2; % filtered
  case {'SCL', 'scl', 'level'}
    method{k} = 'scl';
    fhandle{k} = @pspm_sf_scl;
    datatype(k) = 1; % unfiltered
  case 'all'
    method = {'scl', 'auc', 'dcm', 'mp'};
    fhandle = {@pspm_sf_scl, @pspm_sf_auc,  @pspm_sf_dcm, @pspm_sf_mp};
    datatype = [1 2 2 2];
  otherwise
    warning('Method %s not supported', model.method{k}); return;
end
  
end
% 2.6 Get timing --
if strcmpi(model.timeunits, 'whole')
  epochs = repmat({[1 1]}, numel(model.datafile), 1);
else
  for iFile = 1:numel(model.datafile)
    [sts, epochs{iFile}] = pspm_get_timing('epochs', model.timing{iFile}, model.timeunits);
  end
end

options = pspm_options(options, 'sf');
if options.invalid
  return
end

%% 3 Get data
nFile = numel(model.datafile);
for iFile = 1:nFile
  % 3.1 User output
  fprintf('SF analysis: %s ...', model.datafile{iFile});
  
  % 3.2 get and filter data --
  [sts_load_data, ~, data] = pspm_load_data(model.datafile{iFile}, model.channel);
  if sts_load_data < 0, return; end
  y{1} = data{end}.data;
  sr(1) = data{end}.header.sr;
  model.filter.sr = sr(1);
  [sts_prepdata, y{2}, sr(2)] = pspm_prepdata(data{end}.data, model.filter);
  % always use last data channels
  if sts_prepdata == -1
    warning('ID:invalid_input', 'Call of pspm_prepdata failed.');
    return;
  end
  % 3.3 Check data units
  if ~strcmpi(data{end}.header.units, 'uS') && any(strcmpi('dcm', method))
    fprintf(['\nYour data units are stored as %s, ',...
      'and the method will apply an amplitude threshold in uS. ',...
      'Please check your results.\n'], ...
      data{end}.header.units);
  end
  % 3.4 Get missing epochs --
  if ~isempty(model.missing{iFile})
    [~, missing{iFile}] = pspm_get_timing('missing', model.missing{iFile}, 'seconds');
    model.missing_data = zeros(size(y{2}));
    missing_index = pspm_time2index(missing{iFile}, sr(datatype(k)));
    model.missing_data((missing_index(:,1)+1):(missing_index(:,2)+1)) = 1;
  else
    missing{iFile} = [];
  end
  % 3.5 Get marker data --
  if any(strcmp(model.timeunits, {'marker', 'markers'}))
    [sts, ~, ndata] = pspm_load_data(model.datafile{iFile}, options.marker_chan_num);
    if sts < 1
      warning('ID:invalid_input', 'Could not load data');
      return;
    elseif ~strcmp(ndata{1}.header.chantype, 'marker')
      warning('ID:invalid_option', ...
        ['Channel %i is no marker channel. ',...
        'The first marker channel in the file is used instead'],...
        options.marker_chan_num);
      [sts_load_data, ~, ~] = pspm_load_data(model.datafile{iFile}, 'marker');
      if sts_load_data == -1
        warning('ID:invalid_input', 'Could not load data');
        return;
      end
    end
    % use first marker channel
    events{iFile} = ndata{1}.data(:);
  end


  for iEpoch = 1:size(epochs{iFile}, 1)
    if iEpoch > 1, fprintf('\n\t\t\t'); end
    fprintf('epoch %01.0f ...', iEpoch);
    for k = 1:numel(method)
      fprintf('%s ', method{k});
      switch model.timeunits
        case 'seconds'
          win = round(epochs{iFile}(iEpoch, :) * sr(datatype(k)));
        case 'samples'
          win = round(epochs{iFile}(iEpoch, :) * sr(datatype(k)) / sr(1));
        case 'markers'
          win = round(events{iFile}(epochs{iFile}(iEpoch, :)) * sr(datatype(k)));
        case 'whole'
          win = [1 numel(y{datatype(k)})];
      end
      if any(win > numel(y{datatype(k)}) + 1) || any(win < 0)
        warning('\nEpoch %2.0f outside of file %s ...', iEpoch, model.modelfile{iFile});
        inv_flag = 0;
      else
        inv_flag = 1;
        % correct issues with using 'round'
        win(1) = max(win(1), 1);
        win(2) = min(win(2), numel(y{datatype(k)}));
      end
      if diff(win) < 4
          warning('\nEpoch %2.0f contains insufficient data ...', iEpoch);
          inv_flag = 0;
      end
      % 3.6.1 collect information --
      sf.model{k}(iEpoch).modeltype = method{k};
      sf.model{k}(iEpoch).boundaries = squeeze(epochs{iFile}(iEpoch, :));
      sf.model{k}(iEpoch).timeunits  = model.timeunits;
      sf.model{k}(iEpoch).samples    = win;
      sf.model{k}(iEpoch).sr         = sr(datatype(k));
      %
      escr = y{datatype(k)}(win(1):win(end));
      sf.model{k}(iEpoch).data = escr;

      % 3.6.2 do the analysis and collect results --
      if ~isempty(model.missing{iFile})
        model_analysis = struct('scr', escr, 'sr', sr(datatype(k)), 'missing_data', model.missing_data(win(1):win(end)));
      else
        model_analysis = struct('scr', escr, 'sr', sr(datatype(k)));
      end
      if inv_flag ~= 0
        invrs = fhandle{k}(model_analysis, options);
        sf.model{k}(iEpoch).inv = invrs;
      else
        sf.model{k}(iEpoch).inv = [];
      end
      if inv_flag == 0
        sf.stats(iEpoch, k) = NaN;
      elseif any(strcmpi(method{k}, {'dcm', 'mp'}))
        sf.stats(iEpoch, k)         = invrs.f;
      else
        sf.stats(iEpoch, k)         = invrs;
      end
    end
    sf.trlnames{iEpoch} = sprintf('Epoch #%d', iEpoch);
  end
  sf.names = method(:);
  sf.infos.date = date;
  sf.infos.file = model.modelfile{iFile};
  sf.modelfile = model.modelfile{iFile};
  sf.data = y;
  if exist('events','var'), sf.events = events; end
  sf.input = model;
  sf.options = options;
  sf.modeltype = 'sf';
  sf.modality = settings.modalities.sf;
  save(model.modelfile{iFile}, 'sf');
  outfile = model.modelfile(iFile);
  fprintf('\n');
end
sts = 1;
switch nargout
  case 1
    varargout{1} = outfile;
  case 2
    varargout{1} = sts;
    varargout{2} = outfile;
end
return
