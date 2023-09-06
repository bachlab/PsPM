function model = pspm_check_model(model, modeltype)

% mandatory fields 
% .modelfile (a string for all models, or a cell array of string for SF)
% .datafile
% .timing (DCM)
% .timing OR .nuisance (GLM)
% .timing OR .timeunits == 'whole' (SF)
% .timeunits (GLM, SF)
% 
% and optional fields
% .missing 
% .latency and .window (GLM)
% .bf (GLM)
% .modelspec (GLM)
% .channel (GLM)
% .centering (GLM)

% 0. Initialise
global settings
if isempty(settings)
  pspm_init;
end

% 1. General checks  ------------------------------------------------------
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

% 2. Reject missing mandatory fields common to all models -----------------
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
elseif ~ischar(model.modelfile) && ~strmpci (modeltype, 'sf')
  warning('ID:invalid_input', 'Output model must be a string.'); return;
elseif ischar(model.modelfile) && strmpci (modeltype, 'sf') 
    model.modelfile = {model.modelfile};
end

% 3. Fill missing fields common to all models, and accept only allowed values
if ~isfield(model, 'norm')
  model.norm = 0;
elseif ~any(ismember(model.norm, [0, 1]))
  warning('ID:invalid_input', 'Normalisation must be specified as 0 or 1.'); return;
end
if ~isfield(model, 'timing')
    model.timing = cell(nFile, 1);
elseif ischar(model.timing) || isnumeric(model.timing)
    model.timing = {model.timing};
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

% 4. Check that session-related field entries have compatible size
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

% 5. Check validity of missing epochs
for iFile = 1:nFile
    if ~isempty(model.missing{iFile})
        sts = pspm_get_timing(model.missing{iFile});
        if sts < 1, return, end
    end
end

% 6. GLM-specific checks
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
    elseif strcmpi(model.latency, 'free') && (~isnumeric(model.window) || isempty(model.window))
      warning('ID:invalid_input', 'Window is expected to be a numeric value.'); return;
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
    elseif ~(ischar(model.bf.handle) || isa(model.bf.fhandle, 'function_handle'))
        warning('Basis function must be a string or function handle.'); return
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


% 7. DCM-specific check
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

% 8. SF-specific check
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


% General checks that require GLM-specific checks in case of GLM
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