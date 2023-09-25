function model = pspm_check_model(model, modeltype)
% ● Definition
%   pspm_check_model automatically determine the fields of the struct model
%   for the corresponding function.
% ● Format
%   model = pspm_check_model(model, modeltype)
% ● Arguments
%   ┌──────model:
%   │ ▶︎ mandatory
%   ├──.datafile: Values (any of the following)
%   │               * A file name (single session)
%   │               * A cell array of file names (multiple sessions)
%   ├─.modelfile: a file name for the model output
%   │ ├─.modelfile (GLM, DCM)
%   │ │             * A file name
%   │ └─.modelfile (SF)
%   │               * A file name (single data file)
%   │               * A cell array of file names (multiple data files)
%   ├─.timeunits:
%   │ ├─.timeunits (GLM)
%   │ │           Acceptable values:
%   │ │             'seconds', 'samples', 'markers', or 'markervalues'
%   │ └─.timeunits (SF)
%   │             Acceptable values:
%   │               'seconds', 'samples', or 'markers'
%   ├─.timing:
%   │ ├─.timing (DCM):
%   │ │           Acceptable values (any of the following):
%   │ │             * A file name/cell array of events (single session);
%   │ │             * A cell array of file names/cell arrays.
%   │ │           Descriptions:
%   │ │             * When specifying file names, each file must be a *.mat
%   │ │               file that contain a cell variable called 'events'.
%   │ │             * Each cell should contain either one column (fixed
%   │ │               response) or two columns (flexible response).
%   │ │             * All matrices in the array need to have the same
%   │ │               number of rows, i.e. the event structure must be the
%   │ │               same for every trial. If this is not the case,
%   │ │               include `dummy` events with negative onsets.
%   │ ├─.timing (GLM):
%   │ │           Acceptable values (any of the following):
%   │ │             * A multiple condition file name (single session);
%   │ │             * A cell array of multiple condition file names;
%   │ │             * A struct (single session) or a cell array of struct
%   │ │               (multiple sessions), where each struct show have the
%   │ │               following fields:
%   │ │               * .names (mandatory)
%   │ │               * .onsets (mandatory)
%   │ │               * .durations (optional)
%   │ │               * .pmod (optional)
%   │ │             * A struct (single session) or a cell array of struct
%   │ │               (multiple sessions), if model.timeunits is set as
%   │ │               'markervalues', where each
%   │ │               struct show have the following fields:
%   │ │               * .markervalues
%   │ │               * .names
%   │ └─.timing (SF) OR .timeunits == 'whole' (SF)
%   │             Acceptable values (any of the following):
%   │               * A SPM style onset file with two following event types:
%   │                 * onset
%   │                 * offset (names are ignored)
%   │               * a .mat file with a variable 'epochs', see below
%   │               * a two-column text file with on/offsets
%   │               * e x 2 array of epoch on- and offsets, with e: number
%   │                 of epochs or cell array of any of these, for multiple
%   │                 files.
%   │ ▶︎ optional
%   ├───.missing: allows to specify missing (e. g. artefact) epochs in the
%   │             data file. See pspm_get_timing for epoch definition;
%   │             specify a cell array for multiple input files. This
%   │             must always be specified in SECONDS.
%   │             Default: no missing values
%   ├───.channel: channel number (or, for GLM, channel type).
%   │             If a channel type is specified the LAST channel matching
%   │             the given type will be used. The rationale for this is
%   │             that, in general channels later in the channel list are
%   │             preprocessed/filtered versions of raw channels.
%   │             SPECIAL: if 'pupil' is specified the function uses the
%   │             last pupil channel returned by
%   │             <a href="matlab:help pspm_load_data">pspm_load_data</a>.
%   │             pspm_load_data loads 'pupil' channels according to a
%   │             specific precedence order described in its documentation.
%   │             In a nutshell, it prefers preprocessed channels and
%   │             channels from the best eye to other pupil channels.
%   │             SPECIAL: for the modality 'sps', the model.channel
%   │             accepts only 'sps_l', 'sps_r', or 'sps'.
%   │             DEFAULT: last channel of the specified modality for GLM;
%   │             'scr' for DCM and SF
%   ├─────.norm:  normalise data; default 0
%   ├───.filter:  filter settings; modality specific default
%   │
%   │ ▶︎ optional, GLM (modeltype) only
%   ├───.latency: allows to specify whether latency should be 'fixed'
%   │             (default) or should be 'free'. In 'free' models an
%   │             additional dictionary matching algorithm will try to
%   │             estimate the best latency. Latencies will then be added
%   │             at the end of the output. In 'free' models the fiel
%   │             model.window is MANDATORY and single basis functions
%   │             are allowed only.
%   ├───.window:  only required if model.latency equals 'free' and ignored
%   │             otherwise. A scalar or 2-element vector in seconds that
%   │             specifies over which time window (relative to the event
%   │             onsets specified in model.timing) the model should be
%   │             evaluated.
%   ├────────.bf: basis function/basis set; modality specific default
%   │             with subfields .fhandle (function handle or string) and
%   │             .args (arguments, first argument sampling interval will
%   │             be added by pspm_glm). The optional subfield .shiftbf = n
%   │             indicates that the onset of the basis function precedes
%   │             event onsets by n seconds (default: 0: used for
%   │             interpolated data channels)
%   ├─.modelspec: 'scr' (default); specify the model to be used.
%   │             See pspm_init, defaults.glm() which modelspecs are
%   │             possible with glm.
%   ├─.nuisance:  allows to specify nuisance regressors. Must be a file
%   │             name; the file is either a .txt file containing the
%   │             regressors in columns, or a .mat file containing the
%   │             regressors in a matrix variable called R. There must be
%   │             as many values for each column of R as there are data
%   │             values. SCRalyze will call these regressors R1, R2, ...
%   ├─.centering: if set to 0 the function would not perform the
%   │             mean centering of the convolved X data. For example, to
%   │             invert SPS model, set centering to 0. Default: 1
%   │
%   │ ▶︎ optional, DCM (modeltype) only
%   ├─.lasttrialcutoff:
%   │             If there fewer data after the end of then last trial in a
%   │             session than this cutoff value (in s), then estimated
%   │             parameters from this trial will be assumed inestimable
%   │             and set to NaN after the
%   │             inversion. This value can be set as inf to always retain
%   │             parameters from the last trial.
%   │             Default: 7 s
%   ├─.substhresh:Minimum duration (in seconds) of NaN periods to cause
%   │             splitting up into subsessions which get evaluated
%   │             independently (excluding NaN values).
%   │             Default: 2.
%   ├─.constrained: Constrained model for flexible responses which have
%   │             fixed dispersion (0.3 s SD) but flexible latency.
%   │
%   │ ▶︎ optional, SF (modeltype) only
%   └─────method: [string/cell_array]
%                 [string] either 'auc', 'scl', 'dcm' (default), or 'mp'.
%                 [cell_array] a cell array of methods mentioned above.
%
% ● History
%   Introduced in PsPM 6.2
%   Written in 2023 by Dominik Bach (UCL and Bonn)

% 0. Initialise
global settings
if isempty(settings)
  pspm_init;
end

%% 1. General checks  ------------------------------------------------------
if ~isstruct(model)
  warning('ID:invalid_input', 'Model must be a struct.');
  model = struct('invalid', 1);
  return
else
  model.invalid = 1;
  if isempty(model)
    warning('ID:invalid_input', 'Model is empty.');
    return
  end
end

%% 2. Reject missing mandatory fields common to all models -----------------
if ~isfield(model, 'datafile')
  warning('ID:invalid_input', 'No input data file specified.'); return;
elseif ~isfield(model, 'modelfile')
  warning('ID:invalid_input', 'No output model file specified.'); return;
elseif ischar(model.datafile)
    model.datafile = {model.datafile};
end
nFile = numel(model.datafile);

% 3. Reject wrong type of mandatory fields --------------------------------
if ~iscell(model.datafile) && ~ischar(model.datafile)
  warning('ID:invalid_input', 'Input data must be a cell or string.'); return;
elseif ~ischar(model.modelfile) && ~strcmpi (modeltype, 'sf')
  warning('ID:invalid_input', 'Output model must be a string.'); return;
elseif ischar(model.modelfile) && strcmpi (modeltype, 'sf')
    model.modelfile = {model.modelfile};
end

% NOTE we need to separate the case of DCM timing being
% . a cell array of cell arrays
% . just a cell array

%% 3. Fill missing fields common to all models, and accept only allowed values
if ~isfield(model, 'timing')
    model.timing = cell(nFile, 1);
else
  if ~isempty(model.timing)
    if ~iscell(model.timing) || ...
      strcmpi(modeltype, 'dcm') && ~iscell(model.timing{1})
      % for DCM, model.timing is either a file name or a cell array of
      % events, or a cell array of file names or cell arrays, so we need to
      % take care of cases where model.timing is a cell array but not a cell
      % array of cell arrays
      model.timing = {model.timing};
    end
  end
end
if ~isfield(model, 'missing')
  model.missing = cell(nFile, 1);
elseif ischar(model.missing) || isnumeric(model.missing)
  model.missing = {model.missing};
elseif ~iscell(model.missing)
  warning('ID:invalid_input',...
    'Missing values must be a filename, matrix, or cell array of these.');
  return
end
if ~isfield(model, 'norm')
  model.norm = 0;
elseif ~any(ismember(model.norm, [0, 1]))
  warning('ID:invalid_input', 'Normalisation must be specified as 0 or 1.'); return;
end

%% 4. Check that session-related field entries have compatible size
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

%% 5. Check validity of missing epochs
for iFile = 1:nFile
    if ~isempty(model.missing{iFile})
        sts = pspm_get_timing('missing', model.missing{iFile}, 'seconds');
        if sts < 1, return, end
    end
end

%% 6. GLM-specific checks
% -------------------------------------------------------------------------
if strcmpi(modeltype, 'glm')

    % Reject missing or invalid mandatory fields
    if ~isfield(model, 'timeunits')
        warning('ID:invalid_input', 'No timeunits specified.'); return;
    elseif ~ischar(model.timeunits) || ~ismember(model.timeunits, {'seconds', 'markers', 'samples','markervalues'})
        warning('ID:invalid_input', 'Timeunits (%s) not recognised; only ''seconds'', ''markers'' and ''samples'' are supported', model.timeunits); return;
    elseif sum(cellfun(@(f) isempty(f), model.timing)) > 0
        % model.timing not defined -> check whether model.nuisance is defined
        if ~isfield(model, 'nuisance') || isempty(model.nuisance) || ...
            iscell(model.nuisance) && (sum(cellfun(@(f) isempty(f), model.nuisance)) == numel(model.nuisance))
            warning('ID:invalid_input', 'Event onsets and nuisance file are not specified. At least one of the two must be specified.'); return;
        end
     else  % model.timing is defined -> check timing definition
        for iFile = 1:nFile
            sts = pspm_get_timing('onsets', model.timing{iFile}, model.timeunits);
            if sts < 1, return; end
        end
    end

    % Check optional fields, set default values and reject invalid values
    if ~isfield(model, 'latency')
      model.latency = 'fixed';
    elseif ~ismember(model.latency, {'free', 'fixed'})
      warning('ID:invalid_input', 'Latency should be either ''fixed'' or ''free''.'); return;
    elseif strcmpi(model.latency, 'free') && (~isfield(model, 'window') || ...
            isempty(model.window) || ~isnumeric(model.window))
      warning('ID:invalid_input', 'Window is expected to be a numeric value.'); return;
    elseif strcmpi(model.latency, 'free') && numel(model.window) == 1
      model.window = [0, model.window];
    elseif strcmpi(model.latency, 'free') && numel(model.window) > 2
      warning('ID:invalid_input', 'Only first two elements of model.window are used');
      model.window = model.window(1:2);
    elseif strcmpi(model.latency, 'fixed') && isfield(model, 'window')
      warning('ID:invalid_input', 'model.window was provided but will be ignored');
      model = rmfield(model, 'window');
    end

    if strcmpi(model.latency, 'free') && diff(model.window < 0)
        warning('ID:invalid_input', 'model.window invalid');
    end

    if ~isfield(model, 'modelspec')
        model.modelspec = settings.glm(1).modelspec;
    elseif ~ismember(model.modelspec, {settings.glm.modelspec})
      warning('ID:invalid_input', 'Unknown model specification %s.', model.modelspec); return;
    end

    modno = find(strcmpi(model.modelspec, {settings.glm.modelspec}));
    model.modality = settings.glm(modno).modality;

    if ~isfield(model, 'bf')
        model.bf = settings.glm(modno).cbf;
    elseif ~isfield(model.bf, 'fhandle')
        warning('No basis function given.'); return
    elseif ~(ischar(model.bf.fhandle) || isa(model.bf.fhandle, 'function_handle'))
        warning('Basis function must be a string or function handle.'); return
    elseif ischar(model.bf.fhandle) && ~exist(model.bf.fhandle, 'file')
        warning('ID:invalid_fhandle', 'Specified basis function %s doesn''t exist or is faulty', model.bf.fhandle); return;
    elseif ~isfield(model.bf, 'args')
        model.bf.args = [];
    elseif ~isnumeric(model.bf.args)
        warning('Basis function arguments must be numeric.'); return
    end

    if ~isfield(model, 'channel')
        if strcmp(model.modality, 'psr')
            model.channel = 'pupil';
        else
            model.channel = model.modality;
        end
    elseif ~isnumeric(model.channel) && ~ismember(model.channel, {settings.channeltypes.type})
        warning('ID:invalid_input', 'Channel number must be numeric or a modality short name.'); return;
    end

    if ~isfield(model,'centering')
      model.centering = 1;
    elseif ~ismember(model.centering, [0, 1])
        warning('ID:invalid_input', 'Mean centering must be specified as 0 or 1.'); return;
    end

end


%% 7. DCM-specific check
% -------------------------------------------------------------------------
if strcmpi(modeltype, 'dcm')

    % Reject missing or invalid mandatory fields
    if sum(cellfun(@(f) isempty(f), model.timing)) > 0
        warning('ID:invalid_input', 'No event onsets specified.'); return;
    else
        for iFile = 1:nFile
            sts = pspm_get_timing('events', model.timing{iFile});
            if sts < 1, return; end
        end
    end

    % Check optional fields, set default values and reject invalid values
    if ~isfield(model, 'channel')
        model.channel = 'scr'; % this returns the last SCR channel
    elseif ~isnumeric(model.channel) && ~strcmp(model.channel,'scr')
        warning('ID:invalid_input', 'Channel number must be numeric or SCR.'); return;
    end

    if ~isfield(model, 'constrained')
        model.constrained = 0;
    elseif ~any(ismember(model.constrained, [0, 1]))
        warning('ID:invalid_input', 'Constrained model must be specified as 0 or 1.'); return;
    end

    if ~isfield(model, 'substhresh')
        model.substhresh = 2;
    elseif ~isnumeric(model.substhresh)
        warning('ID:invalid_input', 'Subsession threshold must be numeric.');
        return;
    end

    if ~isfield(model, 'lasttrialcutoff')
        model.lasttrialcutoff = 7;
    elseif ~isnumeric(model.lasttrialcutoff)
        warning('ID:invalid_input', 'Last trial cutoff threshold must be numeric.');
        return;
    end

end

%% 8. SF-specific check
% -------------------------------------------------------------------------
if strcmpi(modeltype, 'sf')

    % Reject missing or invalid mandatory fields
    if ~isfield(model, 'timeunits')
        warning('ID:invalid_input', 'No timeunits specified.'); return;
    elseif ~ischar(model.timeunits) || ~ismember(model.timeunits, {'seconds', 'markers', 'samples','whole'})
        warning('ID:invalid_input', 'Timeunits (%s) not recognised; only ''seconds'', ''markers'', ''samples'' and ''whole'' are supported', model.timeunits); return;
    elseif ~strcmpi(model.timeunits, 'whole') && sum(cellfun(@(f) isempty(f), model.timing)) > 0
        warning('ID:number_of_elements_dont_match',...
            'Number of data files and epoch definitions does not match.'); return;
    elseif numel(model.modelfile) ~= nFile
        warning('ID:number_of_elements_dont_match',...
            'Number of data files and model files does not match.'); return;
    end

    % Check optional fields, set default values and reject invalid values
    if ~isfield(model, 'channel')
        model.channel = 'scr'; % this returns the last SCR channel
    elseif ~isnumeric(model.channel) && ~strcmp(model.channel,'scr')
        warning('ID:invalid_input', 'Channel number must be numeric or SCR.'); return;
    end

    if ~isfield(model, 'method')
      model.method = {'dcm'};
    elseif ischar(model.method)
      model.method={model.method};
    elseif ~iscell(model.method)
      warning('Method needs to be a char or cell array'); return;
    end

end


%% 9. General checks that require GLM-specific checks in case of GLM
% -------------------------------------------------------------------------
if ~isfield(model, 'filter')
    switch modeltype
        case 'glm'
            model.filter = settings.glm(modno).filter;
        case 'dcm'
            model.filter = settings.dcm{1}.filter;
        case 'sf'
            model.filter = settings.dcm{2}.filter;
    end
end

if ~isfield(model.filter, 'down') || ~isnumeric(model.filter.down)
    warning('ID:invalid_input', 'Filter structure needs a numeric ''down'' field.'); return;
end


% validate
% -------------------------------------------------------------------------
model.invalid = 0;
