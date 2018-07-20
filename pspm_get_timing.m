function [sts, outtiming] = pspm_get_timing(model, intiming, vararg)
% PSPM_GET_TIMING is a shared function to read timing information from
% different formats and align with a number of files. Time units (seconds,
% samples, markers) are not changed.
%
% FORMAT:
% [sts, multi]  = pspm_get_timing('onsets', intiming, timeunits)
% [sts, epochs] = pspm_get_timing('epochs', epochs, timeunits)
% [sts, events] = pspm_get_timing('events', events)
%
% for recursive calls also:
% [sts, epochs] = pspm_get_timing('file', filename)
%
% onsets: for defining event onsets for multiple conditions (e. g. GLM)
%      intiming is - a multiple condition file name (single session) OR
%                  - a cell array of multiple condition file names OR
%                  - a struct (single session) with fields .names, .onsets,
%                       and (optional) .durations, .pmod and .marker_cond .marker_cond_chan OR
%                       If .marker_cond is set to one, then the onsets
%                       should be set according to the values held in the
%                       marker channel(id of channel), which is indicated
%                       in .marker_cond_chan or the first marker channel
%                       Otherwise .names and .onsets are used
%                  - a cell array of struct
%
%      if timeunits are 'samples' or 'markers', all onsets must be integer
%
% epochs: for defining data epochs (e. g. analysis of SF, missing epochs in GLM)
%         epochs can be one of the following
%               - an SPM style onset file with two event types: onset &
%                    offset (names are ignored)
%               - a two-column text file with on/offsets
%               - a .mat file with a variable 'epochs' (see below)
%               - e x 2 matrix of epoch on- and offsets (e: number of
%                   epochs)
%
% events: for defining events and event windows (e. g. in DCM), events can
%         be either a variable that is, or a file name that contains a variable
%         'events' that is
%               - a .mat file with a variable 'events' (see below)
%               - a cell array with multiple one and two column vectors for
%                   fully flexible DCMs that must all have the same number of
%                   rows
%__________________________________________________________________________
% PsPM 3.0
% (C) 2009-2015 Dominik R Bach (WTCN, UZH)
%
% $Id$
% $Rev$

% -------------------------------------------------------------------------
% DEVELOPERS NOTES
% Differences in GLM multiple condition definitions between SPM and
% PsPM
% (1) 'durations' is optional - default is 0
% (2) 'durations' must be 0 if onsets are specified by markers
% (3) 'poly' is an optional field in pmods - default is 1. Polynomial
%     values larger than 1 are expanded here and returned as additional cells
%     for 'param'
% -------------------------------------------------------------------------

% initialise & define output
% -------------------------------------------------------------------------
global settings
if isempty(settings), pspm_init; end
sts = -1; outtiming = []; filewarning = 0;


% check input
% ------------------------------------------------------------------------
if nargin < 2
    warning('ID:invalid_input', 'No input. I don''t know what to do.');
    return;
else
    if ~ismember(model, {'onsets', 'epochs', 'events', 'file'})
        warning('ID:invalid_input', 'Invalid input. I don''t know what to do.');
        return;
    end
end


switch model
    case {'onsets', 'epochs'}
        if nargin < 3
            warning('ID:invalid_input', 'Time units unspecified'); return;
        else
            timeunits = vararg;
        end
end


% recursive option to retrieve file contents
% -------------------------------------------------------------------------
switch model
    case 'file'
        if ~ischar(intiming)
            warning('Specify file name as char with ''file'' option.'); return;
        elseif ~exist(intiming, 'file')
            warning('File (%s) doesn''t exist', intiming); return;
        else
            [pth, fn, ext] = fileparts(intiming);
            switch ext
                case {'.mat'} % matlab file
                    outtiming = load(intiming);
                otherwise
                    outtiming.epochs = dlmread(intiming);
                    if isempty(outtiming)
                        warning('Could not read text file %s', intiming);
                        return;
                    end
            end
        end
        
        % timing information for GLM (SPM style files with some slight variations)
        % -------------------------------------------------------------------------
    case 'onsets'
        sts = -1;
        multi = [];
        errmsg = 'Multiple condition information invalid:';
        if ~iscell(intiming)
            tmp = intiming;
            clear intiming;
            intiming{1} = tmp;
        end
        
        for iFile = 1:numel(intiming)
            % load regressor information from file if necessary --
            if ischar(intiming{iFile})
                [sts, in] = pspm_get_timing('file', intiming{iFile});
                %need to distinct if in comes from file or from manual
                %struct 
                in_from_file = 1;
                if sts < 1, return; end
            elseif isstruct(intiming{iFile})
                in = intiming{iFile};
                in_from_file = 0;
            else
                warning('The elements of intiming must be structs or filenames');
                return;
            end
            
            % check regressor information --
            if ~isfield(in, 'marker_cond')
                in.marker_cond = 0;
            % check whether all fields are present and in correct format:
            elseif ~isfield(in, 'marker_cond_chan')
                in.marker_cond_chan = 0;
            end
            
            % if falg to take the onsets from marker is set and the
            % structure is loades from a file 
            if  in.marker_cond ~= 0
                if in_from_file
                    if in.marker_cond_chan == 0
                        marker_chan = find(cellfun(@(x) strcmpi('marker', x.header.chantype),in.data),1);
                    else
                        marker_chan = in.marker_cond_chan;
                    end
                    
                    in.names = unique(in.data{marker_chan}.markerinfo.name);
                    in.onsets = in.data{marker_chan}.markerinfo.values;
                else
                    warning('ID:invalid_input', ['To extract the onsets from'],...
                        ['a marker channel, the input structure must be a file.']); return;
                end
                
            end
            
            if ~isfield(in, 'names') || ~isfield(in, 'onsets')
                warning('%sNo names or onsets.', errmsg); return;
            end
            
            if ~isfield(in, 'durations')
                in.durations = num2cell(zeros(numel(in.names), 1));
            end
            
            if ~iscell(in.names)||~iscell(in.onsets)
                warning('%sNames and onsets need to be cell arrays', errmsg);
                return;
            end
            % check number of conditions:
            if numel(in.names)~=numel(in.onsets)
                warning(['%sNumber of event names (%d) does ', ...
                    'not match the number of onsets (%d).'],...
                    errmsg, numel(in.names), numel(in.onsets));
                return;
            elseif numel(in.names)~=numel(in.durations)
                warning(['%sNumber of event names (%d) does not match ', ...
                    'the number of durations (%d).'], ...
                    errmsg, numel(in.onsets),numel(in.durations));
                return;
            end
            
            % check number of events and non-allowed values per condition:
            for iCond = 1:numel(in.names)
                if ~((isvector(in.onsets{iCond}) && ...
                        isnumeric(in.onsets{iCond})) || ...
                        (isempty(in.onsets{iCond}) && ...
                        ~strcmp('', in.onsets{iCond})))
                    warning('ID:no_numeric_vector', ...
                        ['%sCondition "%s" - onsets{%i} must be a ', ...
                        'numeric vector or empty.'], errmsg, ...
                        in.names{iCond}, iCond); return;
                end
                
                if numel(in.durations{iCond}) == 1
                    in.durations{iCond} = repmat(in.durations{iCond}, ...
                        numel(in.onsets{iCond}), 1);
                elseif (numel(in.onsets{iCond}) ~= numel(in.durations{iCond}))
                    warning(['%sCondition "%s" - Number of event onsets ', ...
                        '(%d) does not match the number of durations (%d).'],...
                        errmsg, in.names{iCond}, numel(in.onsets{iCond}),...
                        numel(in.durations{iCond}));
                    return;
                end
                if any(in.onsets{iCond}) < 0
                    warning(['%sCondition "%s" contains onset values ', ...
                        'smaller than zero'], errmsg, in.names{iCond});
                    return;
                end
                if any(strcmpi(timeunits, {'samples', 'markers'})) && ...
                        any(in.onsets{iCond} ~= ceil(in.onsets{iCond}))
                    warning(['%sCondition "%s" contains non-integer ', ...
                        'onset values but is defined in %s'], ...
                        errmsg, in.names{iCond}, timeunits);
                    return;
                end
                if strcmpi(timeunits, 'markers') && any(in.durations{iCond} ~= 0)
                    warning(['%sCondition "%s" contains non-zero ', ...
                        'durations - this is not allowed for marker time ', ...
                        'units. Please use ''samples'' or ', ...
                        '''seconds'' instead.'], errmsg, in.names{iCond});
                    return;
                end
                if any(in.durations{iCond} < 0)
                    warning(['%sConditions "%s% contains ', ...
                        'negative durations.'], errmsg, in.names{iCond});
                end
            end
            % check pmods:
            if isfield(in, 'pmod')
                % check consistency and add field
                if ~isstruct(in.pmod)
                    warning('%sPmod must be a struct variable.', errmsg);
                    return;
                elseif numel(in.pmod) > numel(in.names)
                    warning(['%sNumber of parametric modulators (%d) ', ...
                        'does not match the number of onsets (%d).'],...
                        errmsg, numel(in.pmod),numel(in.onsets)); return;
                elseif ~isfield(in.pmod, 'param') || ~isfield(in.pmod, 'name')
                    warning('%sFields are missing in pmod structure', errmsg);
                    return;
                elseif ~isfield(in.pmod, 'poly')
                    in.pmod(1).poly{1} = [];
                end
                % define new pmod struct with expanded polynomials
                in.pmodnew = struct('name', {}, 'param', {});
                % check individual pmods and expand polynomials
                for iPmod = 1:numel(in.pmod)
                    iParamNew = 1;
                    for iParam = 1:numel(in.pmod(iPmod).param)
                        if numel(in.onsets{iPmod}) ~= ...
                                numel(in.pmod(iPmod).param{iParam})
                            warning(['%s"%s" & "%s": Number of event ', ...
                                'onsets (%d) does not equal the number of ', ...
                                'parameters (%d).'],...
                                errmsg, in.names{iPmod}, ...
                                in.pmod(iPmod).name{iParam}, ...
                                numel(in.onsets{iPmod}), ...
                                numel(in.pmod(iPmod).param{iParam}));
                            return;
                        end
                        % set polynomial order if not specified
                        if ~iscell(in.pmod(iPmod).poly) || ...
                                numel(in.pmod(iPmod).poly) < iParam || ...
                                isempty(in.pmod(iPmod).poly{iParam})
                            in.pmod(iPmod).poly{iParam} = 1;
                        end
                        % expand
                        for iPoly = 1:in.pmod(iPmod).poly{iParam}
                            in.pmodnew(iPmod).param{iParamNew} = ...
                                (in.pmod(iPmod).param{iParam}).^iPoly;
                            in.pmodnew(iPmod).name{iParamNew}  = ...
                                sprintf('%s^%d', ...
                                in.pmod(iPmod).name{iParam}, iPoly);
                            iParamNew = iParamNew + 1;
                        end
                    end
                end
            end
            outtiming(iFile).names     = in.names;
            outtiming(iFile).onsets    = in.onsets;
            outtiming(iFile).durations = in.durations;
            if isfield(in, 'pmod')
                outtiming(iFile).pmod  = in.pmodnew;
            end
        end
        
        % clear local variables
        clear iParam iParamNew iCond iFile iPmod
        
        
% Epoch information for SF and GLM (model.missing)
% ------------------------------------------------------------------------
    case 'epochs'
        % get epoch information from file or from input --
        if ischar(intiming)
            [sts, in] = pspm_get_timing('file', intiming);
            if sts < 1, return; end;
            if isfield(in, 'epochs')
                outtiming = in.epochs;
            elseif isfield(in, 'onsets')
                onsets = in.onsets;
                onsetsflag = 0;
                if numel(onsets) == 2
                    if numel(onsets{1}) == numel(onsets{2})
                        outtiming(:, 1) = onsets{1};
                        outtiming(:, 2) = onsets{2};
                    else
                        filewarning = 1;
                    end
                else
                    filewarning = 1;
                end
            else
                filewarning = 1;
            end
            if filewarning
                warning('File %s is not a valid epochs or onsets file', ...
                    intiming);
                return;
            end
        else
            outtiming = intiming;
        end
        
        % check epoch information --
        if isnumeric(outtiming) && ismatrix(outtiming)
            if size(outtiming, 2) ~= 2
                warning(['Epochs must be specified by a e x 2 vector', ...
                    'of onset/offsets.']); return;
            end
        else
            warning('Unknown epoch definition format.'); return;
        end
        
        % check time units --
        if any(strcmpi(timeunits, {'samples', 'markers'})) && ...
                ~all(outtiming(:) == ceil(outtiming(:)))
            warning('ID:no_integers', ['Non-integer epoch definition when ', ...
                'time units are ''%s'''], timeunits); return;
        end
        
        
% Event information for DCM
% ------------------------------------------------------------------------
    case('events')
        if ~iscell(intiming)
            % recursive call to retrieve file
            [sts, in] = pspm_get_timing('file', intiming);
            if sts == -1, return; end
            if isfield(in, 'events')
                intiming = in.events;
            else
                warning('File must contain a variable called ''events''.');
                return;
            end
        end
        r = [];
        if isempty(intiming)
            warning('ID:invalid_input', 'No event data given.');
            return;
        end
        for k = 1:numel(intiming)
            [r(k), c] = size(intiming{k});
            if c > 2
                warning('ID:invalid_vector_size', ...
                    'Only one- and two-column vectors are allowed.');
                return;
            end
        end
        if any(r ~= r(1))
            warning('ID:invalid_vector_size', ...
                'All vectors must have the same number of rows.');
            return;
        end
        outtiming = intiming;
end

sts = 1;

return;
