function outfile = pspm_merge(infile1, infile2, reference, options)
% pspm_merge merges two PsPM datafiles with different channels and
% writes it to a file with the same name as the first file, prepended 'm'.
% The data is aligned to file start or first marker. Data after the reference
% are extended to the duration of the longer data file
%
% ● Format
%   outfile = pspm_merge(infile1, infile2, reference, options)
%
% infile1, infile2: data file name(s) (char, or cell array for multiple
%                   files)
% reference:        'marker' aligns with respect to first marker
%                   'file'   aligns with respect to file start
% options:
% options.overwrite: overwrite existing files by default
% options.marker_chan_num: 2 marker channel numbers - if undefined
%                          or 0, first marker channel is used
% ● Introduced In
%   PsPM 3.0
% ● Written By
%   (C) 2008-2015 Dominik R Bach (UZH, WTCN)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
outfile = [];

% check input
% -------------------------------------------------------------------------
% check missing input --
if nargin < 3
  warning('Not enough input'); return;
end;

% check faulty input --
if ischar(infile1)
  infile1 = {infile1};
elseif ~iscell(infile1)
  warning('Data file names must be strings or cell arrays'); return;
end;
if ischar(infile2)
  infile2 = {infile2};
elseif ~iscell(infile2)
  warning('Data file names must be strings or cell arrays'); return;
end;
if numel(infile1) ~= numel(infile2)
  warning('Number of data files does not match'); return;
end;
infile = {infile1, infile2};
if ~ischar(reference) || ~ismember(reference, {'marker', 'file'})
  warning('Reference must be ''marker'' or ''file''.'); return;
end;

% check options --
try options.overwrite, catch, options(1).overwrite = 0; end;
try options.marker_chan_num, catch, options.marker_chan_num = [0 0]; end;

% loop through data files
% -------------------------------------------------------------------------
for iFile = 1:numel(infile{1})
  % read input files --
  infos = cell(2,1);
  data = cell(2,1);
  for iNum = 1:2
    [sts, infos{iNum}, data{iNum}] = pspm_load_data(infile{iNum}{iFile});
    if sts ~= 1
      warning('ID:invalid_input', 'call of pspm_load_data failed');
      return;
    end;
  end;
  % for marker alignment, trim data before first marker --
  if strcmpi(reference, 'marker')
    for iNum = 1:2
      trimdata.data = data{iNum}; trimdata.infos = infos{iNum};
      trimoptions.marker_chan_num = options.marker_chan_num(iNum);
      trimdata = pspm_trim(trimdata, 0, 'none', 'marker', trimoptions);
      data{iNum} = trimdata.data; infos{iNum} = trimdata.infos;
    end;
  end;
  % put together and cut away data from the end --
  [sts, data, duration] = pspm_align_channels([data{1}; data{2}]);
  if sts ~= 1
    warning('ID:invalid_input', 'call of pspm_align_channels failed');
    return;
  end;
  % collect infos --
  oldinfos = infos; infos = struct([]);
  infos(1).duration = duration;
  try infos.sourcefile = {oldinfos{1}.importfile; oldinfos{2}.importfile}; end;
  try infos.importfile = {oldinfos{1}.importfile; oldinfos{2}.importfile}; end;
  try infos.importdate = {oldinfos{1}.importdate; oldinfos{2}.importdate}; end;
  try infos.recdate = {oldinfos{1}.recdate; oldinfos{2}.recdate}; end;
  try infos.rectime = {oldinfos{1}.rectime; oldinfos{2}.rectime}; end;
  infos.mergedate = date;
  infos.mergedref = reference;
  % create output file name and save data --
  [pth, fn, ext] = fileparts(infile{1}{iFile});
  outfile{iFile} = fullfile(pth, ['m', fn, ext]);
  infos.mergedfile = outfile{iFile} ;
  outdata.data = data; outdata.infos = infos; outdata.options = options;
  sts = pspm_load_data(outfile{iFile}, outdata);
  if sts ~= 1, return; end;
end;

% convert to char if only one file was given
if numel(infile{1}) == 1, outfile = outfile{1}; end;
return;