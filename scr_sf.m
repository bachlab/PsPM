function outfile = scr_sf(model, options)
% SCR_SF is a wrapper function for analysis of tonic SC measures.
%
% FORMAT:
% outfile = scr_sf(model, options)
%       MODEL with required fields
%           model.datafile:  one data filename or cell array of filenames
%           model.modelfile: one data filename or cell array of filenames
%           model.timing:    can be one of the following
%               - an SPM style onset file with two event types: onset &
%                    offset (names are ignored)
%               - a .mat file with a variable 'epochs', see below
%               - a two-column text file with on/offsets
%               - e x 2 array of epoch on- and offsets, with
%                   e: number of epochs
%               or cell array of any of these, for multiple files
%           model.timeunits: seconds, samples, markers, whole (in the last case,
%                'timing' will be ignored and the entire file will be used)
%           
%       and optional fields:
%       method: 'auc', 'scl', 'dcm', or 'mp' (or a cell array of methods),
%                default: 'dcm'
%       model.filter:     filter settings; modality specific default
%       model.channel: channel number; default: first SCR channel
%
%       OPTIONS
%       options.overwrite - overwrite existing files
%       options.marker_chan_num: marker channel number - if undefined 
%                                     or 0, first marker channel is used
%       
%       additional options for individual methods:
%       DCM:
%       options.threshold: threshold for SN detection (default 0.1 mcS)
%       options.theta: a (1 x 5) vector of theta values for f_SF 
%           (default: read from scr_sf_theta)
%       options.fresp: frequency of responses to model (default 0.5 Hz)
%       options.dispwin: display progress window (default 1)
%       options.dispsmallwin: display intermediate windows (default 0);
%
% REFERENCE:
% DCM for SF --
% Bach DR, Daunizeau J, Kuelzow N, Friston KJ, Dolan RJ (2010). Dynamic
% causal modelling of spontaneous fluctuations in skin conductance.
% Psychophysiology, 48, 252-257.
% 
% AUC measure --
% Bach DR, Friston KJ, Dolan RJ (2010). Analytic measures for the
% quantification of arousal from spontanaeous skin conductance
% fluctuations. International Journal of Psychophysiology, 76, 52-55.
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (WTCN, UZH)
%
% $Id: scr_sf.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% ------------------------------------------------------------------------
% DEVELOPERS NOTE
% the output also contains a field .time that contains the inversion time
% in ms (for DCM and MP)
% ------------------------------------------------------------------------


% initialise
% ------------------------------------------------------------------------
global settings
if isempty(settings), scr_init; end;
outfile = [];

% check input
% ------------------------------------------------------------------------
% check missing input --
if nargin<1
    errmsg=sprintf('Nothing to do.'); warning('ID:invalid_input', errmsg); return;
elseif nargin<2
    options = struct();
end;

if ~isfield(model, 'datafile')
    warning('ID:invalid_input', 'No input data file specified.'); return;
elseif ~isfield(model, 'modelfile')
    warning('ID:invalid_input', 'No output model file specified.'); return;
elseif ~isfield(model, 'timeunits')
    warning('ID:invalid_input', 'No timeunits specified.'); return;
elseif ~isfield(model, 'timing') && ~strcmpi(model.timeunits, 'file')
    warning('ID:invalid_input', 'No epochs specified.'); return;
end;

% check faulty input --
if ~ischar(model.datafile) && ~iscell(model.datafile)
    warning('ID:invalid_input', 'Input data must be a cell or string.'); return;
elseif ~ischar(model.modelfile) && ~iscell(model.modelfile)
    warning('ID:invalid_input', 'Output model must be a string.'); return;
elseif ~ischar(model.timing) && ~iscell(model.timing) && ~isnumeric(model.timing)
    warning('ID:invalid_input', 'Event onsets must be a string, cell, or struct.'); return;
elseif ~ischar(model.timeunits) || ~ismember(model.timeunits, {'seconds', 'markers', 'samples', 'whole'})
    warning('ID:invalid_input', 'Timeunits (%s) not recognised; only ''seconds'', ''markers'', ''samples'' and ''whole'' are supported', model.timeunits); return;
end;

% convert single file input to cell --
if ischar(model.datafile)
    model.datafile={model.datafile};
end;
if ischar(model.timing) || isnumeric(model.timing)
    model.timing = {model.timing};
end;
if ischar(model.modelfile) 
    model.modelfile = {model.modelfile};
end;

% check number of files --
if ~strcmpi(model.timeunits, 'whole') && numel(model.datafile) ~= numel(model.timing)
    warning('ID:number_of_elements_dont_match', 'Number of data files and epoch definitions does not match.'); return;
elseif numel(model.datafile) ~= numel(model.modelfile)
    warning('ID:number_of_elements_dont_match', 'Number of data files and model files does not match.'); return;
end;

% check methods --
if ~isfield(model, 'method')
    model.method = {'dcm'};
elseif ischar(model.method)
    model.method={model.method}; 
end;
if ~iscell(model.method)
    warning('Method needs to be a char or cell array'); return;
else
    method = cell(numel(model.method), 1);
    fhandle = method;
    datatype = NaN(numel(model.method));
    for k = 1:numel(model.method)
        switch model.method{k}
            case {'auc', 'AUC'}
                method{k} = 'auc';
                fhandle{k} = @scr_sf_auc;
                datatype(k) = 2; % filtered
            case {'DCM', 'dcm'}
                method{k} = 'dcm';
                fhandle{k} = @scr_sf_dcm;
                datatype(k) = 2; % filtered
            case {'MP', 'mp'}
                method{k} = 'mp';
                fhandle{k} = @scr_sf_mp;
                datatype(k) = 2; % filtered
            case {'SCL', 'scl', 'level'}
                method{k} = 'scl';
                fhandle{k} = @scr_sf_scl;
                datatype(k) = 1; % unfiltered
            case 'all'
                method = {'scl', 'auc', 'dcm', 'mp'};
                fhandle = {@scr_sf_scl, @scr_sf_auc,  @scr_sf_dcm, @scr_sf_mp};
                datatype = [1 2 2 2];
            otherwise
                warning('Method %s not supported', model.method{k}); return;
        end;
    end;
end;

% check timing --
if strcmpi(model.timeunits, 'whole');
   epochs = repmat({[1 1]}, numel(model.datafile), 1);
else
    for iSn = 1:numel(model.datafile)
        [sts, epochs{iSn}] = scr_get_timing('epochs', model.timing{iSn}, model.timeunits);
        if sts == -1, return; end;
    end;
end;

% check filter --
if ~isfield(model, 'filter')
    model.filter = settings.dcm{2}.filter;
elseif ~isfield(model.filter, 'down') || ~isnumeric(model.filter.down)
    warning('ID:invalid_input', 'Filter structure needs a numeric ''down'' field.'); return;
end;

% set options --
try model.channel; catch, model.channel = 'scr'; end;
try options.overwrite; catch, options.overwrite = 0; end;
if ~isfield(options,'marker_chan_num') || ~isnumeric(options.marker_chan_num) || numel(options.marker_chan_num) > 1
    options.marker_chan_num = 0;
end;

% get data
% ------------------------------------------------------------------------
for iFile = 1:numel(model.datafile)
    % user output --
    fprintf('SF analysis: %s ...', model.datafile{iFile});
    % check whether model file exists --
    if exist(model.modelfile{iFile}) == 2 && ~options.overwrite
        overwrite=menu(sprintf('Output file (%s) already exists. Overwrite?', model.modelfile{iFile}), 'yes', 'no');
        % close gcf;
        if overwrite == 2, continue; end;
    end;
    % get and filter data --
    [sts, infos, data] = scr_load_data(model.datafile{iFile}, model.channel);
    if sts < 0, return; end;
    Y{1} = data{1}.data; sr(1) = data{1}.header.sr;
    model.filter.sr = sr(1); 
    [sts, Y{2}, sr(2)] = scr_prepdata(data{1}.data, model.filter);
    % check data units --
    if ~strcmpi(data{1}.header.units, 'uS') && any(strcmpi('dcm', method))
        fprintf('\nYour data units are stored as %s, and the method will apply an amplitude threshold in uS. Please check your results.\n', ...
            data{1}.header.units);
    end;
    % get marker data --
    if any(strcmp(model.timeunits, {'marker', 'markers'}))
        if options.marker_chan_num
            [nsts, ninfos, ndata] = scr_load_data(datafile, options.marker_chan_num);
            if ~strcmp(ndata{1}.header.chantype, 'marker')
                warning('ID:invalid_option', 'Channel %i is no marker channel. The first marker channel in the file is used instead', options.marker_chan_num);
                [nsts, ninfos, ndata] = scr_load_data(datafile, 'marker');
            end
        else
            [nsts, ninfos, ndata] = scr_load_data(datafile, 'marker');
        end;
        events = data{1}.data;
    end;
    if sts < 0, return; end;
    for iEpoch = 1:size(epochs{iFile}, 1)
        if iEpoch > 1, fprintf('\n\t\t\t'); end;
        fprintf('epoch %01.0f ...', iEpoch);
        for k = 1:numel(method)
            fprintf('%s ', method{k});
            switch model.timeunits
                case 'seconds'
                    win = round(epochs{iFile}(iEpoch, :) * sr(datatype(k)));
                case 'samples'
                    win = round(epochs{iFile}(iEpoch, :) * sr(datatype(k)) / sr(1));
                case 'markers'
                    win = round(events(epochs{1}(iEpoch, :)) * sr(datatype(k)));
                case 'whole'
                    win = [1 numel(Y{datatype(k)})];
            end;
            if any(win > numel(Y{datatype(k)}) + 1) || any(win < 0)
                warning(sprintf('\nEpoch %2.0f outside of file %s ...', iEpoch, fname{iFile}));
            else
                % correct issues with using 'round'
                win(1) = max(win(1), 1);
                win(2) = min(win(2), numel(Y{datatype(k)}));
            end;
            % collect information --
            sf.(method{k})(iEpoch).boundaries = squeeze(epochs{iFile}(iEpoch, :));
            sf.(method{k})(iEpoch).timeunits  = model.timeunits;
            sf.(method{k})(iEpoch).samples    = win;
            sf.(method{k})(iEpoch).sr         = sr(datatype(k));
            escr = Y{datatype(k)}(win(1):win(end));
            sf.(method{k})(iEpoch).data = escr;
            % do the analysis and collect results --
            invrs = fhandle{k}(escr, sr(datatype(k)), options);
            if any(strcmpi(method{k}, {'dcm', 'mp'}))
                sf.(method{k})(iEpoch).inv     = invrs;
                sf.stats(iEpoch, k)            = invrs.f;
            else
                sf.(method{k})(iEpoch).stats   = invrs;
                sf.stats(iEpoch, k)            = invrs;
            end;
        end;
        sf.trlnames{iEpoch} = sprintf('Epoch #%d', iEpoch);
    end;
    sf.names = method(:);
    sf.infos.date = date;
    sf.infos.file = model.modelfile{iFile};
    sf.modelfile = model.modelfile{iFile};
    sf.data = Y;
    if exist('events','var'), sf.events = events; end;
    sf.input = model;
    sf.options = options;
    modeltype = 'sf';
    save(model.modelfile{iFile}, 'sf', 'modeltype');
    fprintf('\n');
end;
