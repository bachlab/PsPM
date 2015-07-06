function scr_glm_uni(datafile, regfile, modelfile, timeunits, basefunctions, normalize, chan, options)

% test script for GLM with unidirectional data filtering DRB 22.8.2011

% scr_glm models a within subject general linear model of predicted
% SCRs and calculates beta estimates for these responses using the pinv
% function
%
% FORMAT:
% SCR_GLM (DATAFILE, REGFILE, MODELFILE, TIMEUNITS, BASEFUNCTIONS, NORMALIZE, CHAN, OPTIONS)
%
% datafile, regfile: either one datafile and one regfile, or a cell array of
% datefiles to be concatenated (e.g. several sessions of an fMRI
% experiment) and a cell array of regfiles (onsets with respect to session
% start), or one regfile for the whole model (the duration of each
% datafile will be needed to construct the regfile, and can be assessed via
% the variable infos.duration)
%
% timeunits: 'seconds', 'triggers', 'samples'
%
% basefunctions: either a cell array of function names, or one of the
% predefined functions, or a struct with field .name for a function name or
% handle, and .arg for its arguments
%
% predefined basis functions:
% 'scrf' provides a canonical skin conductance response function
% 'scrf1' adds the time derivative
% 'scrf2' adds time dispersion derivative
% 'FIR' provides 30 post-stimulus timebins of 1 s duration
%
% normalize (default = 1) determines whether the data are normalized. This
% has been proposed in the SCR literature when using "classic" baseline to
% peak amplitude, and can help to reduce variance due to peripheral factors
% (i.e. skin properties)
%
% chan: by default, SCRalyze looks for the only waveform channel, or for
% the first scr channel. Provide an argument to pick a specific waveform
% channel (and a second one for events, if timeunits = 'triggers')
%
% options.overwrite = 1: overwrite existing files
%
% The structure of the regfile is equivalent to SPM8
% (www.fil.ion.ucl.ac.uk/spm), so that SPM files can be used.
% The file contains the following variables:
% - names: a cell array of string for the names of the experimental
%   conditions
% - onsets: a cell array of number vectors for the onsets of events for
%   each experimental condition, expressed in seconds, trigger numbers, or
%   samples, as specified in timeunits
% optional variables:
% - durations: a cell array of vectors for the duration of each event. This
%   will be set to zero by default, but if sustained responses need to be
%   modelled, this variable can be used. In this case, you need to use
%   'seconds' or 'samples' as time units
% - pmod: this is used to specify regressors that specify how responses in
%   an experimental condition depend on a parameter to model the effect
%   e.g. of habituation, reaction times, or stimulus ratings.
%   pmod is a struct array corresponding to names and onsets and containing
%   the fields
%   - name: cell array of names for each parametric modulator for this
%       condition
%   - param: cell array of vectors for each parameter for this condition,
%       containing as many numbers as there are onsets
%   - poly: the SPM field poly is currently supported and will be ignored
% - parametric_confound: in order to specify a parametric confound across
%   all conditions without having to include the main effect across all
%   conditions, an additional experimental condition can be created,
%   containing all onsets. The variable parametric_confound should, for
%   each condition contain a 0 or 1. If it is one, the main effect of this
%   condition will be removed.
% e.g. produce a simple file by typing
%  names = {'condition a', 'condition b'};
%  onsets = {[1 2 3], [4 5 6]};
%  save('testfile', 'names', 'onsets');
%
%
% RETURNS a modelfile containing a struct array glm with the most important
% field glm.beta
%
% REFERENCE
%
% GLM 
% Bach DR, Flandin G, Friston KJ, Dolan RJ (2009). Time-series analysis for rapid
% event-related skin conductance responses. Journal of Neuroscience
% Methods, 184, 224-234.
%
% Canonical response function, and GLM assumptions 
% Bach DR, Flandin G, Friston KJ, Dolan RJ (2010). Modelling event-related 
% skin conductance responses. International Journal of Psychophysiology,
% 75, 349-356.
% 
%__________________________________________________________________________
% SCRalyze
% (C) 2008 - 2010 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% v111 drb 9.11.2010 fixed a bug with 'samples' timeunits
% v110 drb 6.2.2010 save actual basis functions and number of intercept 
%                   regressors in glm structure
% v109 drb 2.2.2010 changed handling of empty channel specification
% v108 drb 18.12.2009 allow for durations > 0 & fixed a bug with event import
% v107 drb 8.12.2009 deleted disable - now moved to scr_prepdata
% v106 drb 18.9.2009 introduced channel options
% v105 drb 25.8.2009 introduced -1 option for onsets
% v104 drb 12.8.2009 changed handling of basis functions
% v103 drb 14.7.2009 fixed bug with pmod spec
% v102 drb 9.7.2009 fixed bug with one regfile/multiple sessionfile spec
% v101 drb 24.5.2009 fixed onset spec for multiple onset files

% note the terminology here is to call the data 'scr' even if it's other
% waveform signals

global settings;
if isempty(settings), scr_init; end;


% check input arguments
if nargin<1
    errmsg=sprintf('No data file specified'); warning(errmsg); return;
elseif nargin<2
    errmsg=sprintf('No condition file specified'); warning(errmsg); return;
elseif nargin<3
    errmsg=sprintf('No modelfile specified'); warning(errmsg); return;
elseif nargin<4
    errmsg=sprintf('No timeunits specified'); warning(errmsg); return;
elseif ~ismember(timeunits, {'seconds', 'triggers', 'samples'})
    errmsg=sprintf('Timeunits (%s) not recognised; only ''seconds'', ''triggers'' and ''samples'' are supported', timeunits); warning(errmsg); return;
elseif nargin<5
    errmsg=sprintf('No basis function specified'); warning(errmsg); return;
elseif nargin<6
    normalize=1;
elseif nargin<7 || isempty(chan)
    chan = 0;
end;

% set options
try options.overwrite; catch, options.overwrite = 0; end;

% check modelfile
if ~options.overwrite && exist(modelfile)==2 
    overwrite=menu(sprintf('Model file (%s) already exists. Overwrite?', modelfile), 'yes', 'no');
    close gcf;
    if overwrite==2, return; end;
end;

% check datafile(s)
if ~iscell(datafile)
    datafile={datafile};
end;
for d=1:numel(datafile)
    sts = scr_load_data(datafile{d}, 'none');
    if sts == -1
        return;
    end;
end;

% check regressor files
if ~iscell(regfile)
    regfile={regfile};
end;

[sts multi] = check_regfile(regfile, timeunits);
if sts < 0, return; end;

%-------------------------------------------------------------------------
% user output
%-------------------------------------------------------------------------

fprintf('Computing GLM: %s ...', modelfile);

%-------------------------------------------------------------------------
% prepare data & concatenate regressors
%-------------------------------------------------------------------------

Y=[];
for d=1:numel(datafile)
    
    clear scr infos filt down scr_hp scr_lp scr_down
    
    if chan == 0
        % load waveform channels
        [sts, infos, data] = scr_load_data(datafile{d}, 'wave');
        if sts == -1; return; end;
        % if there is none, or more than one waveform channel
        if isempty(data) || numel(data) > 1
            % load scr channel(s)
            [sts, infos, data] = scr_load_data(datafile{d}, 'scr');
            if sts == -1 || isempty(data); return; end;
        end;
        % use data from single waveform, or first scr channel
        scr = data{1};
        % if required, load events
        if any(strcmp(timeunits, {'trigger', 'triggers'}))
            [sts, infos, data] = scr_load_data(datafile{d}, 'events');
            if sts == -1 || isempty(data); 
                warning('No event data'); return;
            else
                events = data{1}.data;
            end;
        else
            events = [];
        end;
    else
        [sts, infos, data] = scr_load_data(datafile{d}, chan);
        if sts == -1 || isempty(data), warning('Could not load file %s', datafile{d}); return; end;
        if strcmp(data{1}.header.units, 'events'); warning('No waveform data'); return; end;
        scr = data{1};
         if any(strcmp(timeunits, {'trigger', 'triggers'}))
            [sts, infos, data] = scr_load_data(datafile{d}, 'events');
            if sts == -1 || isempty(data); 
                warning('No event data'); return;
            else
                events = data{1}.data;
            end;
        else
            events = [];
        end;
    end;

    % prepare (filter & downsample) data
    [scr_down sr] = scr_prepdata(scr, 'uni');
    
    % concatenate if necessary
    Y=[Y; scr_down];
    
    % get duration of single sessions
    snduration(d)=numel(scr_down);
    
    % concatenate regressors & convert to samples
    if d <= numel(multi)
        for n = 1:numel(multi(1).n)
            % convert onsets to samples
            switch timeunits
                case 'samples'
                    dummy = round(multi(d).o{n} * sr/scr.header.sr);
                    foo   = round(multi(d).d{n} * sr/scr.header.sr);
                case 'seconds'
                    dummy = round(multi(d).o{n} * sr);
                    foo   = round(multi(d).d{n} * sr);
                case 'triggers'
                    try
                        dummy = round(events(multi(d).o{n}) * sr); % triggers are timestamps in seconds
                    catch
                        warning('\nSome events in condition %01.0f were not found in the data file %s', n, datafile{d}); return;
                    end;
                    if any(multi(d).d{n} ~= 0)
                        warning('Triggers is a convenience timeunits option that does not allow to specify events of non-zero duration.'); return;
                    else
                        foo = multi(d).d{n};
                    end;
            end;
            % get the first regressor file
            if d == 1
                names{n} = multi(1).n{n};
                onsets{n} = dummy(:);
                durations{n} = foo(:);
                parametric_confound = multi(1).p(:);
                if isfield(multi, 'pmod') && (numel(multi.pmod) >= n)
                    pmod(n).name = multi(1).pmod(n).name;
                    for p = 1:numel(multi(1).pmod(n).param)
                        pmod(n).param{p} = multi(1).pmod(n).param{p}(:);
                    end;
                end;
            else
                dummy = dummy + sum(snduration(1:(d - 1)));
                onsets{n} = [onsets{n}; dummy(:)];
                durations{n} = [durations{n}; multi(d).d{n}(:)];
                if exist('pmod') && (numel(pmod) >= n)
                    for p = 1:numel(pmod(n).param)
                        pmod(n).param{p} = [pmod(n).param{p}; multi(d).pmod(n).param{p}(:)];
                    end;
                end;
            end;
        end;
    end;
end;

% z-transform if desired
if normalize
    Y=(Y-mean(Y))/std(Y);
end;

Y = Y(:);

%-------------------------------------------------------------------------
% initialise design matrix
%-------------------------------------------------------------------------
clear glm tmp
glm.sourcefile=datafile;
glm.Y=Y; clear Y;
glm.sr.init=scr.header.sr;
glm.sr.fin=sr;
glm.duration=numel(glm.Y)/glm.sr.fin;
glm.durationinfo='duration in seconds';
tmp.duration=numel(glm.Y);
glm.norm=normalize;
tmp.pmodno=zeros(numel(names), 1);
if exist('pmod', 'var')
    for n=1:numel(pmod)
        if ~isempty(pmod(n).param)
            for p=1:numel(pmod(n).param)
                % mean center and scale pmods
                try
                    pmod(n).param{p}=pmod(n).param{p}-mean(pmod(n).param{p})/std(pmod(n).param{p});
                catch
                    pmod(n).param{p}=pmod(n).param{p}-mean(pmod(n).param{p});
                end;
            end;
            % register number of pmods
            tmp.pmodno(n)=p;
        end;
    end;
end;


%-------------------------------------------------------------------------
% create temporary onset functions
%-------------------------------------------------------------------------
% cycle through conditions
for cond=1:numel(names)
    % first process event onset, then pmod
    tmp.onsets = onsets{cond};
    tmp.durations = durations{cond};
    % if file starts with first event, set that onset to 1 instead of 0
    if any(tmp.onsets==0)
        tmp.onsets(tmp.onsets==0)=1;
    end;
    col=1;
    tmp.colnum=1+tmp.pmodno(cond);
    tmp.X{cond}=zeros(tmp.duration, tmp.colnum);
    for k = 1:numel(tmp.onsets)
        tmp.X{cond}(tmp.onsets(k):(tmp.onsets(k) + tmp.durations(k)), col)=1;
    end;
    tmp.name{cond, col}=names{cond};
    col=col+1;
    if exist('pmod')
        if cond<=numel(pmod)
            if ~isempty(pmod(n).param)
                for p=1:numel(pmod(cond).param)
                    for k = 1:numel(tmp.onsets)
                        tmp.X{cond}(tmp.onsets(k):(tmp.onsets(k) + tmp.durations(k)), col)=pmod(cond).param{p}(k);
                    end;
                    tmp.name{cond, col}=[names{cond}, ' x ', pmod(cond).name{p}];
                    col=col+1;
                end;
            end;
        end;
        % orthogonolize pmods before convolution
        tmp.X{cond}=spm_orth(tmp.X{cond});
    end;
end;

%-------------------------------------------------------------------------
% check & get basis functions
%-------------------------------------------------------------------------

clear bf
bfsts = 1;

if ischar(basefunctions),
    switch lower(basefunctions)
        case 'fir', bf.f=str2func('scr_bf_FIR'); bf.arg = [1/glm.sr.fin, 30];
        case 'scrf', bf.f=str2func('scr_bf_infbs');  bf.arg = [1/glm.sr.fin, 0];
        case 'scrf1', bf.f=str2func('scr_bf_infbs'); bf.arg = [1/glm.sr.fin, 1];
        case 'scrf2', bf.f=str2func('scr_bf_infbs'); bf.arg = [1/glm.sr.fin, 2];
        otherwise, bf.f = str2func(basefunctions); bf.arg = 1/glm.sr.fin;
    end;
elseif iscell(basefunctions)
    for k = 1:numel(basefunctions)
        bf(k).f = str2func(basefunctions{k}); bf(k).arg = [1/glm.sr.fin, 0];
    end;
elseif isstruct(basefunctions)
    try
        if ischar(basefunctions.name)
            bf.f = str2func(basefunctions.name);
        elseif isa(basefunctions.name, 'function_handle')
            bf.f = basefunctions.name;
        else
            bfsts = -1;
        end;
        if isnumeric(basefunctions.arg)
            bf.arg = [1/glm.sr.fin, basefunctions.arg(:)'];
        else
            bfsts = -1;
        end;
    catch
        bfsts = -1;
    end;
    if bfsts == -1
        errmsg = ('Invalid basis function');
        warning(errmsg); return;
    end;
end;

tmp.bf=[];
try
    for k = 1:numel(bf)
        tmp.bf = [tmp.bf, feval(bf(k).f, bf(k).arg)];
    end;
catch
    errmsg=sprintf('Specified basis function %s doesn''t exist', bf(k).name(2:end)); warning(errmsg); return;
end;
tmp.baseno=size(tmp.bf, 2);
glm.bf=bf;
glm.bf.X = tmp.bf;
glm.bf.baseno = tmp.baseno;
clear k bf

%-------------------------------------------------------------------------
% create design matrix
%-------------------------------------------------------------------------
% convolve with basis functions

for cond=1:numel(names)
    tmp.Xc{cond}=[];
    for col=1:size(tmp.X{cond}, 2)
        for bf=1:tmp.baseno
            tmp.col=conv(tmp.X{cond}(:,col), tmp.bf(:,bf));
            tmp.Xc{cond}=[tmp.Xc{cond}, tmp.col(1:numel(glm.Y))];
            tmp.namec{cond}{(col-1)*tmp.baseno+bf, 1}=[tmp.name{cond, col}, ', bf ', num2str(bf)];
        end;
    end;
    
    % mean center
    for col=1:size(tmp.Xc{cond},2)
        tmp.Xc{cond}(:,col)=tmp.Xc{cond}(:,col)-mean(tmp.Xc{cond}(:,col));
    end;
    
    % orthogonalize after convolution
    tmp.Xc{cond}=spm_orth(tmp.Xc{cond});
    
    % delete main regressors for parametric confounds
    if parametric_confound(cond)
        tmp.Xc{cond}(:,1:tmp.baseno)=[];
        tmp.namec{cond}(1:tmp.baseno)=[];
    end;
end;

glm.X=cell2mat(tmp.Xc);
r=1;
for cond=1:numel(names)
    n=numel(tmp.namec{cond});
    glm.name(r:(r+n-1),1)=tmp.namec{cond};
    r=r+n;
end;

% add constant(s)
r=1;
for d=1:numel(datafile);
    glm.X(r:(r+snduration(d)-1),end+1)=1;
    glm.name{end+1, 1}=['Constant ', num2str(d)];
    r=r+snduration(d);
end;
glm.interceptno = d;

% filter design matrix (uni)
for k = 1:(size(glm.X, 2) - d)
    glm.X(:, k) = scr_prepdata(glm.X(:, k), glm.sr.fin, settings.lp, settings.hp, 'none', 'uni');
end;

% cleanup
clear tmp;

%-------------------------------------------------------------------------
% calculate beta & save
%-------------------------------------------------------------------------
% this is where the beef is
glm.beta=pinv(glm.X)*glm.Y;
glm.Yhat=glm.X*glm.beta;
glm.e=glm.Y-glm.Yhat;
glm.modeltype = 'glm';
glm.modality = settings.modalities.glm;

save(modelfile, 'glm');


%-------------------------------------------------------------------------
% user output
%-------------------------------------------------------------------------

fprintf(' done. \n');

% cleanup
clear glm scr
return

%-------------------------------------------------------------------------
% internal functions: check regressor file(s)
%-------------------------------------------------------------------------

function [sts multi] = check_regfile(fns, timeunits)

if ~iscell(fns)
    fns = {fns};
end;

sts = 1;
multi = [];

for f = 1:numel(fns)
    fn = fns{f};
    merrmsg=sprintf('Regressor file (%s) is invalid ... ', fn);
    if exist(fn)~=2
        errmsg=sprintf('Regressor file (%s) doesn''t exist', fn);
        warning(errmsg);
        sts = -1;
        return;
    end;
    
    load(fn);
    if (isempty(find(ismember(who, 'names'), 1)))||(isempty(find(ismember(who, 'onsets'), 1))),
        warning(merrmsg); sts = -1; return;
    end;
    if isempty(find(ismember(who, 'durations'), 1)),
        durations=num2cell(zeros(numel(names), 1));
    end;
    if isempty(find(ismember(who, 'parametric_confound'), 1))
        parametric_confound=zeros(numel(names), 1);
    end;
    if ~iscell(names)||~iscell(onsets)
        errmsg = 'Names and onsets need to be cell arrays'; warning([merrmsg, errmsg]); sts=-1; return;
    end;
    if numel(names)~=numel(onsets),  errmsg=sprintf('Number of event names (%d) does not match the number of onsets (%d).',...
            numel(names),numel(onsets)); warning([merrmsg, errmsg]); sts = -1; return;
    elseif numel(names)~=numel(durations),  errmsg=sprintf('Number of event names (%d) does not match the number of durations (%d).',...
            numel(onsets),numel(durations)); warning([merrmsg, errmsg]); sts = -1; return;
    elseif numel(names)~=numel(parametric_confound),  errmsg=sprintf('Number of event names (%d) does not match the number of parametric confound specifications (%d).',...
            numel(onsets),numel(parametric_confound)); warning([merrmsg, errmsg]); sts = -1; return;
    else
        for n=1:numel(names)
            if numel(durations{n})==1, durations{n}=repmat(durations{n}, numel(onsets{n}), 1);
            elseif (numel(onsets{n}) ~= numel(durations{n}))
                errmsg=sprintf('"%s": Number of event onsets (%d) does not match the number of durations (%d).',...
                    names{n}, numel(onsets{n}),numel(durations{n})); warning([merrmsg, errmsg]); sts = - 1; return;
            end;
            switch timeunits
                case 'seconds'
                    if any(onsets{n})<0
                        errmsg=sprintf('Onset vector %d contains onsets smaller than 0 s', n); warning([merrmsg, errmsg]); sts = -1; return;
                    end;
                case {'samples', 'triggers'}
                    if any(fix(onsets{n})~=onsets{n})
                        errmsg=sprintf('Onset vector %d contains non-integers', n); warning([merrmsg, errmsg]); sts = -1; return;
                    end;
            end;
            if any(onsets{n} < 0)
                if numel(onsets{n}) == 1, onsets{n} = [];
                else
                    errmsg=sprintf('Negative event onsets in regressor %s', names{n}); warning([merrmsg, errmsg]); sts = -1; return;
                end;
            end;
        end;
    end;
    if ~isempty(find(ismember(who, 'pmod'), 1))
        if numel(pmod)>numel(names),  errmsg=sprintf('Number of parametric modulators (%d) does not match the number of onsets (%d).',...
                numel(pmod),numel(onsets)); warning([merrmsg, errmsg]); sts = -1; return;
        else
            for n=1:numel(pmod),
                for o=1:numel(pmod(n).param)
                    if numel(onsets{n}) ~= numel(pmod(n).param{o}),
                        errmsg= sprintf('"%s" & "%s": Number of event onsets (%d) does not equal the number of parameters (%d).',...
                            names{n}, pmod(n).name, numel(onsets{n}),numel(pmod(n).param)); warning([merrmsg, errmsg]); sts = -1; return;
                    end;
                end;
            end;
        end;
    end;
    
    if f > 1
        for n = 1:numel(names)
            if ~strcmpi(multi(1).n{n}, names{n})
                errmsg('Event names in sessions 1 and %.0f don''t match (%s and %s)', f, multi(1).n{n},names{n});
                warning(errmsg); sts = -1; return;
            end;
        end
    end;
    multi(f).n = names;
    multi(f).o = onsets;
    multi(f).d = durations;
    multi(f).p = parametric_confound;
    if exist('pmod')
        multi(f).pmod = pmod;
    end;
    clear names onsets durations parametric_confound pmod
end;