function dcm = scr_dcm(model, options)
% SCR_DCM sets up a DCM for skin conductance, prepares and normalises the 
% data, passes it over to the model inversion routine, and saves both the 
% forward model and its inversion
%
% Both flexible-latency (within a response window) and fixed-latency 
% (evoked after a specified event) responses can be modelled. For fixed
% responses, delay and dispersion are assumed to be constant (either
% pre-determined or estimated from the data), while for flexible responses,
% both are estimated for each individual trial. Flexible responses can for
% example be anticipatory, decision-related, or evoked with unknown onset.
%
% FORMAT dcm = scr_dcm(model, options)
%
% MODEL with required fields
% model.modelfile:  a file name for the model output
% model.datafile:   a file name (single session) OR
%                   a cell array of file names
% model.timing:     a file name/cell array of events (single session) OR
%                   a cell array of file names/cell arrays
%                   When specifying file names, each file must be a *.mat 
%                      file that contain a cell variable called 'events' 
%                   Each cell should contain either one column 
%                      (fixed response) or two columns (flexible response). 
%                   All matrices in the array need to have the same number 
%                    of rows, i.e. the event structure must be the same for 
%                    every trial. If this is not the case, include "dummy" 
%                    events with negative onsets
%
% and optional fields
% model.filter:     filter settings; modality specific default
% model.channel:    channel number; default: first SCR channel
% model.norm:       normalise data; default 0 (i. e. data are normalised
%                   during inversion but results transformed back into raw 
%                   data units)
%
% OPTIONS with optional fields:
% response function options
% - options.crfupdate: update CRF priors to observed SCRF, or use
%                      pre-estimated priors (default)
% - options.indrf: estimate the response function from the data (default 0)
% - options.getrf: only estimate RF, do not do trial-wise DCM
% - options.rf: call an external file to provide response function (for use
%               when this is previously estimated by scr_get_rf)
%
% inversion options
% - options.depth: no of trials to invert at the same time (default: 2)
% - options.sfpre: sf-free window before first event (default 2 s)
% - options.sfpost: sf-free window after last event (default 5 s)
% - options.sffreq: maximum frequency of SF in ITIs (default 0.5/s)
% - options.sclpre: scl-change-free window before first event (default 2 s)
% - options.sclpost: scl-change-free window after last event (default 5 s)
% - options.aSCR_sigma_offset: minimum dispersion (standard deviation) for
%   flexible responses (default 0.1 s)
%
% display options
% - options.dispwin: display progress window (default 1)
% - options.dispsmallwin: display intermediate windows (default 0);
%
% output options
% - options.nosave: don't save dcm structure (e. g. used by scr_get_rf)
%
% naming options
% - options.trlnames: cell array of names for individual trials, is used for
%   contrast manager only (e. g. condition descriptions)
% - options.eventnames: cell array of names for individual events, in the
%   order they are specified in the model.timing array - to be used for
%   display and export only
% 
% OUTPUT:   fn - name of the model file
%           dcm - model struct
%
% Output units: all timeunits are in seconds; eSCR and aSCR amplitude are
% in SN units such that an eSCR SN pulse with 1 unit amplitude causes an eSCR
% with 1 mcS amplitude
%
% scr_dcm can handle NaN values in data channels. These are disregarded
% during model inversion, and trials containing NaNs are interpolated for
% averages and principal response components. It is not recommended to use
% this feature for missing data epochs with a duration of > 1-2 s
%
% REFERENCE: (1) Bach DR, Daunizeau J, Friston KJ, Dolan RJ (2010).
%            Dynamic causal modelling of anticipatory skin conductance 
%            changes. Biological Psychology, 85(1), 163-70
%            (2) Staib, M., Castegnetti, G., & Bach, D. R. (2015).
%            Optimising a model-based approach to inferring fear
%            learning from skin conductance responses. Journal of
%            Neuroscience Methods, 255, 131-138.
%
%__________________________________________________________________________
% PsPM 3.0
% (c) 2010-2015 Dominik R Bach (WTCN, UZH)

% $Id$  
% $Rev$

% function revision
rev = '$Rev$';

% initialise & set output
% ------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
warnings = {};

dcm = [];

% check input arguments & set defaults
% -------------------------------------------------------------------------
if nargin < 1
    warning('No data to work on.'); ofn = []; return;
elseif nargin < 2
    options = struct([]);
end;


if ~isfield(model, 'datafile')
    warning('ID:invalid_input', 'No input data file specified.'); return;
elseif ~isfield(model, 'modelfile')
    warning('ID:invalid_input', 'No output model file specified.'); return;
elseif ~isfield(model, 'timing')
    warning('ID:invalid_input', 'No event onsets specified.'); return;
end;

% check faulty input --
if ~ischar(model.datafile) && ~iscell(model.datafile)
    warning('ID:invalid_input', 'Input data must be a cell or string.'); return;
elseif ~ischar(model.modelfile)
    warning('ID:invalid_input', 'Output model must be a string.'); return;
elseif ~ischar(model.timing) && ~iscell(model.timing) 
    warning('ID:invalid_input', 'Event definition must be a string or cell array.'); return;
end;

% get further input or set defaults --
% check data channel --
if ~isfield(model, 'channel')
    model.channel = 'scr'; % this returns the first SCR channel 
elseif ~isnumeric(model.channel)
    warning('ID:invalid_input', 'Channel number must be numeric.'); return;
end;


% check normalisation --
if ~isfield(model, 'norm')
    model.norm = 0;
elseif ~ismember(model.norm, [0, 1])
    warning('ID:invalid_input', 'Normalisation must be specified as 0 or 1.'); return; 
end;

% check filter --
if ~isfield(model, 'filter')
    model.filter = settings.dcm{1}.filter;
elseif ~isfield(model.filter, 'down') || ~isnumeric(model.filter.down)
    warning('ID:invalid_input', 'Filter structure needs a numeric ''down'' field.'); return;
end;

% set and check options ---
try options.indrf;   catch, options(1).indrf = 0;    end;
try options.getrf;   catch, options.getrf = 0;    end;
try options.rf;      catch, options.rf = 0;       end;
try options.nosave;  catch, options.nosave = 0;   end;
try options.overwrite; catch, options.overwrite = 0; end;
if options.indrf && options.rf
    warning('RF can be provided or estimated, not both.'); return;
end;
try options.method; catch, options.method = 'dcm'; end;


% check files --
if exist(model.modelfile) && options.overwrite == 0
    overwrite=menu(sprintf('Model file (%s) already exists. Overwrite?', model.modelfile), 'yes', 'no');
    if overwrite == 2, return, end;
end;

if ischar(model.datafile)
    model.datafile = {model.datafile};
    model.timing   = {model.timing};
end;

if numel(model.datafile) ~= numel(model.timing)
    warning('ID:number_of_elements_dont_match', 'Session numbers of data files and event definitions do not match.'); return;
end;

% check, get and prepare data
% ------------------------------------------------------------------------
for iSn = 1:numel(model.datafile)
    % check & load data
    [sts, infos, data] = scr_load_data(model.datafile{iSn}, model.channel);
    if sts == -1 || isempty(data)
        warning('No SCR data contained in file %s', model.datafile{iSn});
        return;
    end;
    model.filter.sr = data{1}.header.sr;
    options.missing{iSn, 1} = isnan(data{1}.data);
    if any(options.missing{iSn, 1} == true)
        [sts, data{1}.data] = scr_interpolate(data{1}.data);
    end;
    [sts, model.scr{iSn, 1}, model.sr] = scr_prepdata(data{1}.data, model.filter);
    if sts == -1, return; end;
end;

% normalise data --
foo = {};
for sn = 1:numel(model.scr)
    foo{sn, 1} = (model.scr{sn}(:) - mean(model.scr{sn}));
end;
foo = cell2mat(foo);
model.zfactor = std(foo(:));
for sn = 1:numel(model.scr)
    model.scr{sn} = (model.scr{sn}(:) - min(model.scr{sn}))/model.zfactor;
end;
clear foo

% check & get events and group into flexible and fixed responses
% ------------------------------------------------------------------------
for iSn = 1:numel(model.timing)
    % initialise and get timing information -- 
    newevents{1}{iSn} = []; newevents{2}{iSn} = [];
    [sts, events] = scr_get_timing('events', model.timing{iSn});
    if sts ~=1, return; end;
    cEvnt = [1 1];
    % split up into flexible and fixed events --
    for iEvnt = 1:numel(events)
        if size(events{iEvnt}, 2) == 2 % flex
            newevents{1}{iSn}(:, cEvnt(1), 1:2) = events{iEvnt};
            % assign event names
            if iSn == 1 && isfield(options, 'eventnames') && numel(options.eventnames) == numel(events)
                flexevntnames{cEvnt(1)} = options.eventnames{iEvnt};
            elseif iSn == 1
                flexevntnames{cEvnt(1)} = sprintf('Flexible response # %1.0f',cEvnt(1)); 
            end;
            % update counter
            cEvnt = cEvnt + [1 0];
        elseif size(events{iEvnt}, 2) == 1 % fix
            newevents{2}{iSn}(:, cEvnt(2)) = events{iEvnt};
            % assign event names
            if iSn == 1 && isfield(options, 'eventnames') && numel(options.eventnames) == numel(events)
                fixevntnames{cEvnt(2)} = options.eventnames{iEvnt};
            elseif iSn == 1
                fixevntnames{cEvnt(2)} = sprintf('Fixed response # %1.0f',cEvnt(2)); 
            end;
            % update counter
            cEvnt = cEvnt + [0 1];
        end;
    end;
    cEvnt = cEvnt - [1, 1];
    % check number of events across sessions -- 
    if iSn == 1
        nEvnt = cEvnt;
    else
        if any(cEvnt ~= nEvnt)
            warning('Same number of events per trial required across all sessions.'); return;
        end;
    end;
    % find trialstart, trialstop and shortest ITI --
    allevents = [reshape(newevents{1}{iSn}, [size(newevents{1}{iSn}, 1), size(newevents{1}{iSn}, 2) * size(newevents{1}{iSn}, 3)]), newevents{2}{iSn}]; 
    allevents(allevents < 0) = inf;        % exclude "dummy" events with negative onsets
    trlstart{iSn} = min(allevents, [], 2); % first event per trial 
    allevents(isinf(allevents)) = -inf;        % exclude "dummy" events with negative onsets
    trlstop{iSn}  = max(allevents, [], 2); % last event of per trial
    iti{iSn}      = [trlstart{iSn}(2:end); numel(model.scr{iSn, 1})/model.sr] - trlstop{iSn}; 
        % ITI including session end
    miniti(iSn)   = min(iti{iSn});  % minimum ITI
    if miniti(iSn) < 0
        warning('Error in event definition. Either events are outside the file, or trials overlap.'); return;
    end;
end;

model.trlstart =  trlstart;
model.trlstop  =  trlstop;
model.iti      =  iti;
model.events   =  newevents;

% prepare data for CRF estimation and for amplitude priors
% ------------------------------------------------------------------------
% get average event sequence per trial --
if nEvnt(1) > 0
    flexseq = cell2mat(newevents{1}') - repmat(cell2mat(trlstart'), [1, size(newevents{1}{1}, 2), 2]);
    flexseq(flexseq < 0) = NaN;
    flexevents = [];
    % this loop serves to avoid the function nanmean which is part of the
    % stats toolbox
    for k = 1:size(flexseq, 2)
        for m = 1:2
            foo = flexseq(:, k, m);
            flexevents(k, m) = mean(foo(~isnan(foo)));
        end;
    end;
else
    flexevents = [];
end;
if nEvnt(2) > 0
    fixseq  = cell2mat(newevents{2}') - repmat(cell2mat(trlstart'), 1, size(newevents{2}{1}, 2));
    fixseq(fixseq < 0) = NaN;
    fixevents = [];
    for k = 1:size(fixseq, 2)
        foo = fixseq(:, k);
        fixevents(k) = mean(foo(~isnan(foo)));
    end;
else
    fixevents = [];
end;
startevent = min([flexevents(:); fixevents(:)]);
flexevents = flexevents - startevent;
fixevents  = fixevents  - startevent;

options.flexevents = flexevents;
options.fixevents  = fixevents;

clear flexseq fixseq flexevents fixevents startevent

% check ITI --
if (options.indrf || options.getrf) && min(miniti) < 5
    warnings{1} = ('Inter trial interval is too short to estimate individual CRF - at least 5 s needed. Standard CRF will be used instead.');
    fprintf('\n%s\n', warnings{1});
    options.indrf = 0; 
end;

% extract PCA of last fixed response (eSCR) if last event is fixed --
if (options.indrf || options.getrf) && (isempty(options.flexevents) || (max(options.fixevents > max(options.flexevents(:, 2), [], 2))))
    [foo, lastfix] = max(options.fixevents);
    % extract data
    winsize = round(sr * min([miniti 10]));
    D = []; c = 1;
    for iSn = 1:numel(model.scr)
        foo = newevents{2}{iSn}(:, lastfix);
        foo(foo < 0) = [];
        for n = 1:size(foo, 1)
            win = ceil(sr * foo(n) + (1:winsize));
            D(c, :) = model.scr{iSn}(win);
            c = c + 1;
        end;
    end;
    clear c k n
    
    % mean centre
    mD = D - repmat(mean(D, 2), 1, size(D, 2));
    
    % PCA
    [u s]=svd(mD', 0);
    [p,n] = size(mD);
    s = diag(s);
    comp = u .* repmat(s',n,1);
    eSCR = comp(:, 1);
    eSCR = eSCR - eSCR(1);
    foo = min([numel(eSCR), 50]);
    [mx ind] = max(abs(eSCR(1:foo)));
    if eSCR(ind) < 0, eSCR = -eSCR; end;
    eSCR = (eSCR - min(eSCR))/(max(eSCR) - min(eSCR));
    
    % check for peak (zero-crossing of the smoothed derivative) after more 
    % than 3 seconds (use CRF if there is none)
    der = diff(eSCR);
    der = conv(der, ones(10, 1));
    der = der(ceil(3 * sr):end); 
    if all(der > 0) || all(der < 0)
        warnings{1} = ('No peak detected in response to outcomes. Cannot individually adjust CRF. Standard CRF will be used instead.');
        fprintf('\n%s\n', warnings{1});
        options.indrf = 0;
    else
        options.eSCR = eSCR;
    end;
end;

% extract data from all trials
winsize = round(model.sr * min([miniti 10]));
D = []; c = 1;
for iSn = 1:numel(model.scr)
    for n = 1:numel(trlstart{iSn})
        win = ceil(((model.sr * trlstart{iSn}(n)):(model.sr * trlstop{iSn}(n) + winsize)));
        % correct rounding errors
        win(win == 0) = [];
        win(win > numel(model.scr{iSn})) = [];
        D(c, 1:numel(win)) = model.scr{iSn}(win);
        c = c + 1;
    end;
end;
clear c n


% do PCA if required
if (options.indrf || options.getrf) && ~isempty(options.flexevents)
    % mean SOA
    meansoa = mean(cell2mat(trlstop') - cell2mat(trlstart'));
    % mean centre
    mD = D - repmat(mean(D, 2), 1, size(D, 2));
    % PCA
    [u s c]=svd(mD', 0);
    [p,n] = size(mD);
    s = diag(s);
    comp = u .* repmat(s',n,1);
    aSCR = comp(:, 1);
    aSCR = aSCR - aSCR(1);
    foo = min([numel(aSCR), (round(model.sr * meansoa) + 50)]);
    [mx ind] = max(abs(aSCR(1:foo)));
    if aSCR(ind) < 0, aSCR = -aSCR; end;
    aSCR = (aSCR - min(aSCR))/(max(aSCR) - min(aSCR));
    clear u s c p n s comp mx ind mD
    options.aSCR = aSCR;
end;

% get mean response
options.meanSCR = (mean(D))';

% invert DCM
% ------------------------------------------------------------------------
dcm = scr_dcm_inv(model, options);

% assemble stats & names
% ------------------------------------------------------------------------
dcm.stats = [];
cTrl = 1;
for iSn = 1:numel(dcm.sn)
    for iTrl = 1:numel(dcm.sn{iSn}.a)
        dcm.stats(cTrl, :) = [dcm.sn{iSn}.a(iTrl).a(:)', dcm.sn{iSn}.a(iTrl).m(:)', ...
            dcm.sn{iSn}.a(iTrl).s(:)', dcm.sn{iSn}.e(iTrl).a(:)' ];
        cTrl = cTrl + 1;
    end;
end;
dcm.names = {};
for iEvnt = 1:numel(dcm.sn{1}.a(1).a)
    dcm.names{iEvnt, 1} = sprintf('%s: amplitude', flexevntnames{iEvnt});
    dcm.names{iEvnt + numel(dcm.sn{1}.a(1).a), 1} = sprintf('%s: peak latency', flexevntnames{iEvnt});
    dcm.names{iEvnt + 2*numel(dcm.sn{1}.a(1).a), 1} = sprintf('%s: dispersion', flexevntnames{iEvnt});
end;
cMsr = 3 * iEvnt; 
if isempty(cMsr), cMsr = 0; end;
for iEvnt = 1:numel(dcm.sn{1}.e(1).a)
    dcm.names{iEvnt + cMsr, 1} = sprintf('%s: response amplitude', fixevntnames{iEvnt});
end;
    
if isfield(options, 'trlnames') && numel(options.trlnames) == size(dcm.stats, 1)
    dcm.trlnames = options.trlnames;
else
    for iTrl = 1:size(dcm.stats, 1)
        dcm.trlnames{iTrl} = sprintf('Trial #%d', iTrl);
    end;
end;

% assemble input and save
% ------------------------------------------------------------------------
dcm.dcmname = model.modelfile; % this field will be removed in the future
dcm.modelfile = model.modelfile;
dcm.input = model;
dcm.options = options;
dcm.warnings = warnings;
dcm.modeltype = 'dcm';
dcm.modality = settings.modalities.dcm;
dcm.revision = rev;

if ~options.nosave
    save(model.modelfile, 'dcm');
end;

return;
