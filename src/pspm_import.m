function outfile = pspm_import(datafile, datatype, import, options)
% ● DESCRIPTION
% pspm_import imports scr data from different formats and writes them to a
% file to the same path
% ● FORMAT
% outfile = pspm_import(datafile, datatype, import, options)
% ● INPUT
% datafile      file containing the scr data, or cell array of files
% datatype      supported datatypes are defined in pspm_init (see manual)
% import        a cell array of struct with one job (imported channel)
% ┃             per cell
% ┃             ▶︎ mandatory fields for all data types and each job
% ┣━.type       not all data types support all channel types
% ┃             ▶︎ mandatory fields for some data types and each channel
% ┣━.sr         sampling rate for waveform, or timeunit in s for event
% ┃             channels
% ┣━.channel    channel or column number in the original file
% ┃             ▶︎ optional fields for some data types and channel types
% ┣━.flank      optional, string, applicable for continuous channels only
%	┃							accepted values: 'ascending', 'descending', 'both'
% ┃             default: 'both'
% ┣━.transfer:  name of a .mat file containing values for
% ┃             the transfer function, OR a struct array containing the
% ┃             values OR 'none', when no conversion is required
% ┃             (c and optional Rs and offset, see pspm_transfer_function
% ┃             for more information)
% ┣━.eyelink_trackdist
% ┃             distance between eyetracker and
% ┃             the participants' eyes. If is a numeric value the data in
% ┃             a pupil channel obtained with an eyelink eyetracking system
% ┃             are converted from arbitrary units to distance unit. If
% ┃             value is 'none' the conversion is disabled.
% ┃             (only for Eyelink imports)
% ┣━.distance_unit
% ┃             unit in which the eyelink_trackdist is measured.
% ┃             If eyelink_trackdist contains a numeric value, the default
% ┃             value is 'mm' otherwise the distance unit is ''. Can be
% ┃             one of the following units:'mm', 'cm', 'm', 'inches'.
% ┣━.denoise    for marker channels in CED spike format (recorded
% ┃             as 'level'), filters out markers duration longer than the
% ┃             value given here (in ms)
% ┗━.delimiter  for delimiter separated values, value used as delimiter
%               for file read
% options       a struct
% ┗━.overwrite  overwrite existing files by default
% ● OUTPUT
% outfile        a .mat file (or cell array of files) on the input file path
%               containing scr and event info
% ● VERSION
% PsPM 3.0
% ● AUTHORSHIP
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%     2022      Teddy Chao


%% DEVELOPERS NOTES: Structure of PsPM import
%
% pspm_import is a general function for handling of import jobs. It checks
% the import job, calls a datatype-specific function to extract data from
% the file, then calls channel-specific functions to convert the data,
% writes them to file, and checks the consistency of the output file using
% pspm_load_data
%
% Guideline for new data type functions:
% - functions are named as 'pspm_get_datatype' and called
%     [sts, import, sourceinfo] = pspm_get_datatype(filename, import)
% - data type must be described in pspm_init - see there for details
% - the function needs to take an import job and add, or each job, fields
% -- .data - the actual data
% -- .sr   - the sample rate for this channel (only if enabled in pspm_init)
% - optional fields
% -- .marker - for marker channels (see pspm_get_marker)
% -- .markerinfo - same
% -- .minfreq - minimum frequency for pulse channels
% -- .units - if data units are defined by the recording software
%
% - sourceinfo contains information on the source file, with field
%        -- .chan - a cell of string descriptions of the imported source
%                    channels, e. g. names, or numbers
%       and any optional fields that will be added to infos.source (e. g.
%           recording date & time, and others)
%
% Guideline for new channel functions:
% - functions are named as 'pspm_get_channeltype' and called
%      [sts, data] = pspm_get_channeltype(import)
% - see pspm_load_data for the required structure of 'data'
%
% Notes for multiple blocks:
% file formats that support multiple block storage within one file can
% return cell arrays import{1:blkno} and sourceinfo{1:blkno}; SCRalyze will
% save individual files for each block, with a filename 'pspm_fn_blk0x.mat'

%% 1 Initialise
global settings;
if isempty(settings), pspm_init; end
outfile = [];

%% 2 Input argument check & transform
if nargin < 1
  warning('ID:invalid_input', ...
    'No input file');
  return
elseif ~iscell(datafile) && ~ischar(datafile)
  warning('ID:invalid_input', ...
    'Input file needs to be a string or cell array');
  return
elseif nargin < 2
  warning('ID:invalid_input', ...
    'No data type'); return
elseif ~ischar(datatype)
  warning('ID:invalid_input', ...
    'Data type needs to be a string');
  return
elseif sum(strcmpi(datatype, {settings.import.datatypes.short})) == 0
  warning('ID:invalid_channeltype', ...
    'Data type (%s) not recognised', datatype);
  return
elseif nargin < 3
  warning('ID:invalid_input', ...
    'No import job');
  return
elseif ~iscell(import)
  if isstruct(import) && numel(import) == 1
    import = {import};
  else
    warning('ID:invalid_input', ...
      'Import needs to be a cell array of struct, or a single struct');
    return
  end
end

% 2.1 check options
try
  if options.overwrite ~= 1
    options.overwrite = 0;
  end
catch
  options.overwrite = 0;
end

% 2.2 convert data files
if iscell(datafile)
  D=datafile;
else
  D={datafile};
end
clear datafile


%% 3 Check import jobs

% 3.1 determine datatype
datatype = find(strcmpi(datatype, {settings.import.datatypes.short}));

% check number of jobs ---
% more than one job when only one is allowed?
if (~settings.import.datatypes(datatype).multioption) && (numel(import) > 1)
  % two jobs when one is an automatically assigned marker channel?
  if ~(settings.import.datatypes(datatype).automarker && numel(import) == 2 && ...
      any(strcmpi({import{1}.type, import{2}.type}, 'marker')))
    warning('ID:ivalid_import_struct', ...
      'Only one data channel can be imported at a time for data type ''%s''.\n', ...
      settings.import.datatypes(datatype).long); return
  end
end

% check each job ---
for k = 1:numel(import)
  % channel type specified?
  if ~isfield(import{k}, 'type')
    warning('ID:ivalid_import_struct', ...
      'No type given for import job %2.0f.\n', k);
    return
    % channel type allowed for this datatype?
  elseif sum(strcmpi(import{k}.type, settings.import.datatypes(datatype).chantypes)) == 0
    warning('ID:ivalid_import_struct', ...
      'Channel type ''%s'' in import job %2.0f is not supported for data type %s.\n', ...
      import{k}.type, k, settings.import.datatypes(datatype).long);
    return
    % sample rate given or automatically assigned?
  elseif ~isfield(import{k}, 'sr') && ~settings.import.datatypes(datatype).autosr
    warning('ID:ivalid_import_struct', ...
      'Sample rate needed for import job %02.0f of type %s.\n', ...
      k, import{k}.type);
    return
    % sample rate given AND automatically assigned? If yes, remove and say so.
  elseif isfield(import{k}, 'sr') && settings.import.datatypes(datatype).autosr
    import{k} = rmfield(import{k}, 'sr');
    fprintf('Sample rate for import job %02.0f of type %s discarded - will be automatically assigned.\n', ...
      k, import{k}.type);
  end
  % marker channel in data format where no channel name is needed?
  if strcmpi(import{k}.type, 'marker') && settings.import.datatypes(datatype).automarker
    import{k}.channel = 1;
  end
  % flank loading
  if ~isfield(import{k}, 'flank')
    l_type = {settings.chantypes.data};
    if strcmp(l_type{strcmp({settings.chantypes.type},{import{k}.type})},'wave')
      import{k}.flank = 'both'; % set both at the default flank
    end
  else
    if ~strcmp(import{k}.flank, 'ascending') && ...
        ~strcmp(import{k}.flank, 'descending') && ...
        ~strcmp(import{k}.flank, 'both')
      warning('ID:invalid_import_struct', ...
        'The option flank can only be ascending, descending or both.');
      return
    end
  end
  % channel number given? If not, set to zero, or assign automatically and display.
  if ~isfield(import{k}, 'channel')
    if settings.import.datatypes(datatype).searchoption
      import{k}.channel = 0;
    else
      import{k}.channel = k;
      fprintf('Assigned channel/column %1.0f to import job %1.0f of type %s.\n', k, k, import{k}.type);
    end
  end
  % assign channel type number
  import{k}.typeno = find(strcmpi(import{k}.type, {settings.chantypes.type}));
end

%% loop through data files
for d = 1:numel(D)
  % pass over to import function if datafile exists, otherwise next file
  file_exists = true;
  filename_in_msg = D{d};
  if iscell(D{d})
    filename_in_msg = D{d}{1};
    for i = 1:numel(D{d})
      file_exists = file_exists && exist(D{d}{i}, 'file');
    end
  else
    file_exists = exist(D{d}, 'file');
  end
  if file_exists
    [sts, import, sourceinfo] = feval(settings.import.datatypes(datatype).funct, D{d}, import);
  else
    sts = -1;
    warning('ID:nonexistent_file', ...
  		'\nDatafile (%s) doesn''t exist', filename_in_msg);
  end
  if sts == -1
    fprintf('\nImport unsuccesful for file %s.\n', filename_in_msg);
    break;
  end

  % split blocks if necessary ---
  if iscell(sourceinfo)
    blkno = numel(sourceinfo);
  else
    blkno = 1;
    import = {import};
    sourceinfo = {sourceinfo};
  end

  for blk = 1:blkno
    % convert data into desired channel type format ---
    data = cell(numel(import{blk}), 1);
    for k = 1:numel(import{blk})
      if ~isfield(import{blk}{k}, 'units'), import{blk}{k}.units = 'unknown'; end
      chantype = find(strcmpi(import{blk}{k}.type, {settings.chantypes.type}));
      [sts(k), data{k}] = feval(settings.chantypes(chantype).import, import{blk}{k});
      if isfield(import{blk}{k}, 'minfreq'), data{k}.header.minfreq = import{blk}{k}.minfreq; end
    end

    if any(sts == -1), fprintf('\nData conversion unsuccesful for job %02.0f file %s.\n', ...
        find(sts == -1), filename_in_msg); break; end

    % collect infos and save ---
    [pth, fn, ~] = fileparts(filename_in_msg);
    infos.source = sourceinfo{blk};
    infos.source.type = settings.import.datatypes(datatype).long;
    infos.source.file = D{d};
    infos.importdate = date;

    % align data length ---
    [sts, data, duration] = pspm_align_channels(data);
    if sts == -1, fprintf('\nData alignment unsuccesful for file %s.\n', D{d}); break; end
    infos.duration   = duration;
    infos.durationinfo = 'Recording duration in seconds';
    data = data(:);

    % save file ---
    if blkno == 1
      outfile{d, blk}=fullfile(pth, ...
        [settings.import.fileprefix, fn, '.mat']);
    else
      outfile{d, blk}=fullfile(pth, ...
        sprintf('%s%s_blk%02.0f.mat', settings.import.fileprefix, fn, blk));
    end
    infos.importfile = outfile{d};
    clear savedata
    savedata.data = data; savedata.infos = infos; savedata.options = options;
    sts = pspm_load_data(outfile{d, blk}, savedata);
    if sts ~= 1
      warning('Import unsuccessful for file %s.\n', D{d});
      outfile{d, blk} = [];
    end
  end
  fprintf(' done.\n');
  % convert import cell back and remove data ---
  import = import{1};
  for k = 1:numel(import)
    if isfield(import{k}, 'data'), import{k} = rmfield(import{k}, 'data'); end
  end
end
