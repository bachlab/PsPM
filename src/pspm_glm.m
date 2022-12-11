function varargout = pspm_glm(model, options)
% ● Description
%   pspm_glm specifies a within subject general linear convolution model of
%   predicted signals and calculates amplitude estimates for these responses.
% ● Format
%   glm = pspm_glm(model, options)
% ● Arguments
%   ┌─────model:  [struct]
%   │ ▶︎ mandatory
%   ├.modelfile:  a file name for the model output
%   ├─.datafile:  a file name (single session) OR
%   │             a cell array of file names
%   ├───.timing:  a multiple condition file name (single session) OR
%   │             a cell array of multiple condition file names OR
%   │             a struct (single session) with fields .names, .onsets,
%   │             and (optional) .durations and .pmod  OR
%   │             a cell array of struct OR
%   │             a struct with fields 'markerinfos', 'markervalues,
%   │             'names' OR a cell array of struct
%   ├.timeunits:  one of 'seconds', 'samples', 'markers', 'markervalues'
%   ├───.window:  a scalar in seconds that specifies over which time
%   │             window (starting with the events specified in
%   │             model.timing) the model should be evaluated. Is only
%   │             required if model.latency equals 'free'. Is ignored
%   │             otherwise.
%   │ ▶︎ optional
%   ├.modelspec:  'scr' (default); specify the model to be used.
%   │             See pspm_init, defaults.glm() which modelspecs are possible
%   │             with glm.
%   ├─.modality:  specify the modality to be processed.
%   │             When model.modality is set to be sps, the model.channel
%   │             should be set among sps_l, sps_r, or defaultly sps.
%   ├───────.bf:  basis function/basis set; modality specific default
%   │             with subfields .fhandle (function handle or string) and
%   │             .args (arguments, first argument sampling interval will
%   │             be added by pspm_glm). The optional subfield .shiftbf = n
%   │             indicates that the onset of the basis function precedes
%   │             event onsets by n seconds (default: 0: used for
%   │             interpolated data channels)
%   ├──.channel:  channel number or channel type. if a channel type is
%   │             specified the LAST channel matching the given type will
%   │             be used. The rationale for this is that, in general channels
%   │             later in the channel list are preprocessed/filtered versions
%   │             of raw channels.
%   │             SPECIAL: if 'pupil' is specified the function uses the
%   │             last pupil channel returned by
%   │             <a href="matlab:help pspm_load_data">pspm_load_data</a>.
%   │             pspm_load_data loads 'pupil' channels according to a specific
%   │             precedence order described in its documentation. In a nutshell,
%   │             it prefers preprocessed channels and channels from the best eye
%   │             to other pupil channels.
%   │             SPECIAL: for the modality "sps", the model.channel
%   │             accepts only "sps_l", "sps_r", or "sps".
%   │             DEFAULT: last channel of the specified modality
%   │             (for PSR this is 'pupil')
%   ├─────.norm:  normalise data; default 0
%   ├───.filter:  filter settings; modality specific default
%   ├──.missing:  allows to specify missing (e. g. artefact) epochs in the
%   │             data file. See pspm_get_timing for epoch definition;
%   │             specify a cell array for multiple input files. This
%   │             must always be specified in SECONDS.
%   │             Default: no missing values
%   ├─.nuisance:  allows to specify nuisance regressors. Must be a file
%   │             name; the file is either a .txt file containing the
%   │             regressors in columns, or a .mat file containing the
%   │             regressors in a matrix variable called R. There must be
%   │             as many values for each column of R as there are data
%   │             values. SCRalyze will call these regressors R1, R2, ...
%   ├──.latency:  allows to specify whether latency should be 'fixed'
%   │             (default) or should be 'free'. In 'free' models an
%   │             additional dictionary matching algorithm will try to
%   │             estimate the best latency. Latencies will then be added
%   │             at the end of the output. In 'free' models the fiel
%   │             model.window is MANDATORY and single basis functions
%   │             are allowed only.
%   └.centering:  if set to 0 the function would not perform the
%                 mean centering of the convolved X data. For example, to
%                 invert SPS model, set centering to 0. Default: 1
%   ┌───options:
%   │ ▶︎ optional
%   ├──.overwrite:  [logical] (0 or 1)
%   │             Define whether to overwrite existing output files or not.
%   │             Default value: determined by pspm_overwrite.
%   ├──.marker_chan_num:
%   │             marker channel number; default last marker channel.
%   └──.exclude_missing:
%                 marks trials during which NaN percentage exceeds
%                 a cutoff value. Requires two subfields:
%                 'segment_length' (in s after onset) and 'cutoff'
%                 (in % NaN per segment). Results are written into
%                 model structure as fields .stats_missing and
%                 .stats_exclude but not used further.
% ● Outputs
%           glm:  a structure 'glm' which is also written to file
% ● Developer's Notes
%   TIMING - multiple condition file(s) or struct variable(s):
%   The structure is equivalent to SPM2/5/8/12 (www.fil.ion.ucl.ac.uk/spm),
%   such that SPM files can be used.
%   The file contains the following variables:
%   - names: a cell array of string for the names of the experimental
%     conditions
%   - onsets: a cell array of number vectors for the onsets of events for
%     each experimental condition, expressed in seconds, marker numbers, or
%     samples, as specified in timeunits
%   - durations (optional, default 0): a cell array of vectors for the
%     duration of each event. You need to use 'seconds' or 'samples' as time
%     units
%   - pmod: this is used to specify regressors that specify how responses in
%     an experimental condition depend on a parameter to model the effect
%     e.g. of habituation, reaction times, or stimulus ratings.
%     pmod is a struct array corresponding to names and onsets and containing
%     the fields
%   - name: cell array of names for each parametric modulator for this
%       condition
%   - param: cell array of vectors for each parameter for this condition,
%       containing as many numbers as there are onsets
%   - poly (optional, default 1): specifies the polynomial degree
%     e.g. produce a simple multiple condition file by typing
%     names = {'condition a', 'condition b'};
%     onsets = {[1 2 3], [4 5 6]};
%     save('testfile', 'names', 'onsets');
% ● References
%   [1] GLM for SCR:
%       Bach DR, Flandin G, Friston KJ, Dolan RJ (2009). Time-series analysis for
%       rapid event-related skin conductance responses. Journal of Neuroscience
%       Methods, 184, 224-234.
%   [2] SCR: Canonical response function, and GLM assumptions:
%       Bach DR, Flandin G, Friston KJ, Dolan RJ (2010). Modelling event-related
%       skin conductance responses. International Journal of Psychophysiology,
%       75, 349-356.
%   [3] Fine-tuning of SCR CLM:
%       Bach DR, Friston KJ, Dolan RJ (2013). An improved algorithm for
%       model-based analysis of evoked skin conductance responses. Biological
%       Psychology, 94, 490-497.
%   [4] SCR GLM validation and comparison with Ledalab:
%       Bach DR (2014).  A head-to-head comparison of SCRalyze and Ledalab, two
%       model-based methods for skin conductance analysis. Biological Psychology,
%       103, 63-88.
%   [5] SEBR GLM: Khemka S, Tzovara A, Gerster S, Quednow B and Bach DR (2017)
%       Modeling Startle Eyeblink Electromyogram to Assess
%       Fear Learning. Psychophysiology
% ● History
%   Introduced in PsPM 3.1
%   Written in 2008-2016 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Maintained in 2022 by Teddy Chao (UCL)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
glm = struct([]); % output model structure
tmp = struct([]); % temporary model structure

% check input arguments & set defaults
% -------------------------------------------------------------------------

% check missing input --
if nargin<1
  errmsg='Nothing to do.'; warning('ID:invalid_input', errmsg); return;
elseif nargin<2
  options = struct();
end

fprintf('Computing GLM: %s ...\n', model.modelfile);

if ~isfield(model, 'datafile')
  warning('ID:invalid_input', 'No input data file specified.'); return;
elseif ~isfield(model, 'modelfile')
  warning('ID:invalid_input', 'No output model file specified.'); return;
elseif ~isfield(model, 'timeunits')
  warning('ID:invalid_input', 'No timeunits specified.'); return;
end

% check whether field timing doesnt exist, field is emtpy or field is cell
% with empty entries
if ~isfield(model, 'timing') || isempty(model.timing) || ...
    iscell(model.timing) && (sum(cellfun(@(f) isempty(f), model.timing)) == numel(model.timing))
  % model.timing is not set
  % test the same way if nuisance is not set
  if ~isfield(model, 'nuisance') || isempty(model.nuisance) || ...
      iscell(model.nuisance) && (sum(cellfun(@(f) isempty(f), model.nuisance)) == numel(model.nuisance))
    % nuisance is not set
    warning('ID:invalid_input', 'Event onsets and nuisance file are not specified. At least one of the two must be specified.'); return;
  end
end

% set default values
if ~isfield(model, 'latency')
  model.latency = 'fixed';
end

% check faulty input --
if ~ischar(model.datafile) && ~iscell(model.datafile)
  warning('ID:invalid_input', 'Input data must be a cell or string.'); return;
elseif ~ischar(model.modelfile)
  warning('ID:invalid_input', 'Output model must be a string.'); return;
elseif ~ischar(model.timing) && ~iscell(model.timing) && ~isstruct(model.timing)
  warning('ID:invalid_input', 'Event onsets must be a string, cell, or struct.'); return;
elseif ~ischar(model.timeunits) || ~ismember(model.timeunits, {'seconds', 'markers', 'samples','markervalues'})
  warning('ID:invalid_input', 'Timeunits (%s) not recognised; only ''seconds'', ''markers'' and ''samples'' are supported', model.timeunits); return;
elseif ~ismember(model.latency, {'free', 'fixed'})
  warning('ID:invalid_input', 'Latency should be either ''fixed'' or ''free''.'); return;
elseif strcmpi(model.latency, 'free') && (~isnumeric(model.window) || isempty(model.window))
  warning('ID:invalid_input', 'Window is expected to be a numeric value.'); return;
end

% get further input or set defaults --
if ~isfield(model, 'modelspec')
  % load default model specification
  model.modelspec = settings.glm(1).modelspec;
elseif ~ismember(model.modelspec, {settings.glm.modelspec})
  warning('ID:invalid_input', 'Unknown model specification %s.', model.modelspec); return;
end
modno = find(strcmpi(model.modelspec, {settings.glm.modelspec}));
model.modality = settings.glm(modno).modality;

% check data channel --
if ~isfield(model, 'channel')
  if strcmp(model.modality, 'psr')
    model.channel = "pupil";
  else
    model.channel = model.modality;
  end
elseif ~isnumeric(model.channel) && ~ismember(model.channel, {settings.channeltypes.type})
  warning('ID:invalid_input', 'Channel number must be numeric.'); return;
end

% check normalisation --
if ~isfield(model, 'norm')
  model.norm = 0;
elseif ~ismember(model.norm, [0, 1])
  warning('ID:invalid_input', 'Normalisation must be specified as 0 or 1.'); return;
end

% check mean centering --
if ~isfield(model,'centering')
  model.centering = 1;
elseif ~ismember(model.centering, [0, 1])
  model.centering = 1;
end

% check options --
options = pspm_options(options, 'glm');
if options.invalid
  return
end
if ischar(model.datafile)
  model.datafile={model.datafile};
end
if ischar(model.timing) || isstruct(model.timing)
  model.timing = {model.timing};
end

if ~isempty(model.timing) && (numel(model.datafile) ~= numel(model.timing))
  warning('ID:number_of_elements_dont_match', 'Session numbers of data files and event definitions do not match.'); return;
end

% check & get data --
fprintf('Getting data ...');
nFile = numel(model.datafile);
for iFile = 1:nFile
  [sts, ~, data] = pspm_load_data(model.datafile{iFile}, model.channel);
  if sts < 1, return; end
  y{iFile} = data{end}.data(:);
  sr(iFile) = data{end}.header.sr;
  fprintf('.');
  if any(strcmp(model.timeunits, {'marker', 'markers','markervalues'}))
    [sts, ~, data] = pspm_load_data(model.datafile{iFile}, options.marker_chan_num);
    if sts < 1
      warning('ID:invalid_input', ['Could not load the specified markerchannel']);
      return;
    end
    events{iFile} = data{end}.data * data{end}.header.sr;
    if strcmp(model.timeunits,'markervalues')
      model.timing{iFile}.markerinfo = data{end}.markerinfo;
    end
  end
end

if nFile > 1 && any(diff(sr) > 0)
  fprintf('\nSample rate differs between sessions.\n')
else
  fprintf('\n');
end

% check filter --
if ~isfield(model, 'filter')
  model.filter = settings.glm(modno).filter;
end

% set default model.filter.down --
if strcmpi(model.filter.down, 'none') || ...
    isnumeric(model.filter.down) && isnan(model.filter.down)
  model.filter.down = min(sr);
else
  % check value of model.filter.down --
  if ~isfield(model.filter, 'down') || ~isnumeric(model.filter.down)
    % tested because the field is used before the call of
    % pspm_prepdata (everything else is tested there)
    warning('ID:invalid_input', ['Filter struct needs field ', ...
      '''down'' to be numeric or ''none''.']); return;
  end

  model.filter.down = min([sr model.filter.down]);
end

% check & get basis functions --
basepath = [];
if ~isfield(model, 'bf')
  model.bf = settings.glm(modno).cbf;
else
  if ~isfield(model.bf, 'fhandle')
    warning('No basis function given.');
  elseif ischar(model.bf.fhandle)
    [basepath, basefn, baseext] = fileparts(model.bf.fhandle);
    model.bf.fhandle = str2func(basefn);
  elseif ~isa(model.bf.fhandle, 'function_handle')
    warning('Basis function must be a string or function handle.');
  end
  if ~isfield(model.bf, 'args')
    model.bf.args = [];
  elseif ~isnumeric(model.bf.args)
    warning('Basis function arguments must be numeric.');
  end
end
if ~isempty(basepath), addpath(basepath); end
try
  td = 1/model.filter.down;

  % model.bf.X contains the function values
  % bf_x contains the timestamps
  [model.bf.X, bf_x] = feval(model.bf.fhandle, [td; model.bf.args(:)]);
  if strcmpi(model.latency, 'free') && size(model.bf.X,2) > 1
    warning('ID:invalid_input', ['With latency ''free'' multiple response ', ...
      'functions are not allowed.']); return;
  end
catch
  warning('ID:invalid_fhandle', 'Specified basis function %s doesn''t exist or is faulty', func2str(model.bf.fhandle)); return;
end

% set shiftbf
if bf_x(1) < 0
  model.bf.shiftbf = abs(bf_x(1));
elseif bf_x(1) > 0
  warning('ID:invalid_basis_function', 'The first basis function timestamp is larger than 0 (not allowed).'); return;
else
  model.bf.shiftbf = 0;
end

% remove path & clear local variables --
if ~isempty(basepath), rmpath(basepath); end
clear basepath basefn baseext


% check regressor files --
[sts, multi] = pspm_get_timing('onsets', model.timing, model.timeunits);
if sts < 0
  warning('ID:invalid_input', 'Failed to call pspm_get_timing'); return;
elseif strcmpi(model.timeunits,'markervalues')
  nr_multi = numel(multi);
  for n_m = 1:nr_multi
    model.timing{n_m} = multi(n_m);
  end
  model.timeunits = 'markers';
end

% check & get missing values --
if ~isfield(model, 'missing')
  missing = cell(nFile, 1);
else
  if ischar(model.missing) || isnumeric(model.missing)
    model.missing = {model.missing};
  elseif ~iscell(model.missing)
    warning('ID:invalid_input', 'Missing values must be a filename, matrix, or cell array of these.'); return;
  end
  if numel(model.missing) ~= nFile
    warning('ID:number_of_elements_dont_match',...
      'Same number of data files and missing value definitions is needed.'); return;
  end
  for iSn = 1:nFile
    if isempty(model.missing{iSn})
      sts = 1; missing{iSn} = [];
    else
      [sts, missing{iSn}] = pspm_get_timing('epochs', model.missing{iSn}, 'seconds');
    end
    if sts == -1, warning('ID:invalid_input',...
        'Failed to call pspm_get_timing'); return; end
  end
end

% check and get nuisance regressors
if ~isfield(model, 'nuisance')
  model.nuisance = cell(nFile, 1);
  for iSn = 1:nFile
    R{iSn} = [];
  end
  nR = 0;
else
  if ischar(model.nuisance)
    model.nuisance = {model.nuisance};
  elseif ~iscell(model.nuisance)
    warning('ID:invalid_input', 'Nuisance regressors must be specified as char or cell of file names.'); return;
  end
  if numel(model.nuisance) ~= nFile
    warning('ID:number_of_elements_dont_match',...
      'Same number of data files and nuisance regressor files is needed.'); return;
  end
  for iSn = 1:nFile
    if isempty(model.nuisance{iSn})
      R{iSn} = [];
    else
      try
        indata = load(model.nuisance{iSn});
        if isstruct(indata)
          R{iSn} = indata.R;
        else
          R{iSn} = indata;
        end
      catch
        warning('ID:invalid_file_type',...
          'Unacceptable file format or non-existing file for nuisance file in session %01.0f', iSn); return;
      end
      if size(R{iSn}, 1) ~= numel(y{iSn})
        warning('ID:number_of_elements_dont_match',...
          'Nuisance regressors for session %01.0f must have same number of data points as observed data.', iSn); return;
      end
    end
    if iSn == 1
      nR = size(R{iSn}, 2);
    elseif size(R{iSn}, 2) ~= nR
      warning('ID:number_of_elements_dont_match',...
        'Nuisance regressors for all sessions must have the same number of columns'); return;
    end
  end
end


fprintf('Preparing & inverting model ... ');

% collect output model information --
glm(1).glmfile    = model.modelfile; % this field will be removed in the future so don't use any more
glm.modelfile     = model.modelfile;
glm.input         = model;
glm.input.options = options;
glm.bf            = model.bf;
glm.bf.bfno       = size(glm.bf.X, 2);

% prepare timing variables
onsets = {};
names = {};
durations = {};
pmod = {};

% clear local variables --
clear sts iFile modno


% prepare data & regressors
%-------------------------------------------------------------------------

Y=[]; M=[]; tmp=struct([]);
for iSn = 1:nFile

  % prepare (filter & downsample) data
  model.filter.sr = sr(iSn);
  % find NaN values
  oldy = y{iSn};
  % find which fields are nan after interoplation and prepdata
  nan_idx = find(isnan(oldy));
  % interpolate y data
  [sts, oldy] = pspm_interpolate(oldy, struct('extrapolate', 1));
  if sts ~= 1, warning('ID:invalid_input', 'Failed to interpolate y data'); return; end
  % filter data
  [sts, newy, newsr] = pspm_prepdata(oldy, model.filter);
  if sts ~= 1, warning('ID:invalid_input', 'Failed to filter data'); return; end

  % if has been downsampled adjust nan_idx
  if numel(oldy) ~= numel(newy)
    nan_idx = round(nan_idx*(model.filter.down/model.filter.sr));
    % sanitize ends
    nan_idx(nan_idx < 1) = 1;
    nan_idx(nan_idx > numel(newy)) = numel(newy);
    % find duplicates
    dupli = diff(nan_idx) == 0;
    % remove duplicates
    nan_idx(dupli) = [];
  end

  % concatenate data
  Y=[Y; NaN(newsr * model.bf.shiftbf, 1); newy(:)];

  % get duration of single sessions
  tmp(1).snduration(iSn) = numel(newy) + newsr * model.bf.shiftbf;

  % process missing values
  newmissing = zeros(size(newy(:)));
  if ~isempty(missing{iSn})
    missingtimes = pspm_time2index(missing{iSn},newsr,length(newmissing));
    for iMs = 1:size(missingtimes, 1)
      newmissing(missingtimes(iMs, 1):missingtimes(iMs, 2)) = 1;
    end
  end
  % copy NaN in y data should be missing
  newmissing(nan_idx) = 1;

  M = [M; ones(newsr * model.bf.shiftbf, 1); newmissing];

  % convert regressor information to samples
  if ~isempty(multi)

    for n = 1:numel(multi(iSn).names)

      % look for index
      name_idx = find(strcmpi(names, multi(iSn).names(n)));
      if numel(name_idx) > 1
        warning(['Name was found multiple times, ', ...
          'will take first occurence.']);
        name_idx = name_idx(1);
      elseif numel(name_idx) == 0
        % append
        name_idx = numel(names) + 1;
      end

      % convert onsets to samples
      switch model.timeunits
        case 'samples'
          newonsets    = round(multi(iSn).onsets{n} * newsr/sr(iSn));
          newdurations = round(multi(iSn).durations{n} * newsr/sr(iSn));
        case 'seconds'
          newonsets    = round(multi(iSn).onsets{n} * newsr);
          newdurations = round(multi(iSn).durations{n} * newsr);
        case 'markers'
          try
            % markers are timestamps in seconds
            newonsets = round(events{iSn}(multi(iSn).onsets{n}) ...
              * newsr);

          catch
            warning(['\nSome events in condition %01.0f were ', ...
              'not found in the data file %s'], n, ...
              model.datafile{iSn}); return;
          end
          newdurations = multi(iSn).durations{n};
      end
      % get the first multiple condition definition --
      if numel(names) < name_idx
        names{name_idx} = multi(iSn).names{n};
        onsets{name_idx} = [];
        durations{name_idx} = [];
        if isfield(multi, 'pmod') && (numel(multi(iSn).pmod) >= n)
          for p = 1:numel(multi(iSn).pmod(n).param)
            pmod(name_idx).param{p} = [];
          end
          pmod(name_idx).name = multi(iSn).pmod(n).name;
        end

      end

      % shift conditions for sessions not being the first
      if iSn > 1
        newonsets = newonsets + sum(tmp.snduration(1:(iSn - 1)));
      end

      onsets{name_idx} = [onsets{name_idx}; newonsets(:)];
      durations{name_idx} = [durations{name_idx}; newdurations(:)];
      if isfield(multi, 'pmod') && (numel(multi(iSn).pmod) >= n)
        for p = 1:numel(multi(iSn).pmod(n).param)
          pmod(name_idx).param{p} = [pmod(name_idx).param{p}; ...
            multi(iSn).pmod(n).param{p}(:)];
        end
      end
    end
  else
    names = {};
    onsets = {};
    durations = {};
  end

end

% normalise if desired --
if model.norm
  % ignore nan values
  no_nan = ~isnan(Y);
  % normalise
  Y = (Y - mean(Y(no_nan)))/std(Y(no_nan));
end
Y = Y(:);

% collect information into tmp --
tmp.length=numel(Y);

% scale pmods before orthogonalisation --
tmp.pmodno=zeros(numel(names), 1);
if exist('pmod', 'var')
  for n=1:numel(pmod)
    if ~isempty(pmod(n).param)
      for p=1:numel(pmod(n).param)
        % mean center and scale pmods
        try
          tmp.pmodscale(n, p) = std(pmod(n).param{p});
        catch
          tmp.pmodscale(n, p) = 1;
        end
        pmod(n).param{p}=(pmod(n).param{p}-mean(pmod(n).param{p}))/tmp.pmodscale(n, p);
      end
      % register number of pmods
      tmp.pmodno(n)=p;
    end
  end
else
  pmod = [];
end

% collect data & regressors for output model --
glm.input.data    = y;
glm.input.sr      = sr;
glm.Y             = Y;
glm.M             = M;
glm.infos.sr      = newsr;
glm.infos.duration     = numel(glm.Y)/glm.infos.sr;
glm.infos.durationinfo = 'duration in seconds';
glm.timing.multi      = multi;
glm.timing.names      = names;
glm.timing.onsets     = onsets;
glm.timing.durations  = durations;
glm.timing.pmod       = pmod;
glm.modality          = model.modality;
glm.modelspec         = model.modelspec;
glm.modeltype         = 'glm';

% clear local variables --
clear iSn iMs ynew newonsets newdurations newmissing missingtimes


% create temporary onset functions
%-------------------------------------------------------------------------
% cycle through conditions
for iCond = 1:numel(names)
  tmp.regscale{iCond} = 1;
  % first process event onset, then pmod
  tmp.onsets = onsets{iCond};
  tmp.durations = durations{iCond};
  % if file starts with first event, set that onset to 1 instead of 0
  if any(tmp.onsets == 0)
    tmp.onsets(tmp.onsets == 0) = 1;
  end
  col=1;
  tmp.colnum=1+tmp.pmodno(iCond);
  tmp.X{iCond}=zeros(tmp.length, tmp.colnum);
  for k = 1:numel(tmp.onsets)
    tmp.X{iCond}(tmp.onsets(k):(tmp.onsets(k) + tmp.durations(k)), col)=1;
  end
  tmp.name{iCond, col}=names{iCond};
  col=col+1;
  if exist('pmod') && ~isempty(pmod)
    if iCond<=numel(pmod)
      if ~isempty(pmod(iCond).param)
        for p=1:numel(pmod(iCond).param)
          for k = 1:numel(tmp.onsets)
            tmp.X{iCond}(tmp.onsets(k):(tmp.onsets(k) + tmp.durations(k)), col)=pmod(iCond).param{p}(k);
          end
          tmp.name{iCond, col}=[names{iCond}, ' x ', pmod(iCond).name{p}];
          tmp.regscale{iCond}(col) = tmp.pmodscale(iCond, col - 1);
          col=col+1;
        end
      end
    end
    % orthogonalize pmods before convolution
    foo = spm_orth(tmp.X{iCond});
    % catch zero matrices (unclear yet why this happens, 01-Apr-2012)
    if all(all(foo==0))
      warning('the pmods in condition %i have not been orthogonalized (because spm_orth returned a zero matrix)', iCond)
    else
      tmp.X{iCond} = foo;
    end
  end
end


% create design matrix
%-------------------------------------------------------------------------
% create design matrix filter
Xfilter = model.filter;
Xfilter.sr = glm.infos.sr;
Xfilter.down = 'none'; % turn off downsampling
Xfilter.lpfreq = NaN; % turn off low pass filter

% convolve with basis functions
snoffsets = cumsum(tmp.snduration);
snonsets  = [1, snoffsets(1:end) + 1];
tmp.XC = cell(1,numel(names));
tmp.regscalec = cell(1,numel(names));
for iCond = 1:numel(names)
  tmp.XC{iCond} = [];
  tmp.regscalec{iCond} = [];
  iXCcol = 1;
  for iXcol = 1:size(tmp.X{iCond}, 2)
    for iBf = 1:glm.bf.bfno
      % process each session individually
      for iSn = 1:numel(tmp.snduration)
        % convolve
        tmp.col{iSn, 1} = conv(tmp.X{iCond}(snonsets(iSn):snoffsets(iSn), iXcol), glm.bf.X(:,iBf));
        % filter design matrix w/o downsampling
        [sts,  tmp.col{iSn, 1}] = pspm_prepdata(tmp.col{iSn, 1}, Xfilter);
        if sts ~= 1, glm = struct([]);warning('ID:invalid_input', 'Failed to filter data');return; end
        % cut away tail
        tmp.col{iSn, 1}((tmp.snduration(iSn) + 1):end) = [];
      end
      tmp.XC{iCond}(:, iXCcol) = cell2mat(tmp.col);
      tmp.namec{iCond}{iXCcol, 1} = [tmp.name{iCond, iXcol}, ', bf ', num2str(iBf)];
      tmp.regscalec{iCond} = [tmp.regscalec{iCond}, tmp.regscale{iCond}(iXcol)];
      iXCcol = iXCcol + 1;
      % clear local variable
      tmp.col = {};
    end
  end

  % mean centering
  if model.centering
    for iXCol=1:size(tmp.XC{iCond},2)
      tmp.XC{iCond}(:,iXCol) = tmp.XC{iCond}(:,iXCol) - mean(tmp.XC{iCond}(:,iXCol));
    end
  end

  % orthogonalize after convolution if there is more than one column per
  % condition
  if size(tmp.XC{iCond}, 2) > 1
    foo=spm_orth(tmp.XC{iCond});
    % catch zero matrices (unclear yet why this happens, 01-Apr-2012)
    if ~(all(foo(:) == 0))
      tmp.XC{iCond} = foo;
    else
      warning('\nOrthogonalisation error in event type #%02.0f\nCorrelation coefficients are: ', iCond);
      cc = corrcoef(tmp.XC{iCond});
      for k = 2:size(cc, 1)
        fprintf('%0.2f, ', cc(1, k));
      end
      fprintf('\n');
    end
  end
end

% define model
glm.X = cell2mat(tmp.XC);
glm.regscale = cell2mat(tmp.regscalec);
glm.names = cell(numel(names), 1);
r=1;
for iCond = 1:numel(names)
  n = numel(tmp.namec{iCond});
  glm.names(r:(r+n-1), 1) = tmp.namec{iCond};
  r = r + n;
end

% add nuisance regressors
for iSn = 1:numel(model.datafile)
  Rf{iSn} = [];
  model.filter.sr = sr(iSn);
  for iR = 1:nR
    [sts, Rf{iSn}(:, iR)]  = pspm_prepdata(R{iSn}(:, iR), model.filter);
    if sts ~= 1,warning('ID:invalid_input', 'Failed to filter data'); return; end
  end
  if (model.bf.shiftbf ~= 0) && ~isempty(Rf{iSn})
    Rf{iSn} = [ NaN(model.bf.shiftbf*model.filter.down, nR); Rf{iSn}];
  end
end
Rf = cell2mat(Rf(:));

n = size(glm.names, 1);
for iR = 1:nR
  glm.names{n+iR, 1} = sprintf('R%01.0f', iR);
end

glm.X = [glm.X, Rf];
glm.regscale((end+1):(end+nR)) = 1;

% add constant(s)
r=1;
n = size(glm.names, 1);
for iSn = 1:numel(model.datafile)
  glm.X(r:(r+tmp.snduration(iSn)-1), end+1)=1;
  glm.names{n+iSn, 1} = ['Constant ', num2str(iSn)];
  r = r + tmp.snduration(iSn);
end
glm.interceptno = iSn;
glm.regscale((end+1):(end+iSn)) = 1;

% delete missing epochs and prepare output
perc_missing = 1 - sum(glm.M)/length(glm.M);
if perc_missing >= 0.1
  if sr == Xfilter.sr
    warning('ID:invalid_input', ...
      ['More than 10% of input data was filtered out due to missing epochs. ',...
      'Results may be inaccurate.']);
  else
    warning('ID:invalid_input', ...
      ['More than 10% of input data was filtered out due to missing epochs, ',...
      'which is possibly caused by downsampling. Results may be inaccurate.']);
  end
end
glm.YM = glm.Y;
glm.YM(glm.M(1:length(glm.YM))==1) = [];
glm.Y(glm.M(1:length(glm.Y))==1) = NaN;
glm.XM = glm.X;
glm.XM(glm.M(1:length(glm.XM))==1, :) = [];
glm.X(glm.M(1:length(glm.X))==1, :) = NaN;
glm.Yhat    = NaN(size(Y));

% clear local variables
clear tmp Xfilter r iSn n iCond


% invert model & save
%-------------------------------------------------------------------------
% this is where the beef is
if strcmpi(model.latency, 'free')
  % prepare dictionary onsets and new design matrix
  D_on = eye(ceil(model.window*glm.infos.sr));
  XMnew = NaN(size(glm.XM));

  % go through columns
  ncol = size(glm.XM, 2) - nR - glm.interceptno;
  glm.names(2 * ncol + (1:glm.interceptno)) = glm.names(ncol + (1:glm.interceptno));
  for iCol = 1:ncol
    % specify dictionary
    for iD = 1:size(D_on, 2)
      foo = conv(D_on(:, iD), glm.XM(:, iCol));
      D(iD, :) = foo(1:size(glm.XM, 1));
    end
    % obtain inner product and select max
    a = D * glm.YM;
    [~, ind] = max(a);
    lat(iCol) = ind/glm.infos.sr;
    XMnew(:, iCol) = D(ind, :);
    % create names
    glm.names{iCol + ncol} = [glm.names{iCol}, ' Latency'];
  end

  % add nuisance regressors (if any) and session intercepts
  XMnew(:, (iCol + 1):end) = glm.XM(:, (iCol + 1):end);

  % replace design matrix
  glm.XMold = glm.XM;
  glm.XM = XMnew;
end

% estimate amplitudes
glm.stats = pinv(glm.XM)*glm.YM;           % parameter estimates
glm.Yhat(glm.M==0) = glm.XM*glm.stats;     % predicted response
glm.e    = glm.Y - glm.Yhat;               % residual error
glm.EV   = 1 - (var(glm.e)/var(glm.YM));   % explained variance proportion

% rescale pmod parameter estimates & design matrix
%-------------------------------------------------------------------------
glm.X = glm.X .* repmat(glm.regscale, size(glm.X, 1), 1);
glm.XM = glm.XM .* repmat(glm.regscale, size(glm.XM, 1), 1);
glm.stats = glm.stats ./ glm.regscale';

if strcmpi(model.latency, 'free')
  % add latency parameters
  glm.stats = [glm.stats(:); lat(:)];
end

% call pspm_extract_segments if options.exclude_misssing is set
% verify that both fields are set
% when pspm_extract_segments returns set fields in glm
% glm.stats_missing holds the percentage of NaNs per condition
% glm.stats_exclude holds boolean for each condition to indicate if the
% cutoff holds
% glm.stats_exclude_names holds the names of the conditions to be excluded

if isfield(options,'exclude_missing')
  [sts,segments] = pspm_extract_segments('auto', glm, ...
    struct('length', options.exclude_missing.segment_length));
  if sts == -1
    warning('ID:invalid_input', 'call of pspm_extract_segments failed');
    return;
  end
  segments = segments.segments;
  nan_percentages = cellfun(@(x) x.total_nan_percent,segments, ...
    'un',0);
  glm.stats_missing = cell2mat(nan_percentages);
  glm.stats_exclude = glm.stats_missing > options.exclude_missing.cutoff;
  glm.stats_exclude_names = cellfun(@(x) x.name,segments, ...
    'un',0);
  glm.stats_exclude_names = glm.stats_exclude_names(glm.stats_exclude);
end
%% save data
% overwrite is determined in load1
savedata = struct('glm', glm);
[sts_load1, data_load1, mdltype_load1] = pspm_load1(model.modelfile, 'save', savedata, options);
if ~sts_load1
  warning('ID:invalid_input', 'call of pspm_load1 failed');
  return;
end
%% user output
fprintf(' done. \n');
sts = 1;
switch nargout
  case 1
    varargout{1} = glm;
  case 2
    varargout{1} = sts;
    varargout{2} = glm;
end
end
