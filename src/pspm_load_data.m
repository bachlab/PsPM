function [sts, infos, data, filestruct] = pspm_load_data(fn, chan)
% ● DESCRIPTION
% pspm_load_data checks and returns the structure of PsPM 3-5.x and
% ● FORMAT
% [sts, infos, data, filestruct] = pspm_load_data(fn, chan)
% ● INPUT
% fn          [char] filename / [struct] with fields
% ┣━.infos
% ┗━.data
% chan        [numeric vector] / [char] / [struct]
%             [vector]
%               0 or empty  returns all channels
%               number of channels
%                            returns only these channels
%             [char]
%               'wave'      returns all waveform channels
%               'events'    returns all event channels
%               'pupil'     goes through the below precedence order and
%                           loads all channels corresponding to the first
%                           existing option:
%                            1. Combined pupil channels
%                              (by definition also preprocessed)
%                            2. Preprocessed pupil channels
%                              corresponding to best eye
%                            3. Preprocessed pupil channels
%                            4. Best eye pupil channels
%                            please note that if there is only one eye in
%                           the datafile, that eye is defined as the best eye.
%                'channel type'
%                           returns the respective channels
%                            (see settings for channel types)
%                'none'      just checks the file
%             [struct] check and save file
%               ┣━.infos (mandatory)
%               ┣━.data (mandatory)
%               ┗━.options (mandatory)
% ● OUTPUT
% sts         [logical]
%             0 as default
%             -1 if check is unsuccessful
% infos       [struct]
%             variable from data file
% data        cell array of channels as specified
% filestruct  [struct]
% ┣━.numofchan
% ┃           number of channels
% ┣━.numofwavechan
% ┃           number of wave channels
% ┣━.numofeventchan
% ┃           number of event channels
% ┣━.posofmarker
% ┃           position of the first marker channel
% ┃           0 if no marker channel exists
% ┗━.posofchannels
%             number of the channels that were returned
% ● COMPATIBILITY
% SCRalyze 2.x data files - SCRalyze 1.x is not supported
% ● VERSION
% PsPM 6.0
% ● AUTHOSHIP
% (C) 2008-2021 Dominik R. Bach (Wellcome Centre for Human Neuroimaging, UCL)
%     2022 Teddy Chao (UCL)
% ● DEVELOPERS NOTES
% General structure of PsPM data files
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

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
infos = [];
data = [];
filestruct = [];
gerrmsg = '';
%% 2 Check the number of inputs
switch nargin
  case 0
    warning('ID:invalid_input', 'No datafile specified.');
    return;
  case 1
    chan = 0;
  case 2
    % accept
  otherwise
    warning('ID:invalid_input', 'Too many inputs specified.');
    return
end

%% 3 Check fn
% fn has to be a file or a struct
switch class(fn)
  case 'struct'
    % specify if fn is a struct
    if ~isfield(fn, 'data') || ~isfield(fn, 'infos')
      warning('ID:invalid_input', 'Input struct is not a valid PsPM struct');
      return
    end
  case {'string', 'char'}
    % specify if fn is a filename
    if ~exist(fn, 'file')
      if ~isstruct(chan) % if chan is not a struct, fn must exist
        warning('ID:nonexistent_file', 'The file fn does not exist.');
        return
      end
    else
      if ~isstruct(chan)
        % check fn as a mat file only if chan is not a struct
        % because if chan is a struct fn will be overwritten
        % fn exists but may not be a .mat file
        [~, ~, fExt] = fileparts(fn);
        if ~strcmpi(fExt,'.mat')
          errmsg = [gerrmsg, 'Not a matlab data file or .mat extraname is missing.'];
          warning('ID:invalid_file_type', '%s', errmsg);
          return
        end
        % fn is an existing .mat file but may not have required fields
        try
          fields = matfile(fn);
        catch
          errmsg = [gerrmsg, 'Not a matlab data file.'];
          warning('ID:invalid_file_type', '%s', errmsg);
          return
        end
        if isfield(fields, 'scr')
          warning('ID:SCRalyze_1_file', 'SCRalyze 1.x compatibility is discontinued');
          return
        end
        if isempty(fieldnames(load(fn, 'infos'))) || ...
            ~isstruct(load(fn, 'infos')) || ...
            isempty(fieldnames(load(fn, 'data'))) || ...
            ~isstruct(load(fn, 'data'))
          errmsg = [gerrmsg, 'Some variables are either missing or invalid in this file.'];
          warning('ID:invalid_data_structure', '%s', errmsg);
          return
        end
      end
    end
  otherwise
    % fn is neither a file nor a struct
    warning('ID:invalid_input', 'fn needs to be an existing file or a struct.');
    return
end

%% 4 Check chan
switch class(chan)
  case 'double'
    % in this case chan is specified as a number or a vector, as double
    % the number or the vector can only be a 0 or (a) positive number(s)
    if any(chan < 0)
      warning('ID:invalid_input', 'Negative channel numbers are not allowed.');
      return
    end
  case 'char'
    % in this case chan is specified as a char
    if any(~ismember(chan, [{settings.chantypes.type}, 'none', 'wave', 'events']))
      warning('ID:invalid_channeltype', 'Unknown channel type.');
      return
    end
  case 'struct'
    if ~isfield(chan, 'data') || ~isfield(chan, 'infos')
      % data and infos are mandatory fields and must be provided
      % gerrmsg = sprintf('\nData structure is invalid:');
      warning('ID:invalid_input', 'Input struct is not a valid PsPM struct');
      return
    end
    if ~isfield(chan, 'options')
      % options is an optional field
      chan.options = [];
    end
    % add default values
    if ~isfield(chan.options, 'overwrite')
      chan.options.overwrite = 0; % do not overwrite as default
    end
    if ~isfield(chan.options, 'dont_ask_overwrite')
      chan.options.dont_ask_overwrite = 0; % do not overwrite as default
    end
    % if fn exists but it's not clear whether to overwrite it
    if ~chan.options.overwrite && ~chan.options.dont_ask_overwrite
      if feature('ShowFigureWindows')
        msg = ['File already exists. Overwrite?', newline, 'Existing file: ',fn];
        overwrite = questdlg(msg, 'File already exists', 'Yes', 'No', 'Yes'); % default as Yes
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
  otherwise
    warning('ID:invalid_input', 'Unknown channel option.');
end

%% 5 Check infos
if isstruct(chan)
  infos = chan.infos;
else
  if isstruct(fn) % data is from a struct fn
    infos = fn.infos;
  elseif exist(fn, "file") % data is from a file fn
    loaded_infos = load(fn, 'infos');
    if isfield(loaded_infos, "infos") && numel(fieldnames(loaded_infos))==1
      infos = loaded_infos.infos;
    end
    clear loaded_infos
  end
end
flag_infos = 0;
if isempty(fieldnames(infos))
  flag_infos = 1;
else
  if ~isfield(infos, 'duration')
    flag_infos = 1;
  end
end
if flag_infos
  warning('ID:invalid_data_structure', 'Input data does not have sufficient infos');
  return
end

%% 6 Check data
if isstruct(chan)
  data = chan.data;
else
  if isstruct(fn) % data is from a struct fn
    data = fn.data;
  elseif exist(fn, "file") % data is from a file fn
    loaded_data = load(fn, 'data');
    if isfield(loaded_data, "data") && numel(fieldnames(loaded_data))==1
      data = loaded_data.data;
    end
    clear loaded_data
  end
end
% initialise error flags
vflag = zeros(numel(data), 1); % records data structure, valid if 0
wflag = zeros(numel(data), 1); % records whether data is out of range, valid if 0
nflag = zeros(numel(data), 1);
zflag = zeros(numel(data), 1); % records whether data is empty
% loop through channels
for k = 1:numel(data)
  % check header
  if ~isfield(data{k}, 'header')
    vflag(k) = 1;
  else
    if ~isfield(data{k}.header, 'chantype') || ...
        ~isfield(data{k}.header, 'sr') || ...
        ~isfield(data{k}.header, 'units')
      vflag(k) = 1;
    else
      if ~ismember(lower(data{k}.header.chantype), {settings.chantypes.type})
        nflag(k) = 1;
      end
    end
  end
  % check data
  if vflag(k)==0 && nflag(k)==0 && flag_infos==0
    % required information is available and valid in header and infos
    if ~isfield(data{k}, 'data')
      vflag(k) = 1;
    else
      if ~isvector(data{k}.data)
        vflag(k) = 1;
      else
        if isempty(data{k}.data)
          zflag(k) = 1;
        end
        if strcmpi(data{k}.header.units, 'events')
          if (any(data{k}.data > infos.duration) || any(data{k}.data < 0))
            wflag(k) = 1;
          end
        else
          if (length(data{k}.data) < infos.duration * data{k}.header.sr - 3 ||...
              length(data{k}.data) > infos.duration * data{k}.header.sr + 3)
            wflag(k) = 1;
          end
        end
      end
    end
  end
end
if any(vflag)
  errmsg = [gerrmsg, sprintf('Invalid data structure for channel %01.0f.', find(vflag,1))];
  warning('ID:invalid_data_structure', '%s', errmsg);
  return
end
if any(wflag)
  errmsg = [gerrmsg, sprintf(['The data in channel %01.0f is out of ',...
    'the range [0, infos.duration]'], find(wflag,1))];
  warning('ID:invalid_data_structure', '%s', errmsg);
  return
end
if any(nflag)
  errmsg = [gerrmsg, sprintf('Unknown channel type in channel %01.0f', find(nflag,1))];
  warning('ID:invalid_data_structure', '%s', errmsg);
  return
end
if any(zflag)
  % convert empty data to a generalised 1-by-0 matrix
  data{find(zflag,1)}.data = zeros(1,0);
  warning('ID:missing_data', 'Channel %01.0f is empty.', find(zflag,1));
  % if there is empty data, give a warning but do not suspend
end


%% 7 Autofill information in header
% some other optional fields which can be autofilled with default values
% should be added here.

%% 8 Analyse file structure
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

%% 9 Return channels, or save file
if isstruct(chan)
  infos = chan.infos;
  data = chan.data;
end
flag = zeros(numel(data), 1);
if ischar(chan) && ~strcmp(chan, 'none')
  if strcmpi(chan, 'pupil') && isfield(infos.source, 'best_eye')
    flag = get_chans_to_load_for_pupil(data, infos.source.best_eye);
  elseif strcmpi(chan, 'sps') && isfield(infos.source, 'best_eye')
    flag = get_chans_to_load_for_sps(data, infos.source.best_eye);
  else
    for k = 1:numel(data)
      if (any(strcmpi(chan, {'event', 'events'})) && ...
          strcmpi(data{k}.header.units, 'events')) || ...
          (strcmpi(chan, 'wave') && ~strcmpi(data{k}.header.units, 'events')) || ...
          (any(strcmpi(chan, {'trigger', 'marker'})) && ...
          any(strcmpi(data{k}.header.chantype, {'trigger', 'marker'})))
        flag(k) = 1;
      elseif strcmp(data{k}.header.chantype, chan)
        flag(k) = 1;
      end
    end
  end
  if all(flag == 0)
    warning('ID:non_existing_channeltype',...
      'There are no channels of type ''%s'' in the datafile', chan);
    return
  end
  data = data(flag == 1);
  filestruct.posofchannels = find(flag == 1);
elseif isnumeric(chan)
  if chan == 0, chan = 1:numel(data); end
  if any(chan > numel(data))
    warning('ID:invalid_input',...
      'Input channel number(s) are greater than the number of channels in the data');
    return
  end
  data = data(chan);
  filestruct.posofchannels = chan;
elseif isstruct(chan) && ~isempty(fn) && (~exist(fn, 'file') || ...
    chan.options.overwrite == 1)
  save(fn, 'infos', 'data');
  filestruct.posofchannels = 1:numel(data);
else
  filestruct.posofchannels = [];
end

sts = 1;
end

function flag = get_chans_to_load_for_pupil(data, best_eye)
% Set flag variable according to the precedence order:
%
%   1. Combined channels (by definition also preprocessed)
%   2. Preprocessed channels corresponding to best eye
%   3. Preprocessed channels
%   4. Best eye pupil channels
%
% The earliest possible option is taken and then the function returns.
global settings;
if isempty(settings)
  pspm_init;
end
chantype_list = cellfun(@(x) x.header.chantype, data, 'uni', false);
pupil_channels = cell2mat(cellfun(...
  @(chantype) strncmp(chantype, 'pupil',numel('pupil')),...
  chantype_list,...
  'uni',...
  false...
  ));
preprocessed_channels = cell2mat(cellfun(...
  @(chantype) any(strcmp(split(chantype,'_'),'pp')),...
  chantype_list,...
  'uni',...
  false...
  ));
combined_channels = cell2mat(cellfun(...
  @(chantype) any(strcmp(split(chantype,'_'),settings.lateral.char.c)) && ...
  any(strcmp(split(chantype,'_'),'pp')),...
  chantype_list,...
  'uni',...
  false...
  ));
besteye_channels = cell2mat(cellfun(...
  @(chantype) any(strcmpi(split(chantype,'_'),best_eye)),...
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


function flag = get_chans_to_load_for_sps(data, best_eye)
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
  @(chantype) contains(chantype, ['_',settings.lateral.char.c,'_']) && ...
  strcmp(chantype(end-2:end), '_pp'),...
  chantype_list,...
  'uni',...
  false...
  ));
besteye_channels = cell2mat(cellfun(...
  @(chantype) strcmp(chantype(end-1:end), ['_' best_eye]) || ...
  contains(chantype, ['_' best_eye '_']),...
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