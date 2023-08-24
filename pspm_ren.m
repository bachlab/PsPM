function varargout = pspm_ren(filename, newfilename)
% ● Description
%   pspm_ren renames an SCR datafile and updates the infos field
% ● Format
%   newfilename = pspm_ren(filename, newfilename)
% ● Arguments
%      filename: can be a name, or for convenience, a cell array of filenames
%   newfilename: TBA.
% ● History
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Maintained in 2022 by Teddy Chao (UCL)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
switch nargout
  case 1
    varargout{1} = newfilename;
  case 2
    varargout{1} = sts;
    varargout{2} = newfilename;
end

if nargin < 2
  warning('ID:invalid_input', 'No new filename given.');
  return;
end

warningflag = 0;
if ~((ischar(filename)&&ischar(newfilename))||((iscell(filename)&&iscell(newfilename))))
  warningflag = 1;
elseif ischar(filename)&&ischar(newfilename)
  if ~(size(filename, 1) == 1&&size(newfilename, 1) == 1)
    warningflag = 1;
  else
    filename = {filename};
    newfilename = {newfilename};
  end
elseif iscell(filename)&&iscell(newfilename)
  if numel(filename) ~= numel(newfilename)
    warningflag = 1;
  end
end

if warningflag
  errmsg = sprintf('You must provide either two filenames, or two matched cell arrays of filenames.');
  warning('ID:invalid_input', errmsg);
  newfilename =[];
  return
end

%-------------------------------------------------------------------------
% work on files
%-------------------------------------------------------------------------
for f = 1:numel(filename)
  fn = filename{f};
  [pth, nfn, ext] = fileparts(newfilename{f});
  if isempty(ext)
    ext = 'mat';
  end
  if isempty(pth)
    [pth, ~, ~] = fileparts(fn);
  end
  fnfn = fullfile(pth, [nfn, ext]);
  [sts_load_data, infos, data] = pspm_load_data(fn);
  if ~sts_load_data
    warning('ID:invalid_input', 'Could not load data properly.');
    return;
  end
  infos.rendate = date;
  infos.newname = [nfn ext];
  save(fnfn, 'infos', 'data');
  delete(fn);
  clear fn nfn fnfn pth ext foo foo2
end

%% output
if numel(newfilename) == 1
  newfilename = newfilename{1};
elseif isempty(newfilename)
  newfilename = [];
end
sts = 1;
switch nargout
  case 1
    varargout{1} = newfilename;
  case 2
    varargout{1} = sts;
    varargout{2} = newfilename;
end
return
