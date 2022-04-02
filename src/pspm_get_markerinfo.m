function [sts, markerinfo] = pspm_get_markerinfo(fn, options)
% ● DESCRIPTION
% pspm_get_markerinfo extracts markerinfo from PsPM files that contain
% such information (typically after import of EEG-style data files, e.g.
% BrainVision or NeuroScan)
% ● FORMAT
% [sts, markerinfo] = pspm_get_markerinfo(filename, options)
% ● INPUT
% filename        [char]
%                 name of PsPM file
%                 if empty, you will be prompted for one
% options
% ┣━.markerchan   [double]
% ┃               channel id of the marker channel;
% ┃               default value: -1, meaning to use the first found marker channel
% ┣━.filename     [char]
% ┃               name of a file to write the markerinfo to;
% ┃               default value: empty, meaning no file will be written
% ┗━.overwrite    [logical] (0 or 1)
%                 define whether to overwrite existing output files or not
% ● OUTPUT
% sts             [double]
%                 default value: -1 if unsuccessful
% markerinfo      [struct]
% ┣━.name         [char]
% ┣━.value
% ┗━.element
% ● VERSION
% PsPM 6.0
% ● AUTHORSHIP
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%     2022      Teddy Chao (UCL)

global settings;
if isempty(settings), pspm_init; end
% set output values
sts = -1;
markerinfo = [];
if nargin <= 1
  options = struct();
end
if ~isfield(options, 'markerchan')
  options.markerchan = -1;
end
if ~isfield(options, 'filename')
  options.filename = '';
end
if ~isfield(options, 'overwrite')
  options.overwrite = false;
end
if ~isstruct(options)
  warning('ID:invalid_input', 'Options has to be a struct.'); return;
elseif isfield(options, 'filename') && ~ischar(options.filename)
  warning('ID:invalid_input', 'Options.filename has to be char.'); return;
elseif isfield(options, 'markerchan') && ~isnumeric(options.markerchan)
  warning('ID:invalid_input', 'Options.markerchan has to be numeric.'); return;
elseif isfield(options, 'overwrite') && ~islogical(options.overwrite)
  warning('ID:invalid_input', 'Options.overwrite must be logical.'); return;
end
% check input arguments
if nargin < 1 || isempty(fn)
  fn = spm_select(1, 'mat', 'Extract markers from which file?');
end
if options.markerchan == -1
  options.markerchan = 'events';
end
% get file
[bsts, ~, data] = pspm_load_data(fn, options.markerchan);
if bsts == -1, return, end
% check markers
if isempty(data{1}.data)
  sts = -1;
  warning('File (%s) contains no event markers', fn);
  return;
end
%% extract markers: find unique type/value combinations ...
markertype = data{1}.markerinfo.name;
markervalue = data{1}.markerinfo.value;
markerall = strcat(markertype', regexp(num2str(markervalue'), '\s+', 'split'));
markerunique = unique(markerall);
% ... and write them into a struct
for k = 1:numel(markerunique)
  % find all elements
  indx = find(strcmpi(markerall, markerunique{k}));
  % and use first one to extract type and value information
  markerinfo(k).name = markertype{indx(1)};
  markerinfo(k).value = markervalue(indx(1));
  markerinfo(k).elements = indx';
end
% if necessary, write into a file
outfn = options.filename;
if ~isempty(outfn)
  if exist(outfn, 'file')
    if options.overwrite
      write_ok = true;
    elseif strcmpi('Yes', ...
        questdlg(sprintf('File (%s) already exists. Overwrite?', outfn)))
      write_ok = true;
    else
      write_ok = false;
    end
  else
    write_ok = true;
  end
  if write_ok
    save(outfn, 'markerinfo');
  end
end
