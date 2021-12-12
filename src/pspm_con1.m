function pspm_con1(modelfile, connames, convec, datatype, deletecon, options)
% pspm_con1 creates contrasts on the first level (i.e. within one dataset)
% and saves them to the modelfile to be accessed later
%
% FORMAT:
% pspm_con1 (modelfile, connames, convec, [datatype, deletecon, options])
%
% modelfile: a filename, or cell array of filenames
% connames: a cell array of names for the desired contrasts
% convec: a cell array of contrasts
%
% optional arguments
% datatype: 'param': use all parameter estimates
%           'cond': GLM - contrasts formulated in terms of conditions, 
%                   automatically detects number of basis functions and 
%                   uses only the first one (i.e. without derivatives)
%                   other models - contrasts based on unique trial names 
%           'recon': contrasts formulated in terms of conditions in a GLM,
%                   reconstructs estimated response from all basis functions
%                   and uses the peak of the estimated response
%           deletecon: should existing contrasts be deleted (1) or 
%                   appended (0)? 
%                   default = 0;
% options: options.zscored: 1 - zscore data
%                               Restriction: only for non-linear models 
%                               and not when datatype == 'recon'
%                           0 - do not zscore data
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)


% initialise 
% ------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end;

% check input arguments
% ------------------------------------------------------------------------
if nargin<1
    errmsg=sprintf('No modelfile specified'); warning(errmsg); return;
elseif nargin<2
    errmsg=sprintf('No contrast names specified'); warning(errmsg); return;
elseif nargin<3
    errmsg=sprintf('No contrasts specified'); warning(errmsg); return;
elseif nargin<4
    datatype = 'param';
end;
if nargin < 5
    deletecon = 0;
end;
if nargin < 6
    options = struct();
end;

% check & convert filename --
if ischar(modelfile)
    modelfile={modelfile}; 
elseif ~iscell(modelfile)
    warning('Model file must be string or cell array of string.');
end;

% check contrasts --
if ~iscell(convec)
    warning('Please specify a cell array of contrast vectors.'); return;
end;
for c=1:numel(convec)
    if ~isnumeric(convec{c})
        errmsg=sprintf('Contrast #%d is not a numeric vector.', c); warning(errmsg); return;
    end;
end;

% check contrast --
if numel(connames)~=numel(convec)
     warning('Number of contrast names (%d) and number of contrast vectors (%d) don''t match.', ...
         numel(connames), numel(convec));
     return;
end;

% store for output
out_datatype = datatype;
switch datatype
    case 'param'
        datatype = 'stats';
    case {'cond', 'recon'}
    otherwise
        warning('Unknown datatype');
        return;
end;

% set load1_options
load1_options = struct('zscored',0);
if isfield(options, 'zscored') && options.zscored
    load1_options.zscored = 1;
end;

% work on contrasts
% ------------------------------------------------------------------------
for iFn =1:numel(modelfile)
    % user output --
    fprintf('Loading data ... ');

    % retrieve stats --
    [sts, data, mdltype] = pspm_load1(modelfile{iFn}, datatype, '', load1_options);
    if sts == -1
        warning('ID:invalid_input', 'Could not retrieve stats'); 
        return;
    end;
    % create con structure or retrieve existing contrasts --
    if deletecon == 1
        con = []; conno = 0; 
    else
        [sts, con] = pspm_load1(modelfile{iFn}, 'con');
        if sts == -1
            fprintf(' Creating fresh contrast structure.\n');
            con = []; conno = 0;
        else
            conno = numel(con);
        end;
    end;
    
    % user output --
    fprintf('\nWriting contrasts to %s\n', modelfile{iFn});
    % check number of contrast weights --
    paramno = size(data.stats, 1);
    for c=1:numel(convec)
        if numel(convec{c}) > paramno
            warning('Contrast (%d) has more weights than statistics (%d) in modelfile %s', ...
                numel(convec{c}), paramno, modelfile{iFn}); return;
        end;
    end;
    % transform into row vector and right pad with zeros --
    conmat=zeros(numel(connames), paramno);
    for c=1:numel(convec)
        conmat(c,1:numel(convec{c}))=convec{c};
    end;

    % calculate contrasts --
    % this automatically replicates contrasts across multiple measures if
    % data.stats has more than one column
    conval = conmat * data.stats;
    
    % zscored text-output for connames
    if isfield(data, 'zscored') && data.zscored 
        out_zscored = ' (z-scored)';
    else
        out_zscored = '';
    end
    
    % create name matrix if necessary --
    if size(conval, 2) > 1
       for iCon = 1:size(conval, 1)
           for iMsr = 1:size(conval, 2)
               newconnames{iCon, iMsr} = sprintf('%s - %s%s', connames{iCon}, ...
                   data.names{iMsr}, out_zscored);
           end;
       end;
    else
        newconnames = connames;
    end;
    
    % save contrasts
    for iCon=1:numel(conval)
        con(conno+iCon).type   = out_datatype;
        con(conno+iCon).name   = newconnames{iCon};
        con(conno+iCon).con    = conval(iCon);
        indx = mod(iCon, size(conval, 1)); 
        if indx == 0, indx = size(conval, 1); end;
        con(conno+iCon).convec = conmat(indx, :);
    end;
    pspm_load1(modelfile{iFn}, 'savecon', con);
end;

    

   
