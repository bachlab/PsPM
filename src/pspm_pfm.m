function output = pspm_pfm(model, options)
% PFM stands for Pupil Fitting Model and allows to fit models to the puipil
% data. The function starts by extracting and averaging signal segments of 
% length `model.window` from each data file individually, then averages 
% these mean segments and finally fits an LTI model.
% The fitting process is a residual least square minimisation where the
% predicted value is calculated as following:
%          Y_predicted = input_function (*) basis_function
% with (*) represents a convolution. Only parameters of the input
% function are optimised.
%
% MODEL is made of:
% - REQUIRED FIELDS:
%    model.modelfile:    a file name for the model output
%    model.datafile:     a file name (single session) OR
%                        a cell array of file names
%    model.timing:       a multiple condition file name (single session) OR
%                        a cell array of multiple condition file names OR
%                        a struct (single session) with fields .names, .onsets,
%                             and (optional) .durations OR
%                        a cell array of struct OR
%                        a struct with fields 'markerinfos', 'markervalues',
%                            'names' OR
%                        a cell array of struct
%    model.timeunits:    a char array equal to 'seconds', 'samples' or 'markers'
%    model.window:       a scalar in model.timeunits as unit that specifies  
%                        over which time window (starting with the events 
%                        specified in model.timing) the model should 
%                        be evaluated. 
%                        For model.timeunits == 'markers', the unit of the
%                        window should be specified in 'seconds'.
%
% - OPTIONAL FIELDS:
%    model.modality:     a char array equal to 'constriction' or 'dilation'
%                        corresponding to the fitted model.
%                        DEFAULT: 'dilation'
%    model.bf:           basis function/basis set with required subfields: 
%                           .fhandle : function handle or string
%                           .args    : arguments; the first two arguments
%                                      (time resolution and duration)
%                                      will be added by pspm_pupil_model.
%                        DEFAULT: specified by the modality
%    model.if:           input function (function which will be fitted) 
%                        with required subfields: 
%                           .fhandle : function handle or string
%                           .arg     : initial arguments, numeric array
%                           .lb      : lower bounds, numeric array of the
%                                      same size as .arg
%                           .ub      : upper bounds, numeric array of the
%                                      same size as .arg
%                        If an argument should not be fitted, set the 
%                        corresponding value of .lb and .ub to the same
%                        value as .arg. For unbounded parameters set -Inf
%                        or/and Inf respectively.
%                        DEFAULT: specified by the modality
%    model.channel:      allows to specify channel number or channel type.
%                        If there is only one element specified, this element
%                        will be applied to each datafile.
%                        model.channel can also be a cell array of the size of
%                        model.datafile in which case each element of the array
%                        correspond to the channel to use for each data file.
%                        DEFAULT: last channel of 'pupil' data type
%    model.zscore:       allows to specify whether data should be zscored or not
%                        DEFAULT: 1
%    model.filter:       filter settings; modality specific default
%                        filter is applied after extracting the segments, in
%                        case of differing sr the segments will be downsampled
%                        DEFAULT: no filter is applied
%    model.baseline:     allows to specify a baseline in 'seconds' which is
%                        applied to the data before fitting the model. It
%                        has to be positive and smaller than model.window.
%                        If no baseline specified, data will be baselined
%                        wrt. the first datapoint.
%                        DEFAULT: 0
%    model.marker_chan:  marker channel number OR
%                        a cell array of marker channel number of
%                        the size of the model.datafile
%                        DEFAULT: 'marker' (i.e. last marker channel)
%    model.std_exp_cond: allows to specify the standard experimental condition
%                        as a string or an index in timing.names.
%                        if specified this experimental condition will be
%                        substracted from all the other conditions.
%                        DEFAULT: 'none'
%    model.norm:         allows ot specify if the model have to be normalized
%                        before fitting the model, i.e. setting the first
%                        peak at 1.
%                        DEFAULT: 0 (not normalize) 
% 
% OPTIONS can contain: (optional argument)
%     options.overwrite:       overwrite existing model output; 
%                              DEFAULT: 0                           
%
% TIMING - multiple condition file(s) or struct variable(s):
%    The structure is equivalent to SPM2/5/8/12 (www.fil.ion.ucl.ac.uk/spm),
%    such that SPM files can be used.
%    The file contains the following variables:
%    - names: a cell array of string for the names of the experimental
%      conditions
%    - onsets: a cell array of number vectors for the onsets of events for
%      each experimental condition, expressed in seconds, marker numbers, or
%      samples, as specified in timeunits
%    - durations (optional, default 0): a cell array of vectors for the
%      duration of each event. You need to use 'seconds' or 'samples' as time
%      units
%    e.g. produce a simple multiple condition file by typing
%      names = {'condition a', 'condition b'};
%      onsets = {[1 2 3], [4 5 6]};
%      save('testfilcircle_degreee', 'names', 'onsets');
%
% RETURNS a structure 'pfm' which is also written to file
%
% REFERENCE
% J Vis. 2016;16(3):28. doi: 10.1167/16.3.28.
% A solid frame for the window on cognition: Modeling event-related pupil responses.
% Korn CW, Bach DR.
%________________________________________________________________________
% PsPM 4.2
% (C) 2020 Ivan Rojkov (University of Zurich)

% $Id$   
% $Rev$

%%%%%%%% Initialise %%%%%%%%
global settings;
if isempty(settings), pspm_init; end


%%%%%%%% Checking inputs %%%%%%%%

if nargin<1
    errmsg='Nothing to do.'; warning('ID:invalid_input', errmsg); return;
elseif nargin<2
    options = struct();
end

%%% Checking required fields %%%
if ~isfield(model, 'datafile')
    warning('ID:invalid_input', 'No input data file specified.'); return;
elseif ~ischar(model.datafile) && ~iscell(model.datafile)
    warning('ID:invalid_input', 'Input data must be a cell or string.'); return;
elseif ~isfield(model, 'modelfile')
    warning('ID:invalid_input', 'No output model file specified.'); return;
elseif ~ischar(model.modelfile)
    warning('ID:invalid_input', 'Output model must be a string.'); return;
elseif ~isfield(model, 'timeunits')
    warning('ID:invalid_input', 'No timeunits specified.'); return;
elseif ~isfield(model, 'timing') || isempty(model.timing) || iscell(model.timing) ...
        && (sum(cellfun(@(f) isempty(f), model.timing)) == numel(model.timing))
    % Timing doesnt exist, is emtpy or is a cell array with empty entries
    warning('ID:invalid_input', 'Event onsets file is not specified.'); return;
elseif ~ischar(model.timing) && ~iscell(model.timing) && ~isstruct(model.timing)
    warning('ID:invalid_input', 'Event onsets must be a string, cell, or struct.'); return;
elseif ~ischar(model.timeunits) || ~ismember(model.timeunits, {'seconds', 'markers', 'samples'})
    warning('ID:invalid_input', ['Timeunits (%s) not recognised; only ''seconds'','...
                                ' ''markers'' and ''samples'' are supported'], model.timeunits); return;
elseif ~isfield(model,'window')
   warning('ID:invalid_input','No window specified.'); return
elseif ~isnumeric(model.window) 
    warning('ID:invalid_input', 'Time window must be numeric.'); return
end

if ischar(model.datafile)
    model.datafile={model.datafile};
end
model.datafile = model.datafile(:);

if ischar(model.timing) || isstruct(model.timing)
    model.timing = {model.timing};
end

if ~isempty(model.timing) && (numel(model.datafile) ~= numel(model.timing))
    warning('ID:number_of_elements_dont_match', ...
        'Session numbers of data files and event definitions do not match.'); return;
end

%%% Checking optionnal fields %%%

% Checking model specs
if ~isfield(model, 'modality')
    % load default model specification
    model.modality = settings.pfm(1).modality;
elseif ~ismember(model.modality, {settings.pfm.modality})
    warning('ID:invalid_input', 'Unknown model specification %s.', model.modality); return;
end
modno = strcmpi(model.modality, {settings.pfm.modality});

% Checking the basis function
if ~isfield(model, 'bf')
    model.bf = settings.pfm(modno).cbf;
else
    if ~isfield(model.bf, 'fhandle')
        warning('No basis function given.'); return;
    elseif ischar(model.bf.fhandle)
        [~, basefn,~] = fileparts(model.bf.fhandle);
        model.bf.fhandle = str2func(basefn);
        clear basefn
    elseif ~isa(model.bf.fhandle, 'function_handle')
        warning('Basis function must be a string or function handle.'); return;
    end
    if ~isfield(model.bf, 'args')
        model.bf.args = [];
    elseif ~isnumeric(model.bf.args)
        warning('Basis function arguments must be numeric.');
    end
end
model.bf.args = model.bf.args(:).';

% Checking the input function
if ~isfield(model, 'if')
    model.if = settings.pfm(modno).cif;
else    
    if ~isfield(model.if, 'fhandle')
        warning('No input function given.'); return;
    elseif ischar(model.if.fhandle)
        [~, basefn,~] = fileparts(model.if.fhandle);
        model.if.fhandle = str2func(basefn);
        clear basefn
    elseif ~isa(model.bf.fhandle, 'function_handle')
        warning('Basis function must be a string or function handle.'); return;
    end
    if ~isfield(model.if,'args') || isempty(model.if.args) || ~isnumeric(model.if.args)
        warning('ID:invalid_input',['Arguments for the input',...
                ' function must be a non-empty numeric array.']); return;
    end
    if ~isfield(model.if,'lb') || ~isnumeric(model.if.lb) ...
            || any(size(model.if.lb)~=size(model.if.args))
        warning('ID:invalid_input',['The lower bounds for the input function',...
                ' must be a numeric array of the same size than ''model.if.arg''.']); return;
    end
    if ~isfield(model.if,'ub') || ~isnumeric(model.if.ub) ...
            || any(size(model.if.ub)~=size(model.if.args))
        warning('ID:invalid_input',['The upper bounds for the input function',...
                ' must be a numeric array of the same size than ''model.if.arg''.']); return;
    end
    if any(model.if.lb > model.if.ub) || any(model.if.lb > model.if.args) ...
            || any(model.if.args > model.if.ub)
        warning('ID:invalid_input',['Input function''s parameters are inconsistent.',...
                ' They must respect: model.if.lb <= model.if.arg <= model.if.ub.']); return;
    end
end
model.if.args = model.if.args(:).';
model.if.lb = model.if.lb(:).';
model.if.ub = model.if.ub(:).';

% Checking data channel
chan_war_msg = ['Channel number must be a unique number,', ...
                'a cell array of unique number', ...
                'or correspond to a valid channel type.'];
if ~isfield(model, 'channel')
    model.channel = 'pupil';
elseif ~iscell(model.channel) && ~isnumeric(model.channel) && ...
       ~ismember(model.channel, {settings.chantypes.type})
    warning('ID:invalid_input', chan_war_msg); return;
elseif ~iscell(model.channel) && numel(model.channel) > 1 
    warning('ID:invalid_input', chan_war_msg); return;
elseif iscell(model.channel) && numel(model.channel)~=numel(model.datafile)
    warning('ID:invalid_input', ...
            'Channel array must be of the same size as datafile array.'); return;
elseif iscell(model.channel)
    model.channel = model.channel(:);
    tmp_fun = @(x) ~isnumeric(x) && numel(x)~=1 ...
                   && ~ismember(x, {settings.chantypes.type});
    tmp = cellfun(tmp_fun,model.channel);
    if any(tmp)
       warning('ID:invalid_input', chan_war_msg); return;
    end
    clear tmp_fun
end
clear chan_war_msg

% Checking zscore
if ~isfield(model, 'zscore')
    model.zscore = 1;
elseif ~ismember(model.zscore, [0, 1])
    warning('ID:invalid_input', '''model.zscore'' has to be 0 or 1.'); return;
end

% Checking filter
if ~isfield(model, 'filter')
    model.filter = settings.pfm(modno).filter;
    model.filter.applied_filt = false;      % parameter which determine if we apply or not the filter
else
    if ~isfield(model.filter, 'down') || ~isnumeric(model.filter.down)
        warning('ID:invalid_input', ['Filter struct needs field ', ...
            '''down'' to be numeric or ''none''.']); return;        
    end
    
    model.filter.applied_filt = true;       % parameter which determine if we apply or not the filter
end

% Checking baseline
if ~isfield(model,'baseline')
    model.baseline = 0;
elseif ~isnumeric(model.baseline)
    warning('ID:invalid_input','''model.baseline'' has to be a numeric.'); return;
elseif model.baseline > model.window || model.baseline < 0
    warning('ID:invalid_input',['''model.baseline'' has to be positive ',...
                                'and smaller than ''model.window''.']); return;
end

% Checking marker channels 
if strcmpi(model.timeunits,'markers')
    if ~isfield(model,'marker_chan')
        model.marker_chan = 'marker';
    elseif numel(model.marker_chan)==1 && ~isnumeric(model.marker_chan)
        warning('ID:invalid_input','Marker channels have to be numeric.'); return;
    elseif numel(model.marker_chan)>1 && ...
           ( ~iscell(model.marker_chan) || ... 
             numel(model.marker_chan)~=numel(model.marker_chan) )
        warning('ID:invalid_input',['Marker channels have to be a cell array', ...
                                    ' of the same size than ''model.modelfile''.'])
    end
end

% Checking standard experimental condition
std_cond_war_msg = ['The standard experimetal condition must be',...
                ' either a valid experimental condition or an',...
                ' index corresponding to it.'];
if ~isfield(model,'std_exp_cond')
    model.std_exp_cond = 'none';
elseif ~ischar(model.std_exp_cond) && ~isnumeric(model.std_exp_cond)
    warning('ID:invalid_input',std_cond_war_msg); return;
elseif ischar(model.std_exp_cond)
    tmp_ind = cellfun(@(x) strcmpi(model.std_exp_cond,x),model.timing{1}.names);
    if ~any(tmp_ind)
        warning('ID:invalid_input',std_cond_war_msg); return;
    end
    std_exp_cond.name = model.std_exp_cond;
    std_exp_cond.ind = find(tmp_ind);
elseif isnumeric(model.std_exp_cond)
    if model.std_exp_cond < 1 || ...
       model.std_exp_cond > numel(model.timing{1}.names)
        warning('ID:invalid_input',std_cond_war_msg); return;
    end
    std_exp_cond.name = model.timing{1}.names(model.std_exp_cond);
    std_exp_cond.ind = model.std_exp_cond;
end
clear std_cond_war_msg tmp_ind

%Checking norm
if ~isfield(model, 'norm')
    model.norm = 0;
elseif ~ismember(model.norm, [0, 1])
    warning('ID:invalid_input', '''model.zscore'' has to be 0 or 1.'); return;
end

if ~pspm_overwrite(model.modelfile, options); return; end

%%
%%%%%%%% Loading files %%%%%%%%

fprintf('Computing Pupil Model: %s \n', model.modelfile);

n_exp_cond = numel(model.timing{1}.names);      % number of experimental conditions
n_file = numel(model.datafile);                 % number of files

% Loading data and sr
fprintf('Getting data .');
for iFile = 1:n_file
    if iscell(model.channel)
        [sts, ~, data] = pspm_load_data(model.datafile{iFile}, model.channel{iFile});
    else 
        [sts, ~, data] = pspm_load_data(model.datafile{iFile}, model.channel);
    end
    if sts < 1, warning('ID:load_data_fail', 'Problem encountered while loading data.'); return; end
    
    % Filling up the data and the sampling rates
    y{iFile} = data{end}.data(:);
    sr(iFile) = data{end}.header.sr;
    fprintf('.');
    
    % If the timeunits is markers
    if strcmpi(model.timeunits, 'markers')
        if iscell(model.marker_chan)
            [sts, ~, data] = pspm_load_data(model.datafile{iFile}, model.marker_chan{iFile});
        else
            [sts, ~, data] = pspm_load_data(model.datafile{iFile}, model.marker_chan);
        end
        if sts < 1
            warning('ID:invalid_input','Could not load the specified marker channel.'); 
            return;
        end
        markers{iFile} = data{end}.data;
    end
    
    fprintf('.');
end

% Old sampling rate
oldsr = sr;

% Checking if the sampling rate is the same for all samples.
if n_file > 1 && any(diff(sr) > 0)
    if ~model.filter.applied_filt || ...                                    % if no filter where specified
       (isnumeric(model.filter.down) && model.filter.down > min(sr)) ||...  % if filter.down is less than the minimal sr
       strcmpi(model.filter.down,'none')                                    % if filter.down is none
   
            model.filter.applied_filt = true;
            model.filter.down = min(sr);
            fprintf('\nSampling rate differs between sessions. Data will be downsampled.\n')
    end
else
    fprintf('\n');
end

%%%%%%%% Zscoring the data %%%%%%%%
if model.zscore
    fprintf('Zscoring ...\n')
    n_file = numel(model.datafile);
    for iFile = 1:n_file
      % NANZSCORE found in src/VBA/stats&plots
      [y{iFile},~,~] = nanzscore(y{iFile});
    end
end

%%%%%%%% Extracting segments %%%%%%%% 
fprintf('Extracting segments ...\n')

% temporary structure which is deleted after extracting segments
extrsgopt.timeunit = model.timeunits;    
extrsgopt.length = model.window;       % segments of 'model.window' time unit long
extrsgopt.plot = 0;                    % do not plot mean value and std 

for k=1:n_file
   if strcmpi(model.timeunits, 'markers')
       extrsgopt.marker_chan = markers(k);
   end
   
   [lsts, s] = pspm_extract_segments('manual', y(k), sr(k), model.timing(k), extrsgopt);
   if lsts<1, warning('ID:error_extract_segments','An error occured in pspm_extract_segments.'); return; end
   
   for i=1:n_exp_cond
        tmp_data.mean = s.segments{i,1}.mean;
        tmp_data.std = s.segments{i,1}.std;
        tmp_data.sem = s.segments{i,1}.sem;
        tmp_data.t = s.segments{i,1}.t;
        % a cell array of struct and of size (n_file x n_exp_cond) where each 
        % line correspond to a given file and each column to an 
        % experimental condition
        segm{k,i} = tmp_data;
        clear tmp_data
   end
      
end
clear extrsg tmp_data s lsts

%%%%%%%% Downsample the data %%%%%%%%
% if a filter was specified or if the data differ in sr
if model.filter.applied_filt
    fprintf('Filtering ...\n')
    for i = 1:n_exp_cond
        for k = 1:n_file
            
            model.filter.sr = sr(k);
            
            [lsts, segm{k,i}, ~] = structfun(@(x) pspm_prepdata(x, model.filter),segm{k,i},'UniformOutput',false);
            if any(structfun(@(x) x<1,lsts)), warning('ID:error_prepdata','An error occured in pspm_prepdata.'); return; end
                
            clear new_sr lsts
        end
    end
    
    % changing the sampling rate
    sr = model.filter.down*ones(size(sr));
    
    % delete fields that are not useful for the model output
    model.filter = rmfield(model.filter,'sr');
    model.filter = rmfield(model.filter,'applied_filt');
    filtered = 1;
    
% if data were not filtered
else    
    model = rmfield(model,'filter');
    filtered = 0;
end

%%%%%%%% Determining mean values %%%%%%%%
fprintf('Preparing for fitting ...\n')

baseline_index = floor(sr(1)*model.baseline)+1;

if exist('std_exp_cond','var')
    tmp_data = [segm{:,std_exp_cond.ind}];
    
    std_exp_cond.data = nanmean([tmp_data.mean],2);
    std_exp_cond.std = nanmean([tmp_data.std],2);
    std_exp_cond.sem = nanmean([tmp_data.sem],2);
end

for i=1:n_exp_cond
    
    tmp_data = [segm{:,i}];
    
    tmp_data_new.data = nanmean([tmp_data.mean],2);
    tmp_data_new.std = nanmean([tmp_data.std],2);
    tmp_data_new.sem = nanmean([tmp_data.sem],2);
    tmp_data_new.t = nanmean([tmp_data.t],2);
    
    % Subtracting the standard experimental condition
    if exist('std_exp_cond','var') && i~=std_exp_cond.ind
       tmp_data_new.data = tmp_data_new.data - std_exp_cond.data;
       tmp_data_new.std = tmp_data_new.std + std_exp_cond.std;      % the error adds up
       tmp_data_new.sem = tmp_data_new.sem + std_exp_cond.sem;      % the error adds up
    end
        
    % Baselining data
    tmp_data_new.data = tmp_data_new.data - tmp_data_new.data(baseline_index);
    
    % Dividing by the max value
    if model.norm
        [tmp_max,tmp_max_ind] = max(tmp_data_new.data);
        tmp_data_new.data = tmp_data_new.data/tmp_max;
        tmp_data_new.std = tmp_data_new.std + tmp_data_new.std(tmp_max_ind); % the error adds up
        tmp_data_new.sem = tmp_data_new.sem + tmp_data_new.sem(tmp_max_ind); % the error adds up
    end
    
    mean{1,i} = tmp_data_new;
    
    clear tmp_data tmp_data_new tmp_max tmp_max_ind
end

%%%%%%%% Fitting the model %%%%%%%%
fprintf('Fitting ...\n')

for i=1:n_exp_cond    
    raw_y = mean{1,i}.data; 
    
    n = model.window;
    td = n / length(raw_y);
    
    % Extending the size of the data vector in order to do the fitting,
    % because if size(raw_y)=[n 1], the convolution would produce a vector of
    % size [2*n-1 1] so we have to extend the size of the data vector. 
    conv_y = [ raw_y ; zeros(size(raw_y,1)-1,size(raw_y,2))];
    
    % Predicted signal (LTI model)
    predicted_y = @(x) conv(model.if.fhandle([td,n,x]),model.bf.fhandle([td, n, model.bf.args])).';

    % Residual Sum Square (RSS) calculation (basically error btw conv_y and predicted_y)
    RSS = @(x) norm(conv_y - predicted_y(x), 2)^2;

    % Minimization of RSS 
    warning off all
    [~, fitted{1,i}.optargs, fitted{1,i}.fval, sts, fmincon_output] = ...
            evalc('fmincon(RSS,model.if.args,[],[],[],[],model.if.lb,model.if.ub)');
    warning on all
    if sts == 0 
        warning('ID:fmincon',['During the fitting process, ''fmincon'' exceeded', ...
                              ' the number of iterations or the number of function evaluations.', ...
                              ' Try to change the initial arguments and bounds to improve the fitting.'])
    elseif sts == -1
        warning('ID:fmincon',['During the fitting process, ''fmincon''', ...
                              ' was terminated by an output function or a plot.']);
        fprintf('Here is the output of fmincon:\n');
        disp(fmincon_output);
    elseif sts == -2
        warning('ID:fmincon',['During the fitting process, ''fmincon''', ...
                              ' haven''t found any feasible point.']);
        fprintf('Here is the output of fmincon:\n');
        disp(fmincon_output);
    end
    
    % Calculating the predicted signal that will be included in the output structure
    fitted{1,i}.data = predicted_y(fitted{1,i}.optargs); 
    % Cutting away tail
    tmp_y = mean{1,i}.data; 
    fitted{1,i}.data(size(tmp_y,1)+1:end) = [];
    
end

%%%%%%%% Saving model %%%%%%%% 
fprintf('Saving model ...\n');

% Collecting input model information
pfm.modelfile     = model.modelfile;
pfm.input         = model;
pfm.input.options = options;
pfm.input.sr      = num2cell(oldsr(:).');
pfm.bf            = model.bf;
pfm.if            = model.if;

% Collecting fitting data
tmp_mean = [mean{1,:}];
pfm.data.Y        = {tmp_mean.data};
pfm.data.X        = {tmp_mean.t};
pfm.data.std      = {tmp_mean.std};
pfm.data.sem      = {tmp_mean.sem};
pfm.data.sr       = num2cell(sr(:).');
pfm.data.filtered = filtered;
pfm.data.zscored  = model.zscore;
pfm.data.norm     = model.norm;

if exist('std_exp_cond','var')
    pfm.data.std_exp_cond.name  = std_exp_cond.name;
    pfm.data.std_exp_cond.ind   = std_exp_cond.ind;
else
    pfm.data.std_exp_cond       = 'none';
end

% Collecting fits
tmp_fitted = [fitted{1,:}];
pfm.fit.Y         = {tmp_fitted.data};
pfm.fit.X         = {tmp_mean.t};
pfm.fit.rss       = {tmp_fitted.fval};  % RSS (residual sum square)
pfm.fit.args      = {tmp_fitted.optargs};
pfm.fit.sr        = num2cell(sr(:).');

pfm.infos.duration     = model.window;
pfm.infos.durationinfo = 'duration in seconds';

pfm.timing        = model.timing;

pfm.modeltype     = 'pfm';
pfm.modality      = model.modality;

pfm.names         = model.timing{1}.names(:).';

% Saving structure
savedata = struct('pfm', pfm);
[sts, ~ , ~ ] = pspm_load1(model.modelfile, 'save', savedata, options);
if sts == -1
    warning('ID:invalid_input', 'call of pspm_load1 failed');
    return;
end

%%%%%%%% User output %%%%%%%%
output = pfm;

fprintf('done. \n');

end