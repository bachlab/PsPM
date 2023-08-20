function model = pspm_check_model(model, modeltype)

% General checks
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

% 1. Reject missing mandatory fields common to all models
if ~isfield(model, 'datafile')
  warning('ID:invalid_input', 'No input data file specified.'); return;
elseif ~isfield(model, 'modelfile')
  warning('ID:invalid_input', 'No output model file specified.'); return;
elseif ~isfield(model, 'timing')
  warning('ID:invalid_input', 'No event onsets specified.'); return;
end

% 2. Reject wrong type of mandatory fields
if ~iscell(model.datafile) && ~ischar(model.datafile)
  warning('ID:invalid_input', 'Input data must be a cell or string.'); return;
elseif ~ischar(model.modelfile)
  warning('ID:invalid_input', 'Output model must be a string.'); return;
elseif ~ischar(model.timing) && ~iscell(model.timing) && ~isstruct(model.timing)
  warning('ID:invalid_input', 'Event definition must be a string, cell array, or (for GLM) struct.'); return;
end

% 3. Fill missing fields common to all models, and accept only allowed values
if ~isfield(model, 'norm')
  model.norm = 0;
elseif ~any(ismember(model.norm, [0, 1]))
  warning('ID:invalid_input', 'Normalisation must be specified as 0 or 1.'); return;
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

% 4. Check that data files, timing, and missing values are cell arrays with
% matching size
if ischar(model.datafile)
  model.datafile = {model.datafile};
  model.timing   = {model.timing};
end

nFile = numel(model.datafile);
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

% GLM-specific checks
% -------------------------------------------------------------------------
if strcmpi(modeltype, 'glm')
    % Reject missing mandatory fields
    if ~isfield(model, 'timeunits')
        warning('ID:invalid_input', 'No timeunits specified.'); return;
    end
end


% DCM-specific check
% -------------------------------------------------------------------------
if strcmpi(modeltype, 'dcm')
    if ~ischar(model.timing) && ~iscell(model.timing)
        warning('ID:invalid_input', 'Event definition must be a string or cell array.'); return;
    end
    % Fill missing fields and detect wrong values
    if ~isfield(model, 'channel')
        model.channel = 'scr'; % this returns the last SCR channel
    elseif ~isnumeric(model.channel) && ~strcmp(model.channel,'scr')
        warning('ID:invalid_input', 'Channel number must be numeric.'); return;
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
end



% General checks that require GLM-specific checks in case of GLM
% -------------------------------------------------------------------------
if ~isfield(model, 'filter')
    if strcmpi(modeltype, 'glm')
        model.filter = settings.glm(modno).filter;
elseif strcmpi(modeltype, 'dcm')
  model.filter = settings.dcm{1}.filter;
elseif ~isfield(model.filter, 'down') || ~isnumeric(model.filter.down)
  warning('ID:invalid_input', 'Filter structure needs a numeric ''down'' field.'); return;
end


% 2.7 check filter --



try model.lasttrialcutoff;      catch, model.lasttrialcutoff = 7;       end


model.invalid = 0;