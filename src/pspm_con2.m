function pspm_con2(modelfile, outfile, con, connames, options)
% ● Description
%   pspm_con2 is a function to set up second level contrasts. Currently,
%   one- and two-sample t-tests are implemented.
% ● Format
%   pspm_con2(modelfile, outfile, con, connames, [datatype], [options])
% ● Arguments
%   modelfile:  a cell array of modelfiles for a one-sample t-tests, or a 2x1
%               array of cell arrays with modelfiles for a two-sample t-test
%               note: all modelfiles need to have the same contrasts (it's best
%               to compute these with pspm_con1 in one call)
%     outfile:  a file the model is being saved to
%         con:  optional argument containing a vector with the contrasts for which
%               the second level should be set up (default: all), or 'all'
%     conname:  optional argument containing names for the contrasts or the
%               option 'file' to be read from first model file. contrasts
%               will be numbered by default if this argument is missing or has
%               value 'number'
%     options:  
%  .overwrite:  defines whether to overwrite existing files.
%               (default = 0).
% ● Version
%   PsPM 3.0
% ● Written By
%   (c) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
%% check input arguments
if nargin<1
  errmsg = sprintf('No first level model file(s) stated'); warning(errmsg); return
elseif nargin<2
  errmsg = sprintf('No second level output file stated'); warning(errmsg); return
elseif nargin<3
  con = 'all';
end
if nargin < 4
  conoption = 'number';
elseif ~iscell(connames);
  if strcmpi(connames, 'number') || strcmpi(connames, 'file')
    conoption = connames;
  else
    warning('Unknown contrast option - contrasts will be read from model file.');
    conoption = 'file';
  end
else
  conoption = 'name';
end
datatype = 'any';
if nargin < 5 || ~isfield(options, 'overwrite') || ~isnumeric(options.overwrite)
  options.overwrite = 0;
end
if ischar(con)
  if ~strcmpi(con, 'all')
    errmsg = sprintf('Invalid contrast option (%s)', con); warning(errmsg); return
  else
    con = 0;
  end
end
%% check model file(s)
if ~iscell(modelfile)
  errmsg = sprintf('Parameter modelfile needs to be a cell array'); warning(errmsg); return
elseif numel(modelfile) == 2&&(iscell(modelfile{1}))
  sample = 2;
else
  sample = 1;
end
%% check outfile
if isfile(outfile)
  overwrite = pspm_overwrite(outfile, options)
  if overwrite == 0
    return
  end
end
%% assemble input (for diagnostic checking)
t.input.inputfile = modelfile;
t.input.modelfile = outfile;
t.input.con = con;
t.input.connames = connames;
t.input.datatype = datatype;
%% get contrasts
if sample==1
  for n=1:numel(modelfile)
    [sts, foo] = loadmodel(modelfile{n}, datatype);
    if sts == -1, return; end
    if con==0, con=1:numel(foo); end
    t.beta(n,:) = [foo(con).con];
    if n == 1 && strcmp(conoption, 'file'), connames = {foo(con).name}'; end
  end
  % exclude NaN values - might happen with non-standard analysis
  indx = find(any(isnan(t.beta), 2));
  if ~isempty(indx)
    t.beta(indx, :) = [];
    warning('%5.0f datasets with NaN values were excluded', numel(indx));
  end
  t.df = repmat(size(t.beta, 1)-1, 1, size(t.beta, 2));
  t.t = mean(t.beta)./(eps+(std(t.beta)/sqrt(size(t.beta, 1))));
  t.p = (1-spm_Tcdf(abs(t.t), t.df))*2; % 2-tailed test
  t.type = 1;
else
  for s = 1:2
    for n = 1:numel(modelfile{s})
      [sts, foo] = loadmodel(modelfile{s}{n}, datatype);
      if sts == -1, return; end
      if con == 0, con = 1:numel(foo); end
      t.beta{s}(n,:) = [foo(con).con];
      if n == 1 && strcmp(conoption, 'file'), connames = {foo.name}'; end
    end
  end
  t.df = repmat(size(t.beta{1}, 1)+size(t.beta{2}, 1)-2, 1, size(t.beta{1}, 2));
  for n = 1:size(t.beta{1}, 2)
    sd = sqrt(((size(t.beta{1}, 1)-1) * (std(t.beta{1}(:,n))).^2 + ...
      (size(t.beta{2}, 1)-1) * (std(t.beta{2}(:,n))).^2) ./ t.df(n));
    se = sd * sqrt(1./size(t.beta{1}, 1) + 1./size(t.beta{2}, 1));
    t.t(n)=(mean(t.beta{1}(:,n)-mean(t.beta{2}(:,n))))/se;
    t.p(n)=(1-spm_Tcdf(abs(t.t(n)), t.df(n)))*2; % two tailed test
  end
  t.type=2;
end
if numel(connames)~=numel(con) && ~strcmpi(conoption, 'number')
  errmsg = sprintf(['Number of contrast names (%d) ',...
    'does not match number of contrasts (%d) - contrasts will be numbered instead'], ...
    numel(connames), numel(con));
  warning(errmsg);
  conoption = 'number';
end
if strcmpi(conoption, 'number');
  for n=1:numel(con)
    t.names{n}=sprintf('Contrast %d', n);
  end
else
  t.names = connames;
end
t.files = modelfile;
%% save
save(outfile, 't');
%% subfunctions
function [sts, foo] = loadmodel(modelfile, datatype)
[sts, foo] = pspm_load1(modelfile, 'con', datatype);
if isempty(foo)
  warning('No contrasts contained in file %s', modelfile);
  sts = -1;
end