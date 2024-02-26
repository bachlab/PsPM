function [sts, infos, data, filestruct] = pspm_load_data(fn, channel)
% ● Description
%   pspm_load_data checks and returns the structure of PsPM 3-5.x and
%   SCRalyze 2.x data files - SCRalyze 1.x is not supported
% ● Format
%   [sts, infos, data, filestruct] = pspm_load_data(fn, channel)
% ● Arguments
%   ┌─────fn:   [char] filename / [struct] with fields
%   ├─.infos:
%   └──.data:
%    channel:   [numeric vector] / [char] / [struct]
%               ▶ vector
%                 0 or empty: returns all channels
%                 vector of channels: returns only these channels
%               ▶ char
%                 'wave'    returns all waveform channels
%                 'events'  returns all event channels
%                 'pupil', 'sps', 'gaze_x', 'gaze_y', 'blink', 'saccade',
%                 'pupil_missing' (eyetracker channels)
%                           returns all channels of the respective type
%                           (i.e., 'pupil' returns all of 'pupil', 'pupil_l',
%                            'pupil_r', 'pupil_c')
%                 'channel type' (e.g. 'scr')
%                           returns the respective channels (see settings for
%                           permissible channel types)
%                 'none'    just checks the file
%               ▶ struct  check and save file
%                 ├───.infos (mandatory)
%                 ├────.data (mandatory)
%                 └─.options (mandatory)
% ● Outputs
%                sts: [logical] 1 as default, -1 if check is unsuccessful
%              infos: [struct] variable from data file
%               data: cell array of channels as specified
%   ┌─────filestruct: [struct]
%   ├─────.numofchan: number of channels
%   ├─.numofwavechan: number of wave channels
%   ├.numofeventchan: number of event channels
%   ├───.posofmarker: position of the first marker channel
%   │                 0 if no marker channel exists
%   └─.posofchannels: number of the channels that were returned
% ● Developer's Notes
%   General structure of PsPM data files
%   Each file contains two variables:
%       infos - struct variable with general infos
%       data  - cell array with channel specific infos and data
%   Mandatory fields:
%       infos.duration (in seconds)
%       data{n}.header
%       data{n}.header.chantype (as defined in settings)
%       data{n}.header.sr (sample rate in 1/second, or timestamp units in seconds)
%       data{n}.header.units (data units, or 'events')
%       data{n}.data (actual data)
%   Additionally, a typical file contains the optional infos:
%       infos.sourcefile, infos.importfile, infos.importdate, import.sourcetype
%       and, if available, also infos.recdate, infos.rectime
%       some data manipulation functions (in particular, pspm_trim) update infos
%       to record some file history.
%   data.header.chantype = 'trigger' is allowed for backward compatibility;
%       this feature will be removed in the future
% ● History
%   Written in 2008-2021 by Dominik R. Bach (Wellcome Centre for Human Neuroimaging, UCL)
%     2022 Teddy Chao (UCL)

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
    channel = 0;
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
      if ~isstruct(channel) % if channel is not a struct, fn must exist
        warning('ID:nonexistent_file', 'The file fn does not exist.');
        return
      end
    else
      if ~isstruct(channel)
        % check fn as a mat file only if channel is not a struct
        % because if channel is a struct fn will be overwritten
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
%% 4 Check channel if struct, otherwise checking is done in pspm_select_channels
if isstruct(channel)
    if ~isfield(channel, 'data') || ~isfield(channel, 'infos')
      % data and infos are mandatory fields and must be provided
      % gerrmsg = sprintf('\nData structure is invalid:');
      warning('ID:invalid_input', 'Input struct is not a valid PsPM struct');
      return
    end
    if ~isfield(channel, 'options')
      % options is an optional field
      channel.options = [];
    end
    % add default values
    if ~isfield(channel.options, 'overwrite')
      channel.options.overwrite = pspm_overwrite(fn);
    end
end
%% 5 Check infos
if isstruct(channel)
  infos = channel.infos;
else
  if isstruct(fn) % data is from a struct fn
    infos = fn.infos;
  elseif exist(fn, 'file') % data is from a file fn
    loaded_infos = load(fn, 'infos');
    if isfield(loaded_infos, 'infos') && numel(fieldnames(loaded_infos))==1
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
%% 6 Load data
if isstruct(channel)
  data = channel.data;
else
  if isstruct(fn) % data is from a struct fn
    data = fn.data;
  elseif exist(fn, 'file') % data is from a file fn
    loaded_data = load(fn, 'data');
    if isfield(loaded_data, 'data') && numel(fieldnames(loaded_data))==1
      data = loaded_data.data;
    end
    clear loaded_data
  end
end
%% 7 Check data
% 7.1 initialise error flags --
vflag = zeros(numel(data), 1); % records data structure, valid if 0
wflag = zeros(numel(data), 1); % records whether data is out of range, valid if 0
nflag = zeros(numel(data), 1);
zflag = zeros(numel(data), 1); % records whether data is empty
% loop through channels
for k = 1:numel(data)
  % 7.2 Check header --
  if ~isfield(data{k}, 'header')
    vflag(k) = 1;
  else
    % 7.2.1 Convert header channeltype into chantype if there are --
    if isfield(data{k}.header, 'channeltype')
      data{k}.header.chantype = data{k}.header.channeltype;
      data{k}.header = rmfield(data{k}.header, 'channeltype');
    end
    if ~isfield(data{k}.header, 'chantype') || ...
        ~isfield(data{k}.header, 'sr') || ...
        ~isfield(data{k}.header, 'units')
      vflag(k) = 1;
    else
      if isfield(data{k}.header, 'chantype')
        if ~ismember(lower(data{k}.header.chantype), {settings.channeltypes.type})
          nflag(k) = 1;
        end
      else
        if ~ismember(lower(data{k}.header.chantype), {settings.channeltypes.type})
          nflag(k) = 1;
        end
      end
    end
  end
  % 7.3 Check data --
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
  errmsg = [gerrmsg, sprintf('Unknown channel type %s in channel %01.0f', data{find(nflag,1)}.header.chantype, find(nflag,1))];
  warning('ID:invalid_data_structure', '%s', errmsg);
  return
end
if any(zflag)
  % convert empty data to a generalised 1-by-0 matrix
  data{find(zflag,1)}.data = zeros(1,0);
  warning('ID:missing_data', 'Channel %01.0f is empty.', find(zflag,1));
  % if there is empty data, give a warning but do not suspend
end
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
if ischar(channel) && strcmp(channel, 'none')
    sts = 1; return;
elseif isstruct(channel) 
    infos = channel.infos;
    data = channel.data;
    filestruct.posofchannels = 1:numel(data);
    if ~isempty(fn) && (~exist(fn, 'file') || ...
        channel.options.overwrite == 1)
        save(fn, 'infos', 'data');
    else
        warning('ID:existing_file', 'File exists and overwriting not allowed.\n')
    end
elseif ~(isnumeric(channel) && numel(channel) == 1 && channel == 0)
    [sts, data, filestruct.posofchannels] = pspm_select_channels(data, channel);
    if sts < 1, return; end
else
    filestruct.posofchannels = 1:numel(data);
end
sts = 1;
return

