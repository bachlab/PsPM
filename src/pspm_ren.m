function newfilename = pspm_ren(filename, newfilename)

% pspm_ren renames an SCR datafile and updates the infos field
%
% FORMAT:
% NEWFILENAME = pspm_ren(FILENAME, NEWFILENAME)
%
% FILENAME can be a name, or for convenience, a cell array of filenames
% ● Introduced In
%   PsPM 3.0
% ● Written By
%   (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

if nargin < 2
  errmsg = sprintf('No new filename given.');
  warning('ID:invalid_input', errmsg);
  return;
end;

warningflag = 0;
if ~((ischar(filename)&&ischar(newfilename))||((iscell(filename)&&iscell(newfilename))))
  warningflag = 1;
elseif ischar(filename)&&ischar(newfilename)
  if ~(size(filename, 1) == 1&&size(newfilename, 1) == 1)
    warningflag = 1;
  else
    filename = {filename};
    newfilename = {newfilename};
  end;
elseif iscell(filename)&&iscell(newfilename)
  if numel(filename) ~= numel(newfilename)
    warningflag = 1;
  end;
end;

if warningflag
  errmsg = sprintf('You must provide either two filenames, or two matched cell arrays of filenames.');
  warning('ID:invalid_input', errmsg);
  newfilename =[];
  return;
end;

%-------------------------------------------------------------------------
% work on files
%-------------------------------------------------------------------------
for f = 1:numel(filename)
  fn = filename{f};
  [pth nfn ext] = fileparts(newfilename{f});
  if isempty(ext)
    ext = 'mat';
  end;
  if isempty(pth)
    [pth foo foo2] = fileparts(fn);
  end;
  fnfn = fullfile(pth, [nfn, ext]);
  [sts, infos, data] = pspm_load_data(fn);
  if sts == -1
    warning('ID:invalid_input', 'Could not load data properly.');
    return;
  end;
  infos.rendate = date;
  infos.newname = [nfn ext];
  save(fnfn, 'infos', 'data');
  delete(fn);
  clear fn nfn fnfn pth ext foo foo2
end;

%-------------------------------------------------------------------------
% output
%-------------------------------------------------------------------------

if numel(newfilename) == 1
  newfilename = newfilename{1};
elseif isempty(newfilename)
  newfilename = [];
end;
