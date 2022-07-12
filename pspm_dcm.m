function dcm = pspm_dcm(model, options)
% ● DESCRIPTION
% pspm_dcm sets up a DCM for skin conductance, prepares and normalises the
% data, passes it over to the model inversion routine, and saves both the
% forward model and its inversion.
%
% Both flexible-latency (within a response window) and fixed-latency
% (evoked after a specified event) responses can be modelled.
% For fixed responses, delay and dispersion are assumed to be constant
% (either pre-determined or estimated from the data), while for flexible
% responses, both are estimated for each individual trial.
% Flexible responses can for example be anticipatory, decision-related,
% or evoked with unknown onset.
%
% ● FORMAT
%	dcm = pspm_dcm(model, options)
%
% ● ARGUMENTS
%	model
%	┃ Required fields
% ┣━.modelfile  A file name for the model output.
%	┣━.datafile   A file name (single session) OR a cell array of file names.
%	┣━.timing     A file name/cell array of events (single session) OR a cell
%	┃             array of file names/cell arrays.
%	┃             When specifying file names, each file must be a *.mat file
%	┃             that contain a cell variable called 'events'.
%	┃             Each cell should contain either one column (fixed response)
%	┃             or two columns (flexible response).
%	┃             All matrices in the array need to have the same number of rows,
%	┃             i.e. the event structure must be the same for every trial.
%	┃             If this is not the case, include "dummy" events with
%	┃             negative onsets.
%	┃ Optional fields
% ┣━.missing    Allows to specify missing (e. g. artefact) epochs in the
%	┃             data file.
%	┃             See pspm_get_timing for epoch definition; specify a cell
%	┃             array for multiple input files.
%	┃             This must always be specified in SECONDS.
%	┃             Default: no missing values
% ┣━.lasttrialcutoff
%	┃             If there fewer data after the end of then last trial in a
%	┃             session than this cutoff value (in s), then estimated
%	┃             parameters from this trial will be assumed inestimable
%	┃             and set to NaN after the
%	┃             inversion. This value can be set as inf to always retain
%	┃             parameters from the last trial.
%	┃             Default: 7 s
% ┣━.substhresh
%	┃             Minimum duration (in seconds) of NaN periods to cause
%	┃             splitting up into subsessions which get evaluated
%	┃             independently (excluding NaN values).
%	┃             Default: 2.
% ┣━.filter			Filter settings.
%	┃             Modality specific default.
% ┣━.channel:		Channel number.
%	┃             Default: first SCR channel
% ┣━.norm:			Normalise data.
%	┃             i.e. Data are normalised during inversion but results
%	┃             transformed back into raw data units.
%	┃             Default: 0.
% ┗━.constrained
%	              Constrained model for flexible responses which have fixed
%               dispersion (0.3 s SD) but flexible latency.
% options
%	┃ Response function options
% ┣━.crfupdate  Update CRF priors to observed SCRF, or use pre-estimated
%	┃             priors (default)
% ┣━.indrf      Estimate the response function from the data.
%	┃             Default: 0.
% ┣━.getrf      Only estimate RF, do not do trial-wise DCM
% ┣━.rf         Call an external file to provide response function
%	┃             (for use when this is previously estimated by pspm_get_rf)
%	┃ Inversion options
% ┣━.depth      No of trials to invert at the same time.
%	┃             Default: 2.
% ┣━.sfpre      sf-free window before first event.
%	┃             Default: 2s.
% ┣━.sfpost     sf-free window after last event.
%	┃             Default: 5s.
% ┣━.sffreq:		maximum frequency of SF in ITIs.
%	┃             Default: 0.5/s.
% ┣━.sclpre     scl-change-free window before first event.
%	┃             Default: 2s.
% ┣━.sclpost    scl-change-free window after last event.
%	┃             Default: 5s.
% ┣━.aSCR_sigma_offset
%	┃             Minimum dispersion (standard deviation) for flexible responses.
%	┃             Default: 0.1s.
%	┃ Display options
% ┣━.dispwin    Display progress window.
%	┃             Default: 1.
% ┣━.dispsmallwin
%	┃             display intermediate windows.
%	┃             Default: 0.
%	┃ Output options
% ┣━.nosave		  Don't save dcm structure (e.g. used by pspm_get_rf)
% ┣━.overwrite	whether to overwrite
%	┃             Default: determined by pspm_overwrite.
%	┃ Naming options
% ┣━.trlnames   Cell array of names for individual trials,
%	┃             is used for contrast manager only (e.g. condition descriptions)
% ┗━.eventnames
%               Cell array of names for individual events,
%               in the order they are specified in the model.timing array -
%               to be used for display and export only
% ● OUTPUT
%	fn            Name of the model file.
%	dcm           Model struct.
%
% Output units: all timeunits are in seconds; eSCR and aSCR amplitude are
% in SN units such that an eSCR SN pulse with 1 unit amplitude causes an
% eSCR with 1 mcS amplitude
%
% pspm_dcm can handle NaN values in data channels. Either by specifying
% missing epochs manually using model.missing, or by detecting NaN epochs
% in the data. Missing epochs shorter than model.substhresh will be ignored
% in the inversion; otherwise the data will be split into subsessions that
% are inverted independently. The results will be unchanged, and events
% within missing epochs will simply be set to NaN.  NaN periods shorter than
% model.substhresh are interpolated for averages and principal response
% components.
%
% pspm_dcm calculates the inter-trial intervals as the duration between the
% end of a trial and the start of the next one.
% ITI value for the last trial in a session is calculated as the duration
% between the end of the last trial and the end of the whole session.
% Since this value may differ significantly from the regular ITI duration
% values, it is not used when computing the minimum ITI duration of a session.
%
% Minimum of session specific min ITI values is used
%   1. when computing mean SCR signal
%   2. when computing the PCA from all the trials in all the sessions.
%
% In case of case (2), after each trial, all the samples in
% the period with duration equal to the just mentioned overall min ITI
% value is used as a row of the input matrix. Since this minimum does not
% use the min ITI value of the last trial in each session, the sample
% period may be longer than the ITI value of the last trial. In such a case,
% pspm_dcm is not able to compute the PCA and emits a warning.
%
% The rationale behind this behaviour is that we observed that ITI value of
% the last trial in a session might be much smaller than the usual ITI
% values. For example, this can happen when a long missing data section
% starts very soon after the beginning of a trial. If this very small ITI
% value is used to define the sample periods after each trial, nearly all
% the trials use much less than available amount of samples in both case
% (1) and (2). Instead, we aim to use as much data as possible in (1), and
% perform (2) only if this edge case is not present.
%
% REFERENCES
% (1) Bach DR, Daunizeau J, Friston KJ, Dolan RJ (2010).
%     Dynamic causal modelling of anticipatory skin conductance changes.
%     Biological Psychology, 85(1), 163-70
% (2) Staib, M., Castegnetti, G., & Bach, D. R. (2015).
%     Optimising a model-based approach to inferring fear learning from
%     skin conductance responses.
%     Journal of Neuroscience Methods, 255, 131-138.
%
%__________________________________________________________________________
% PsPM 5.1.0
% (c) 2010-2021 Dominik Bach (Wellcome Centre for Human Neuroimaging, UCL)

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

dcm = [];
% cell array which saves all the warnings which are not followed
% by a `return` function
warnings = {};

%% 2 Check input arguments & set defaults
% 2.1 check input
if nargin < 1
  warning('ID:invalid_input', 'No data to work on.');
  return
elseif nargin < 2
  options = struct([]);
end
if ~isfield(model, 'datafile')
  warning('ID:invalid_input', 'No input data file specified.'); return;
elseif ~isfield(model, 'modelfile')
  warning('ID:invalid_input', 'No output model file specified.'); return;
elseif ~isfield(model, 'timing')
  warning('ID:invalid_input', 'No event onsets specified.'); return;
end

% 2.2 check faulty input
if ~iscell(model.datafile) && ~ischar(model.datafile)
  warning('ID:invalid_input', 'Input data must be a cell or string.'); return;
elseif ~ischar(model.modelfile)
  warning('ID:invalid_input', 'Output model must be a string.'); return;
elseif ~ischar(model.timing) && ~iscell(model.timing)
  warning('ID:invalid_input', 'Event definition must be a string or cell array.'); return;
end

% 2.3 get further input or set defaults --
% check data channel --
if ~isfield(model, 'channel')
  model.channel = 'scr'; % this returns the first SCR channel
elseif ~isnumeric(model.channel) && ~strcmp(model.channel,'scr')
  warning('ID:invalid_input', 'Channel number must be numeric.'); return;
end

% 2.4 check normalisation --
if ~isfield(model, 'norm')
  model.norm = 0;
elseif ~any(ismember(model.norm, [0, 1]))
  warning('ID:invalid_input', 'Normalisation must be specified as 0 or 1.'); return;
end

% 2.5 check constrained model --
if ~isfield(model, 'constrained')
  model.constrained = 0;
elseif ~any(ismember(model.constrained, [0, 1]))
  warning('ID:invalid_input', 'Constrained model must be specified as 0 or 1.'); return;
end

% 2.6 check substhresh --
if ~isfield(model, 'substhresh')
  model.substhresh = 2;
elseif ~isnumeric(model.substhresh)
  warning('ID:invalid_input', 'Subsession threshold must be numeric.');
  return;
end

% 2.7 check filter --
if ~isfield(model, 'filter')
  model.filter = settings.dcm{1}.filter;
elseif ~isfield(model.filter, 'down') || ~isnumeric(model.filter.down)
  warning('ID:invalid_input', 'Filter structure needs a numeric ''down'' field.'); return;
end

if ~isstruct(options)
  warning('ID:invalid_input', '''options'' must be a struct.');
  return;
end

% 2.8 set and check options ---
try options.indrf;              catch, options(1).indrf = 0;            end
try options.getrf;              catch, options.getrf = 0;               end
try options.rf;                 catch, options.rf = 0;                  end
try options.nosave;             catch, options.nosave = 0;              end
try options.depth;              catch, options.depth = 2;               end
try options.sfpost;             catch, options.sfpost = 5;              end
try options.aSCR_sigma_offset;  catch, options.aSCR_sigma_offset = 0.1; end
try options.sclpost;            catch, options.sclpost = 5;             end
try options.sclpre;             catch, options.sclpre = 2;              end
try options.sfpre;              catch, options.sfpre = 2;               end
try options.sffreq;             catch, options.sffreq = 0.5;            end
try options.method;             catch, options.method = 'dcm';          end
try options.dispwin;            catch, options.dispwin = 1;             end
try options.dispsmallwin;       catch, options.dispsmallwin = 0;        end
try options.crfupdate;          catch, options.crfupdate = 0;           end
try options.eventnames;         catch, options.eventnames = {};         end
try options.trlnames;           catch, options.trlnames = {};           end
try model.lasttrialcutoff;      catch, model.lasttrialcutoff = 7;       end

% 2.9 check option fields --
% numeric fields
num_fields = {'depth', 'sfpre', 'sfpost', 'sffreq', 'sclpre', ...
  'sclpost', 'aSCR_sigma_offset'};
% logical fields
bool_fields = {'crfupdate', 'indrf', 'getrf', 'dispwin', ...
  'dispsmallwin', 'nosave'};
% cell fields
cell_fields = {'trlnames', 'eventnames'};
check_sts = sum([pspm_check_options('numeric', options, num_fields), ...
  pspm_check_options('logical', options, bool_fields), ...
  pspm_check_options('cell', options, cell_fields)]);
%
if check_sts < 3
  warning('ID:invalid_input', ['An error occurred while validating the ', ...
    'input options. See earlier warnings for more information.']);
  return;
end
% check input of special rf field
if isempty(options.rf) || ...
    ((isnumeric(options.rf) && options.rf ~= 0) && (~ischar(options.rf)))
  warning('ID:invalid_input', 'Field ''rf'' is neither a string nor 0.');
  return;
end
% check mutual exclusivity
if options.indrf && options.rf
  warning('ID:invalid_input', 'RF can be provided or estimated, not both.');
  return
end

% 2.10 check files
% stop the script if files are not allowed to overwrite
if ~pspm_overwrite(model.modelfile, options)
  warning('ID:invalid_input', 'Results are not allowed to overwrite.');
  return
end

if ischar(model.datafile)
  model.datafile = {model.datafile};
  model.timing   = {model.timing};
end

nFile = numel(model.datafile);
if ~isfield(model, 'missing')
  model.missing = cell(nFile, 1);
elseif ischar(model.missing) || isnumeric(model.missing)
  model.missing = {model.missing};
elseif ~iscell(model.missing)
  warning('ID:invalid_input',...
    'Missing values must be a filename, matrix, or cell array of these.');
  return
end
if nFile ~= numel(model.timing)
  warning('ID:number_of_elements_dont_match',...
    'Session numbers of data files and event definitions do not match.');
  return
end
if nFile ~= numel(model.missing)
  warning('ID:number_of_elements_dont_match',...
    'Same number of data files and missing value definitions is needed.');
  return
end

%% 3 Check, get and prepare data

% split into subsessions
% colnames: iSn start stop enabled (if contains events)
subsessions = [];
data = cell(numel(model.datafile), 1);
missing = cell(nFile, 1);
for iSn = 1:numel(model.datafile)
  % check & load data
  [sts, ~, data{iSn}] = pspm_load_data(model.datafile{iSn}, model.channel);
  if sts == -1 || isempty(data{iSn})
    warning('ID:invalid_input', 'No SCR data contained in file %s', ...
      model.datafile{iSn});
    return;
  end

  % load and check existing missing data (if defined)
  if ~isempty(model.missing{iSn})
    [~, missing{iSn}] = pspm_get_timing('epochs', ...
      model.missing{iSn}, 'seconds');
    % sort missing epochs
    if size(missing{iSn}, 1) > 0
      [~, sortindx] = sort(missing{iSn}(:, 1));
      missing{iSn} = missing{iSn}(sortindx,:);
      % check for overlap and merge
      for k = 2:size(missing{iSn}, 1)
        if missing{iSn}(k, 1) <= missing{iSn}(k - 1, 2)
          missing{iSn}(k, 1) =  missing{iSn}(k - 1, 1);
          missing{iSn}(k - 1, :) = [];
        end
      end
    end
  else
    missing{iSn} = [];
  end
  model.filter.sr = data{iSn}{1}.header.sr;

  % try to find missing epochs according to subsession threshold
  n_data = size(data{iSn}{1}.data,1);
  if isempty(missing{iSn})
    nan_epochs = isnan(data{iSn}{1}.data);

    d_nan_ep = transpose(diff(nan_epochs));
    nan_ep_start = find(d_nan_ep == 1);
    nan_ep_stop = find(d_nan_ep == -1);

    if numel(nan_ep_start) > 0 || numel(nan_ep_stop) > 0
      % check for blunt ends and fix
      if isempty(nan_ep_start)
        nan_ep_start = 1;
      elseif isempty(nan_ep_stop)
        nan_ep_stop = numel(d_nan_ep);
      end

      if nan_ep_start(1) > nan_ep_stop(1)
        nan_ep_start = [1, nan_ep_start];
      end
      if nan_ep_start(end) > nan_ep_stop(end)
        nan_ep_stop(end + 1) = numel(d_nan_ep);
      end
    end

    % put missing epochs together
    miss_epochs = [nan_ep_start(:), nan_ep_stop(:)];

    % classify if epoch should be considered
    % true for duration > substhresh and for missing epochs
    ignore_epochs = diff(miss_epochs, 1, 2)/data{iSn}{1}.header.sr > ...
      model.substhresh;

  else
    % use missing epochs as specified by file
    miss_epochs = pspm_time2index(missing{iSn},data{iSn}{1}.header.sr);
    ignore_epochs = diff(missing{iSn}, 1, 2) > model.substhresh;

    % and set data to NaN to enable later detection of "short" missing
    % epochs
    for k = 1:size(miss_epochs, 1)
      flanks = round(miss_epochs(k,:));
      data{iSn}{1}.data(flanks(1):flanks(2)) = NaN;
    end
  end

  if any(ignore_epochs)
    i_e = find(ignore_epochs);

    % invert missings to sessions without nans
    se_start = [1; miss_epochs(i_e(1:end), 2) + 1];
    se_stop = [miss_epochs(i_e(1:end), 1)-1; n_data];

    % throw away first session if stop is
    % earlier than start (can happen because stop - 1)
    % is used
    if se_stop(1) <= se_start(1)
      se_start = se_start(2:end);
      se_stop = se_stop(2:end);
    end

    % throw away last session if start (+1) overlaps
    % n_data
    if se_start(end) >= n_data
      se_start = se_start(1:end-1);
      se_stop = se_stop(1:end-1);
    end

    % subsessions header --
    % =====================
    % 1 session_id
    % 2 start_time (s)
    % 3 stop_time (s)
    % 4 missing (1) or data segment (0)

    n_sbs = numel(se_start);
    % enabled subsessions
    subsessions(end+(1:n_sbs), 1:4) = [ones(n_sbs,1)*iSn, ...
      [se_start, se_stop]/data{iSn}{1}.header.sr, ...
      zeros(n_sbs,1)];

    % missing epochs
    n_miss = sum(ignore_epochs);
    subsessions(end+(1:n_miss), 1:4) = [ones(n_miss,1)*iSn, ...
      miss_epochs(i_e,:)/data{iSn}{1}.header.sr, ...
      ones(n_miss,1)];
  else
    subsessions(end+1,1:4) = [iSn, ...
      [1, numel(data{iSn}{1}.data)]/data{iSn}{1}.header.sr, 0];


  end
end

% sort subsessions by start
subsessions = sortrows(subsessions);

% find missing values, interpolate and normalise ---
valid_subsessions = find(subsessions(:,4) == 0);
foo = {};
for vs = 1:numel(valid_subsessions)
  isbSn = valid_subsessions(vs);
  sbSn = subsessions(isbSn, :);
  flanks = pspm_time2index(sbSn(2:3), data{sbSn(1)}{1}.header.sr);
  sbSn_data = data{sbSn(1)}{1}.data(flanks(1):flanks(2));
  sbs_miss = isnan(sbSn_data);

  if any(sbs_miss)
    interpolateoptions = struct('extrapolate', 1);
    [~, sbSn_data] = pspm_interpolate(sbSn_data, interpolateoptions);
    
    clear interpolateoptions
  end
  [sts, sbs_data{isbSn, 1}, model.sr] = pspm_prepdata(sbSn_data, model.filter);
  % define missing epochs for inversion in final sampling rate
  sbs_missing{isbSn, 1} = downsample(sbs_miss, model.filter.sr/model.sr);
  if sts == -1, return; end
  foo{vs, 1} = (sbs_data{isbSn}(:) - mean(sbs_data{isbSn}));
end

foo = cell2mat(foo);
model.zfactor = std(foo(:));
for vs = 1:numel(valid_subsessions)
  isbSn = valid_subsessions(vs);
  sbs_data{isbSn} = (sbs_data{isbSn}(:) - min(sbs_data{isbSn}))/model.zfactor;
end
clear foo

%% 4 Check & get events and group into flexible and fixed responses
trials = {};
n_sbs = size(subsessions, 1);
sbs_newevents = cell(2,1);
sbs_trlstart = cell(1,n_sbs);
sbs_trlstop = cell(1,n_sbs);
sbs_iti= cell(1,n_sbs);
sbs_miniti = zeros(1,n_sbs);
lasttrial_log = zeros(1, n_sbs);
% 4.1 processing in each element
for iSn = 1:numel(model.timing)
  % 4.1.1 initialise and get timing information --
  sn_newevents{1}{iSn} = []; sn_newevents{2}{iSn} = [];
  [sts, events] = pspm_get_timing('events', model.timing{iSn});
  if sts ~=1, return; end
  cEvnt = [1 1];
  % table with trial_id sbsnid
  % split up into flexible and fixed events --
  for iEvnt = 1:numel(events)
    if size(events{iEvnt}, 2) == 2 % flex
      sn_newevents{1}{iSn}(:, cEvnt(1), 1:2) = events{iEvnt};
      % assign event names
      if iSn == 1 && isfield(options, 'eventnames') ...
          && numel(options.eventnames) == numel(events)
        flexevntnames{cEvnt(1)} = options.eventnames{iEvnt};
      elseif iSn == 1
        flexevntnames{cEvnt(1)} = ...
          sprintf('Flexible response # %1.0f',cEvnt(1));
      end
      % update counter
      cEvnt = cEvnt + [1 0];
    elseif size(events{iEvnt}, 2) == 1 % fix
      sn_newevents{2}{iSn}(:, cEvnt(2), 1) = events{iEvnt};
      % assign event names
      if iSn == 1 && isfield(options, 'eventnames') && ...
          numel(options.eventnames) == numel(events)
        fixevntnames{cEvnt(2)} = options.eventnames{iEvnt};
      elseif iSn == 1
        fixevntnames{cEvnt(2)} = ...
          sprintf('Fixed response # %1.0f',cEvnt(2));
      end
      % update counter
      cEvnt = cEvnt + [0 1];
    end
  end
  cEvnt = cEvnt - [1, 1];
  % check number of events across sessions --
  if iSn == 1
    nEvnt = cEvnt;
  else
    if any(cEvnt ~= nEvnt)
      warning(['Same number of events per trial required ', ...
        'across all sessions.']); return;
    end
  end

  % find trialstart, trialstop and shortest ITI --
  sn_allevents = [reshape(sn_newevents{1}{iSn}, ...
    [size(sn_newevents{1}{iSn}, 1), ...
    size(sn_newevents{1}{iSn}, 2) * size(sn_newevents{1}{iSn}, 3)]), ...
    sn_newevents{2}{iSn}];
  % exclude "dummy" events with negative onsets
  sn_allevents(sn_allevents < 0) = inf;
  % first event per trial
  sn_trlstart{iSn} = min(sn_allevents, [], 2);
  % exclude "dummy" events with negative onsets
  sn_allevents(isinf(sn_allevents)) = -inf;
  % last event of per trial
  sn_trlstop{iSn}  = max(sn_allevents, [], 2);

  % assign trials to subsessions
  trls = num2cell([sn_trlstart{iSn}, sn_trlstop{iSn}],2);
  subs = cellfun(@(x) find(x(1) > subsessions(:,2) & ...
    x(2) < (subsessions(:,3)) ...
    & subsessions(:, 1) == iSn), trls, 'UniformOutput', 0);

  emp_subs = cellfun(@isempty, subs);
  if any(emp_subs)
    subs(emp_subs) = {-1};
  end
  % find enabled and disabled trials
  trlinfo = cellfun(@(x) x ~= -1 && subsessions(x, 4) == 0, subs, ...
    'UniformOutput', 0);
  trials{iSn} = [cell2mat(trlinfo), cell2mat(subs)];
  % cycle through subsessions and copy events to corresponding subsession
  % --
  % find subsessions corresponding to the current session
  sn_sbs = find(subsessions(:, 1) == iSn);
  if any(trials{iSn})
    for isn_sbs=1:numel(sn_sbs)
      sbs_id = sn_sbs(isn_sbs);
      % trials which are enabled and have the 'current' subsession id
      sbs_trls = trials{iSn}(:, 1) == 1 & trials{iSn}(:,2) == sbs_id;
      if sum(sbs_trls)>0 % if any trials exist
        sbs_trlstart{sbs_id} = sn_trlstart{iSn}(sbs_trls) - ...
          subsessions(sbs_id,2);
        sbs_trlstop{sbs_id} = sn_trlstop{iSn}(sbs_trls) - ...
          subsessions(sbs_id,2);
        sbs_iti{sbs_id} = [sbs_trlstart{sbs_id}(2:end); ...
          numel(sbs_data{sbs_id, 1})/model.sr] - sbs_trlstop{sbs_id};
        if sum(sbs_trls)>1 % if more than one trial exists
          sbs_miniti(sbs_id) = min(sbs_iti{sbs_id}(1 : end - 1));
        else
          sbs_miniti(sbs_id) = NaN;
        end

        for ievType = 1:numel(sbs_newevents)
          if ~isempty(sn_newevents{ievType}{iSn})
            sbs_newevents{ievType}{sbs_id} = ...
              sn_newevents{ievType}{iSn}(sbs_trls,:,:) ...
              - subsessions(sbs_id,2);
          else
            sbs_newevents{ievType}{sbs_id} = [];
          end
        end

        if sbs_miniti(iSn) < 0
          warning(['Error in event definition. Either events are ', ...
            'outside the file, or trials overlap.']); return;
        end

        % invalidate last trial if interval to end of session is
        % shorter than minimum value
        if sbs_iti{sbs_id}(end) < model.lasttrialcutoff
          trlindx = find(sbs_trls);         % find last trial of this subsession
          trials{iSn}(trlindx(end), 1) = 0; % set index - will be applied after estimation
          lasttrial_log(sbs_id) = 1;
        end
      end
    end
  else
    warning('Could not find any enabled trial for file ''%s''', ...
      model.datafile{iSn});
    [warnings{end+1,2},warnings{end+1,1}] = lastwarn;
  end
end

if all(cellfun(@isempty, sbs_trlstart))
  warning('ID:invalid_input', ['In all files there is not a ', ...
    'single subsession to be processed.']);
  return;
end

% find subsessions with events and define them to be processed
proc_subsessions = ~cellfun(@isempty, sbs_trlstart);
proc_miniti = sbs_miniti(proc_subsessions);
% proc_miniti(isnan(proc_miniti)) = [];
% proc_miniti may contains NaN, but it is not recommended to remove these
% NaN now, because its length will be inconsistant with other variables in
% the following processing. NaNs are accepted by .* operations in MATLAB.
model.trlstart = sbs_trlstart(proc_subsessions);
model.trlstop = sbs_trlstop(proc_subsessions);
model.iti = sbs_iti(proc_subsessions);
model.events = {sbs_newevents{1}(proc_subsessions), sbs_newevents{2}(proc_subsessions)};
model.lasttrlfiltered = lasttrial_log; % recorded the sessions that have last trial filtered
model.scr = sbs_data(proc_subsessions);
options.missing = sbs_missing(proc_subsessions);

%% 5 Prepare data for CRF estimation and for amplitude priors
% 5.1 get average event sequence per trial
if nEvnt(1) > 0
  flexseq = cell2mat(model.events{1}') - repmat(cell2mat(model.trlstart'), ...
    [1, size(model.events{1}{1}, 2), 2]);
  flexseq(flexseq < 0) = NaN;
  flexevents = [];
  % this loop serves to avoid the function nanmean which is part of the
  % stats toolbox
  for k = 1:size(flexseq, 2)
    for m = 1:2
      foo = flexseq(:, k, m);
      flexevents(k, m) = mean(foo(~isnan(foo)));
    end
  end
else
  flexevents = [];
end
if nEvnt(2) > 0
  fixseq  = cell2mat(model.events{2}') - repmat(cell2mat(model.trlstart'),...
    1, size(model.events{2}{1}, 2));
  fixseq(fixseq < 0) = NaN;
  fixevents = [];
  for k = 1:size(fixseq, 2)
    foo = fixseq(:, k);
    fixevents(k) = mean(foo(~isnan(foo)));
  end
else
  fixevents = [];
end
startevent = min([flexevents(:); fixevents(:)]);
flexevents = flexevents - startevent;
fixevents  = fixevents  - startevent;
options.flexevents = flexevents;
options.fixevents  = fixevents;
clear flexseq fixseq flexevents fixevents startevent

% 5.2 check ITI
if (options.indrf || options.getrf) && min(proc_miniti) < 5
  warning(['Inter trial interval is too short to estimate individual CRF - ',...
    'at least 5 s needed. Standard CRF will be used instead.']);
  [warnings{end+1,2},warnings{end+1,1}] = lastwarn;
  options.indrf = 0;
end

% 5.3 extract PCA of last fixed response (eSCR) if last event is fixed --
if (options.indrf || options.getrf) && (isempty(options.flexevents) ...
    || (max(options.fixevents > max(options.flexevents(:, 2), [], 2))))
  [~, lastfix] = max(options.fixevents);
  % extract data
  winsize = floor(model.sr * min([proc_miniti 10]));
  D = [];
  c = 1;
  valid_newevents = sbs_newevents{2}(proc_subsessions);
  for isbSn = 1:numel(model.scr)
    scr_sess = model.scr{isbSn};
    foo = valid_newevents{isbSn}(:, lastfix);
    foo(foo < 0) = [];
    for n = 1:size(foo, 1)
      win = ceil(model.sr * foo(n) + (1:winsize));
      [row, warnings] = get_data_after_trial_filling_with_nans_when_necessary(...
        scr_sess, win, n, isbSn, model.iti, proc_miniti, warnings);
      D(c, 1:numel(row)) = row;
      c = c + 1;
    end
  end
  clear c k n
  if isempty(find(isnan(D(:))))
    mD = D - repmat(mean(D, 2), 1, size(D, 2)); % mean centre
    % PCA
    [u, s]=svd(mD', 0);
    [~, n] = size(mD);
    s = diag(s);
    comp = u .* repmat(s',n,1);
    eSCR = comp(:, 1);
    eSCR = eSCR - eSCR(1);
    foo = min([numel(eSCR), 50]);
    [~, ind] = max(abs(eSCR(1:foo)));
    if eSCR(ind) < 0, eSCR = -eSCR; end
    eSCR = (eSCR - min(eSCR))/(max(eSCR) - min(eSCR));
    % check for peak (zero-crossing of the smoothed derivative) after more
    % than 3 seconds (use CRF if there is none)
    der = diff(eSCR);
    der = conv(der, ones(10, 1));
    der = der(ceil(3 * model.sr):end);
    if all(der > 0) || all(der < 0)
      warning('ID:PCA_eSCR',...
        ['No peak detected in response to outcomes. ',...
        'Cannot individually adjust CRF. ',...
        'Standard CRF will be used instead.']);
      [warnings{end+1,2},warnings{end+1,1}] = lastwarn;
      options.indrf = 0;
    else
      options.eSCR = eSCR;
    end
  else
    warning('ID:invalid_input',...
      'Due to NaNs after some trial endings, PCA could not be computed');
    [warnings{end+1,2},warnings{end+1,1}] = lastwarn;
  end
end

% 5.4 extract data from all trials
winsize = floor(model.sr * min([proc_miniti 10]));
D = []; c = 1;
for isbSn = 1:numel(model.scr)
  scr_sess = model.scr{isbSn};
  for n = 1:numel(model.trlstart{isbSn})
    win = ceil(((model.sr * model.trlstart{isbSn}(n)):...
      (model.sr * model.trlstop{isbSn}(n) + winsize)));
    % correct rounding errors
    win(win == 0) = [];
    [row,warnings] = get_data_after_trial_filling_with_nans_when_necessary(...
      scr_sess, win, n, isbSn, model.iti, proc_miniti, warnings);
    D(c, 1:numel(row)) = row;
    c = c + 1;
  end
end
clear c n

% 5.5 do PCA if required
if (options.indrf || options.getrf) && ~isempty(options.flexevents)
  if isempty(find(isnan(D(:))))
    % mean SOA
    meansoa = mean(cell2mat(model.trlstop') - cell2mat(model.trlstart'));
    % mean centre
    mD = D - repmat(mean(D, 2), 1, size(D, 2));
    % PCA
    [u, s, ~] = svd(mD', 0);
    [~, n] = size(mD);
    s = diag(s);
    comp = u .* repmat(s',n,1);
    aSCR = comp(:, 1);
    aSCR = aSCR - aSCR(1);
    foo = min([numel(aSCR), (pspm_time2index(meansoa, model.sr) + 50)]);
    [~, ind] = max(abs(aSCR(1:foo)));
    if aSCR(ind) < 0, aSCR = -aSCR; end
    aSCR = (aSCR - min(aSCR))/(max(aSCR) - min(aSCR));
    clear u s c p n s comp mx ind mD
    options.aSCR = aSCR;
  else
    warning('ID:invalid_input', ...
      'Due to NaNs after some trial endings, PCA could not be computed');
    [warnings{end+1,2},warnings{end+1,1}] = lastwarn;
  end
end

% 5.6 get mean response
options.meanSCR = transpose(nanmean(D));

%% 6 Invert DCM
dcm = pspm_dcm_inv(model, options);

%% 7 Assemble stats & names
dcm.stats = [];
cTrl = 0;
proc_subs_ids = find(proc_subsessions);
for iSn = 1:numel(model.datafile)
  trls = trials{iSn};
  sn_sbs = find(subsessions(proc_subs_ids, 1) == iSn);

  for isbSn = 1:numel(sn_sbs)
    sbs_id = proc_subs_ids(sn_sbs(isbSn));
    sbs_trl = find(trls(:,2) == sbs_id);
    offset_trl = sbs_trl + 1 - min(sbs_trl); % start counting from 1

    flex_stats = [cell2mat({dcm.sn{sn_sbs(isbSn)}.a(offset_trl).a}'), ...
      cell2mat({dcm.sn{sn_sbs(isbSn)}.a(offset_trl).m}'), ...
      cell2mat({dcm.sn{sn_sbs(isbSn)}.a(offset_trl).s}')];

    fix_stats = cell2mat({dcm.sn{sn_sbs(isbSn)}.e(offset_trl).a}');

    if ~isempty(fix_stats) && ~isempty(flex_stats)
      dcm.stats(sbs_trl + cTrl, :) = [flex_stats, fix_stats];
    elseif ~isempty(fix_stats)
      dcm.stats(sbs_trl + cTrl, :) = fix_stats;
    elseif ~isempty(flex_stats)
      dcm.stats(sbs_trl + cTrl, :) = flex_stats;
    end

  end
  % set disabled trials to NaN (trials during missing data stretches or
  % that are too close to session end)
  dcm.stats(cTrl + find(trls(:, 1) == 0), :) = NaN;
  cTrl = cTrl + size(trls, 1);
end
dcm.names = {};
for iEvnt = 1:numel(dcm.sn{1}.a(1).a)
  dcm.names{iEvnt, 1} = sprintf('%s: amplitude', flexevntnames{iEvnt});
  dcm.names{iEvnt + numel(dcm.sn{1}.a(1).a), 1} = ...
    sprintf('%s: peak latency', flexevntnames{iEvnt});
  dcm.names{iEvnt + 2*numel(dcm.sn{1}.a(1).a), 1} = ...
    sprintf('%s: dispersion', flexevntnames{iEvnt});
end
cMsr = 3 * iEvnt;
if isempty(cMsr), cMsr = 0; end
for iEvnt = 1:numel(dcm.sn{1}.e(1).a)
  dcm.names{iEvnt + cMsr, 1} = sprintf('%s: response amplitude', fixevntnames{iEvnt});
end

if isfield(options, 'trlnames') && numel(options.trlnames) == size(dcm.stats, 1)
  dcm.trlnames = options.trlnames;
else
  for iTrl = 1:size(dcm.stats, 1)
    dcm.trlnames{iTrl} = sprintf('Trial #%d', iTrl);
  end
end

%% 8 Assemble input and save
dcm.dcmname = model.modelfile; % this field will be removed in the future
dcm.modelfile = model.modelfile;
dcm.input = model;
dcm.options = options;
dcm.warnings = warnings;
dcm.modeltype = 'dcm';
dcm.modality = settings.modalities.dcm;
if ~options.nosave
  save(model.modelfile, 'dcm');
end

end

function [datacol, warnings] = ...
  get_data_after_trial_filling_with_nans_when_necessary(...
  scr_sess, win, n, isbSn, sbs_iti, proc_miniti, warnings)
% Try to get all the data elements after the end of the trial n in session 
% isbSn. Indices of the elements to return are sto
% red in win. In case these indices are larger than size of scr_sess{isbSn}, then fill the
% rest of the data with NaN values.
datacol = NaN(1, numel(win));
num_indices_outside_scr = win(end) - numel(scr_sess);
if num_indices_outside_scr > 0
  warning('ID:too_short_ITI',...
    ['Trial %d in session %d has ITI %f; but for mean response we use %f seconds',...
    ' after each trial. Filling the rest with NaNs'],...
    n, isbSn, sbs_iti{isbSn}(n), proc_miniti(isbSn)...
    );
  [warnings{end+1,2},warnings{end+1,1}] = lastwarn;
  win(end - num_indices_outside_scr + 1 : end) = [];
  datacol(1:numel(win)) = scr_sess(win);
  datacol(numel(win) + 1 : end) = NaN;
else
  datacol(1:numel(win)) = scr_sess(win);
end
end
