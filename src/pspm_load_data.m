function [sts, infos, data, filestruct] = pspm_load_data(fn, chan)
% pspm_load_data checks and returns the structure of PsPM 3-5.x and
% SCRalyze 2.x data files - SCRalyze 1.x is not supported
%
% FORMAT: [sts, infos, data, filestruct] = pspm_load_data(fn, chan)
%           fn: filename, or struct with fields .infos, .data
%           chan: One of the below options:
%
%               0 or empty - returns all channels
%
%               vector of channelnumbers - returns only these channels
%
%               'wave' - returns all waveform channels
%
%               'events' - returns all event channels
%
%               'pupil' - goes through the below precedence order and
%                         loads all channels corresponding to the first
%                         existing option:
%
%                         1. Combined pupil channels (by definition also preprocessed)
%                         2. Preprocessed pupil channels corresponding to best eye
%                         3. Preprocessed pupil channels
%                         4. Best eye pupil channels
%
%                         Note that if there is only one eye in the datafile,
%                         that eye is defined as the best eye.
%
%               'channel type' - returns the respective channels
%                       (see settings for channel types)
%
%               'none' - just checks the file
%                   a struct with fields .infos, .data, .options - checks
%                      and saves file
%
%           sts: -1 if check is unsuccessful
%           infos: variable from data file
%           data: cell array of channels as specified
%           filestruct: A struct with the fields
%                       .numofchan
%                       .numofwavechan
%                       .numofeventchan
%                       .posofmarker' (first marker channel, or 0 if no
%                          marker channel exists)
%                       .posofchannels (number of the channels that
%                       were returned)
%__________________________________________________________________________
% PsPM 5.1.1
% (C) 2008-2021 PsPM Team


% -------------------------------------------------------------------------
% DEVELOPERS NOTES: General structure of PsPM data files
%
% each file contains two variables:
% infos - struct variable with general infos
% data  - cell array with channel specific infos and data
%
% mandatory fields:
% infos.duration (in seconds)
%
% data{n}.header
% data{n}.header.chantype (as defined in settings)
% data{n}.header.sr (sample rate in 1/second, or timestamp units in seconds)
% data{n}.header.units (data units, or 'events')
%
% data{n}.data (actual data)
%
% additionally, a typical file contains the optional infos:
% infos.sourcefile, infos.importfile, infos.importdate, import.sourcetype
% and, if available, also infos.recdate, infos.rectime
% some data manipulation functions (in particular, pspm_trim) update infos
% to record some file history
%
% data.header.chantype = 'trigger' is allowed for backward compatibility;
% this feature will be removed in the future
%
% compatibility with SCRalyze 1.x files was removed after version b2.1.8
% -------------------------------------------------------------------------


% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), pspm_init; end

% initialise output
sts = -1; infos = []; data = []; filestruct=[]; gerrmsg = '';

% input check
% -------------------------------------------------------------------------
if nargin < 1
  warning('ID:invalid_input', 'No datafile specified'); return;
elseif ~(ischar(fn) || isstruct(fn))
  warning('ID:invalid_input', 'Need string or struct input for datafile.'); return;
elseif nargin < 2
  chan = 0;
elseif isnumeric(chan)
  if any(chan < 0)
    warning('ID:invalid_input', 'Negative channel numbers not allowed.'); return;
  end
elseif ischar(chan)
  if any(~ismember(chan, [{settings.chantypes.type}, 'none', 'wave', 'events']))
    warning('ID:invalid_channeltype', 'Unknown channel type.'); return;
  end
elseif isstruct(chan)
  if ~(isfield(chan, 'infos') && isfield(chan, 'data'))
    warning('ID:invalid_input', 'Fields .infos and .data are required to save file.'); return;
  end
  try
    chan.options.overwrite = (chan.options.overwrite == 1);
  catch
    chan.options.overwrite = 0;
  end
  try
    chan.options.dont_ask_overwrite = (chan.options.dont_ask_overwrite == 1);
  catch
    chan.options.dont_ask_overwrite = 0;
  end
else
  warning('ID:invalid_input', 'Unknown channel option.');
end

% check whether file exists ---
if isstruct(fn)
elseif ~isstruct(chan) && ~exist(fn, 'file')
  warning('ID:nonexistent_file', 'Data file (%s) doesn''t exist', fn); return;
elseif exist(fn, 'file') && isstruct(chan) && ~chan.options.overwrite ...
    && ~chan.options.dont_ask_overwrite
  if feature('ShowFigureWindows')
    msg = ['File already exists. Overwrite?', newline, 'Existing file: ',fn];
    overwrite = questdlg(msg, 'File already exists', 'Yes', 'No', 'Yes');
  else
    overwrite = 'Yes';
  end
  if strcmp(overwrite, 'Yes')
    chan.options.overwrite = 1;
  else
    chan.options.overwrite = 0;
    warning('Data not saved.\n');
  end
end

% check file structure
% -------------------------------------------------------------------------
if isstruct(chan)
  try
    data = chan.data; infos = chan.infos;
  catch
    warning('ID:invalid_input', 'Input struct is not a valid PsPM struct'); return;
  end
  gerrmsg = sprintf('\nData structure is invalid:');
elseif isstruct(fn)
  try
    data = fn.data; infos = fn.infos;
  catch
    warning('ID:invalid_input', 'Input struct is not a valid PsPM struct'); return;
  end
else
  gerrmsg = sprintf('Data file %s is not a valid PsPM file:\n', fn);
  try
    load(fn);
  catch
    errmsg = [gerrmsg, 'Not a matlab data file.'];
    warning('ID:invalid_file_type', '%s', errmsg); return;
  end
  % check for SCRalyze 1.x files ---
  if exist('scr', 'var'), warning('ID:SCRalyze_1_file', 'SCRalyze 1.x compatibility is discontinued'); return; end;
end

% check variables ---
vflag = 0;
if ~exist('infos', 'var')
  vflag = 1;
elseif ~isstruct(infos)
  vflag = 1;
end

if isempty(data) || ~iscell(data)
  vflag = 1;
end

if vflag, errmsg = [gerrmsg, 'Some variables are either missing or invalid in this file.']; warning('ID:invalid_data_structure', '%s', errmsg); return; end;

% loop through channels
vflag = zeros(numel(data), 1);
wflag = zeros(numel(data), 1);
nflag = zeros(numel(data), 1);
for k = 1:numel(data)
  if ~isfield(data{k}, 'header') || ~isfield(data{k}, 'data')
    vflag(k) = 1;
  elseif size(data{k}.data, 2) > 1
    vflag(k) = 1;
  elseif ~isfield(data{k}.header, 'chantype') || ~isfield(data{k}.header, 'sr') || ~isfield(data{k}.header, 'units')
    vflag(k) = 1;
  elseif strcmpi(data{k}.header.units, 'events') && any(data{k}.data > infos.duration)
    wflag(k) = 1;
  elseif strcmpi(data{k}.header.units, 'events') && any(data{k}.data < 0)
    wflag(k) = 1;
  elseif ~strcmpi(data{k}.header.units, 'events') && (length(data{k}.data) < infos.duration * data{k}.header.sr - 3 || length(data{k}.data) > infos.duration * data{k}.header.sr + 3)
    wflag(k) = 1;
  elseif ~ismember(lower(data{k}.header.chantype), {settings.chantypes.type})
    nflag(k) = 1;
  elseif isempty(data{k}.data)
    warning('ID:missing_data', 'Channel %01.0f is empty.', k);
  end
end

if any(vflag), errmsg = [gerrmsg, sprintf('Invalid data structure for channel %01.0f.', find(vflag,1))]; warning('ID:invalid_data_structure', '%s', errmsg); return; end;
if any(wflag), errmsg = [gerrmsg, sprintf('The data in channel %01.0f is out of the range [0, infos.duration]', find(wflag,1))]; warning('ID:invalid_data_structure', '%s', errmsg); return; end;
if any(nflag), errmsg = [gerrmsg, sprintf('Unknown channel type in channel %01.0f', find(nflag,1))]; warning('ID:invalid_data_structure', '%s', errmsg); return; end;

% analyse file structure
filestruct.numofwavechan = 0;
filestruct.numofeventchan = 0;
filestruct.posofmarker = [];
filestruct.numofchan = numel(data);
for k = 1:numel(data)
  if strcmpi(data{k}.header.units, 'events')
    filestruct.numofeventchan = filestruct.numofeventchan + 1;
  else
    filestruct.numofwavechan = filestruct.numofwavechan + 1;
  end
  if any(strcmpi(data{k}.header.chantype, {'trigger', 'marker'}))
    filestruct.posofmarker = [filestruct.posofmarker k];
  end
end
if numel(filestruct.posofmarker) == 0
  filestruct.posofmarker = 0;
elseif numel(filestruct.posofmarker) > 1
  filestruct.posofmarker = filestruct.posofmarker(1); % first marker channel
end


% return channels, or save file
%--------------------------------------------------------------------------
flag = zeros(numel(data), 1);
if ischar(chan) && ~strcmp(chan, 'none')
  if strcmpi(chan, 'pupil') && isfield(infos.source, 'best_eye')
    flag = get_chans_to_load_for_pupil(data, flag, infos.source.best_eye);
  elseif strcmpi(chan, 'sps') && isfield(infos.source, 'best_eye')
    flag = get_chans_to_load_for_sps(data, flag, infos.source.best_eye);
  else
    for k = 1:numel(data)
      if (any(strcmpi(chan, {'event', 'events'})) && strcmpi(data{k}.header.units, 'events')) || ...
          (strcmpi(chan, 'wave') && ~strcmpi(data{k}.header.units, 'events')) || ...
          (any(strcmpi(chan, {'trigger', 'marker'})) && any(strcmpi(data{k}.header.chantype, {'trigger', 'marker'})))
        flag(k) = 1;
      elseif strcmp(data{k}.header.chantype, chan)
        flag(k) = 1;
      end
    end
  end
  if all(flag == 0)
    warning('ID:non_existing_channeltype', 'There are no channels of type ''%s'' in the datafile', chan); return;
  end
  
  data = data(flag == 1);
  filestruct.posofchannels = find(flag == 1);
elseif isnumeric(chan)
  if chan == 0, chan = 1:numel(data); end
  if any(chan > numel(data))
    warning('ID:invalid_input', 'Input channel number(s) are greater than the number of channels in the data'); return;
  end
  data = data(chan);
  filestruct.posofchannels = chan;
elseif isstruct(chan) && ~isempty(fn) && (~exist(fn, 'file') || chan.options.overwrite == 1)
  save(fn, 'infos', 'data');
  filestruct.posofchannels = 1:numel(data);
else
  filestruct.posofchannels = [];
end

sts = 1;
end

function flag = get_chans_to_load_for_pupil(data, flag, best_eye)
% Set flag variable according to the precedence order:
%
%   1. Combined channels (by definition also preprocessed)
%   2. Preprocessed channels corresponding to best eye
%   3. Preprocessed channels
%   4. Best eye pupil channels
%
% The earliest possible option is taken and then the function returns.
best_eye = lower(best_eye);
chantype_list = cellfun(@(x) x.header.chantype, data, 'uni', false);
pupil_channels = cell2mat(cellfun(...
  @(chantype) strncmp(chantype, 'pupil',numel('pupil')),...
  chantype_list,...
  'uni',...
  false...
  ));
preprocessed_channels = cell2mat(cellfun(...
  @(chantype) strcmp(chantype(end-2:end), '_pp'),...
  chantype_list,...
  'uni',...
  false...
  ));
combined_channels = cell2mat(cellfun(...
  @(chantype) contains(chantype, '_lr_') && strcmp(chantype(end-2:end), '_pp'),...
  chantype_list,...
  'uni',...
  false...
  ));
besteye_channels = cell2mat(cellfun(...
  @(chantype) strcmp(chantype(end-1:end), ['_' best_eye]) || contains(chantype, ['_' best_eye '_']),...
  chantype_list,...
  'uni',...
  false...
  ));
preprocessed_channels = preprocessed_channels & pupil_channels;
combined_channels = combined_channels & pupil_channels;
besteye_channels = besteye_channels & pupil_channels;

if any(combined_channels)
  flag = combined_channels;
elseif any(preprocessed_channels)
  flag = preprocessed_channels & besteye_channels;
  if ~any(flag)
    flag = preprocessed_channels;
  end
else
  flag = besteye_channels;
end
end


function flag = get_chans_to_load_for_sps(data, flag, best_eye)
% 16-06-21 This is a tempory patch for loading sps data, copied from
% pupil data
% It needs to be updated for testing the compatibility with sps
% Set flag variable according to the precedence order:
%
%   1. Combined channels (by definition also preprocessed)
%   2. Preprocessed channels corresponding to best eye
%   3. Preprocessed channels
%   4. Best eye pupil channels
%
% The earliest possible option is taken and then the function returns.
best_eye = lower(best_eye);
chantype_list = cellfun(@(x) x.header.chantype, data, 'uni', false);
sps_channels = cell2mat(cellfun(...
  @(chantype) strncmp(chantype, 'sps',numel('sps')),...
  chantype_list,...
  'uni',...
  false...
  ));
preprocessed_channels = cell2mat(cellfun(...
  @(chantype) strcmp(chantype(end-2:end), '_pp'),...
  chantype_list,...
  'uni',...
  false...
  ));
combined_channels = cell2mat(cellfun(...
  @(chantype) contains(chantype, '_lr_') && strcmp(chantype(end-2:end), '_pp'),...
  chantype_list,...
  'uni',...
  false...
  ));
besteye_channels = cell2mat(cellfun(...
  @(chantype) strcmp(chantype(end-1:end), ['_' best_eye]) || contains(chantype, ['_' best_eye '_']),...
  chantype_list,...
  'uni',...
  false...
  ));
preprocessed_channels = preprocessed_channels & sps_channels;
combined_channels = combined_channels & sps_channels;
besteye_channels = besteye_channels & sps_channels;

if any(combined_channels)
  flag = combined_channels;
elseif any(preprocessed_channels)
  flag = preprocessed_channels & besteye_channels;
  if ~any(flag)
    flag = preprocessed_channels;
  end
else
  flag = besteye_channels;
end
end
