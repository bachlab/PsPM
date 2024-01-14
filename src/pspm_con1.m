function pspm_con1(modelfile, connames, convec, datatype, deletecon, options)
% ● Description
%   pspm_con1 creates contrasts on the first level (i.e. within one dataset)
%   and saves them to the modelfile to be accessed later.
% ● Format
%   pspm_con1 (modelfile, connames, convec, [datatype, deletecon, options])
% ● Arguments
%    modelfile: a filename, or cell array of filenames
%     connames: a cell array of names for the desired contrasts
%       convec: a cell array of contrasts
%     datatype: 'param':  use all parameter estimates
%                'cond':  GLM - contrasts formulated in terms of conditions,
%                         automatically detects number of basis functions and
%                         uses only the first one (i.e. without derivatives)
%                         other models - contrasts based on unique trial names
%               'recon':  contrasts formulated in terms of conditions in a GLM,
%                         reconstructs estimated response from all basis
%                         functions and uses the peak of the estimated response
%    deletecon: define existing contrasts to be deleted (1) or appended (0,
%               default).
%      options: [struct]
%               .zscored: 1 - zscore data
%                             Restriction: only for non-linear models
%                             and not when datatype == 'recon'
%                         0 - do not zscore data
% ● History
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
%% 2 check input arguments
%% 2.1 check nargin
if nargin < 1
  errmsg = 'No modelfile specified'; warning(errmsg); return;
elseif nargin < 2
  errmsg = 'No contrast names specified'; warning(errmsg); return;
elseif nargin < 3
  errmsg = 'No contrasts specified'; warning(errmsg); return;
elseif nargin < 4
  datatype = 'param';
end
if nargin < 5
  deletecon = 0;
end
if nargin < 6
  options = struct();
end
%% 2.2 check & convert filenames
if ischar(modelfile)
  modelfile = {modelfile};
elseif ~iscell(modelfile)
  warning('Model file must be string or cell array of string.');
end
% 2.3 check contrasts
if ~iscell(convec)
  warning('Please specify a cell array of contrast vectors.'); return
end
for c=1:numel(convec)
  if ~isnumeric(convec{c})
    warning('Contrast #%d is not a numeric vector.', c); return
  end
end
% 2.4 check contrast
if numel(connames) ~= numel(convec)
  warning('Number of contrast names (%d) and number of contrast vectors (%d) don''t match.', ...
    numel(connames), numel(convec));
  return
end
% 2.5 store for output
out_datatype = datatype;
switch datatype
  case 'param'
    datatype = 'stats';
  case {'cond', 'recon'}
  otherwise
    warning('Unknown datatype');
    return
end
% 2.6 set load1_options
load1_options = struct('zscored',0);
options = pspm_options(options, 'con1');
if options.invalid
  return
end
if options.zscored
  load1_options.zscored = 1;
end
%% 3 work on contrasts
for iFn = 1:numel(modelfile)
  %% 3.1 user output --
  fprintf('Loading data ... ');
  %% 3.2 retrieve stats --
  [lsts, data, ~] = pspm_load1(modelfile{iFn}, datatype, '', load1_options);
  if lsts == -1
    warning('ID:invalid_input', 'Could not retrieve stats');
    return;
  end
  %% 3.3 create con structure or retrieve existing contrasts --
  if deletecon == 1
    con = []; conno = 0;
  else
    [lsts, con, ~] = pspm_load1(modelfile{iFn}, 'con');
    if lsts == -1
      fprintf(' Creating fresh contrast structure.\n');
      con = []; conno = 0;
    else
      conno = numel(con);
    end
  end
  %% 3.4 user output --
  fprintf('\nWriting contrasts to %s\n', modelfile{iFn});
  %% 3.5 check number of contrast weights --
  paramno = size(data.stats, 1);
  for c = 1:numel(convec)
    if numel(convec{c}) > paramno
      warning('Contrast (%d) has more weights than statistics (%d) in modelfile %s', ...
        numel(convec{c}), paramno, modelfile{iFn});
      return
    end
  end
  % 3.6 transform into row vector and right pad with zeros --
  conmat = zeros(numel(connames), paramno);
  for c = 1:numel(convec)
    conmat(c,1:numel(convec{c})) = convec{c};
  end
  % 3.7 calculate contrasts
  % this automatically replicates contrasts across multiple measures if
  % data.stats has more than one column
  % there are issues if data.stats has NaN and the corresponding conmat
  % also contains 0
  IdxIssueRow = any(isnan(data.stats),2);
  conval = conmat * data.stats; % initialise conval
  [Rconval, ~] = size(conval);
  if any(IdxIssueRow(:))
    for rconval = 1:Rconval
      if all(conmat(rconval,IdxIssueRow) == 0)
        % all the issues refer to 0 in conmat
        conval(rconval,:) = conmat(rconval,~IdxIssueRow) * data.stats(~IdxIssueRow,:);
        warning(['Calculated data.stats contain NaNs that are caused by unknown reasons. '...
          'However they were not used in the computation of the contrasts.']);
      else
        % the issues refer to non-0 or 0 in conmat
        conval(rconval,:) = conmat(rconval,:) * data.stats;
        warning(['Calculated data.stats contain NaNs that are caused by unknown reasons. '...
            'data.stats are then used in a contrasts, producing an invalid result (NaN).']);
      end
    end
  end
  % zscored text-output for connames
  if isfield(data, 'zscored') && data.zscored
    out_zscored = ' (z-scored)';
  else
    out_zscored = '';
  end
  % 3.8 create name matrix if necessary --
  if size(conval, 2) > 1
    for iCon = 1:size(conval, 1)
      for iMsr = 1:size(conval, 2)
        newconnames{iCon, iMsr} = sprintf('%s - %s%s', connames{iCon}, ...
          data.names{iMsr}, out_zscored);
      end
    end
  else
    newconnames = connames;
  end
  %% 3.9 save contrasts
  for iCon = 1:numel(conval)
    con(conno+iCon).type   = out_datatype;
    con(conno+iCon).name   = newconnames{iCon};
    con(conno+iCon).con    = conval(iCon);
    indx = mod(iCon, size(conval, 1));
    if indx == 0, indx = size(conval, 1); end
    con(conno+iCon).convec = conmat(indx, :);
  end
  pspm_load1(modelfile{iFn}, 'savecon', con);
end
return
