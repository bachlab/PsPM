function [sts, import, sourceinfo] = pspm_get_smrx(datafile, import)
% ● Description
%   pspm_get_smrx is the main function for reading spike-smrx files
% ● Format
%   [sts, import, sourceinfo] = pspm_get_smr(datafile, import);
% ● Arguments
%     datafile: path to the smrx file
%   ┌───import: [struct]  The struct that stores required parameters.
%   ├─.channel: [integer] The number of the channel to load. Use '0' to load all channels.
%   ├───.flank: [string]  
%   ├.transfer: [string]  The transfer function, use a file, an input or 'none'.
%   ├────.type: [string]  The type of input channel, such as 'scr'.
%   └──.typeno: [integer] The number of channel type, please see pspm_init.
% ● Output
%   sts: the status recording whether the function runs successfully.
%   import: the struct that stores read information.
%   sourceinfo: the struct that stores channel titles.
% ● History
%   Introduced in PsPM 6.2
%   Written in 2024 by Teddy

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];
addpath(pspm_path('Import','CEDS64ML'));
if ~strcmpi(computer('arch'), 'win64')
  error('Reading .smrx files is available only on Windows 64bit.');
end
% Add path to CED code
cedpath = fileparts(which('CEDS64Open'));
setenv('CEDS64ML', fileparts(which('CEDS64Open')));
CEDS64LoadLib(cedpath);
%% 2 Get external file
warning off;
% 2.1 Open file
fhand = CEDS64Open(datafile, 1);
if (fhand < 0); error('Could not open file.'); end
% 2.2 Read file info
fileinfo.timebase      = CEDS64TimeBase(fhand);
fileinfo.maxchan       = CEDS64MaxChan(fhand);
fileinfo.maxtime       = CEDS64MaxTime(fhand);
[~, fileinfo.timedate] = CEDS64TimeDate(fhand);
fileinfo.timedate = double(fileinfo.timedate);
% 2.3 Get list of channels
iChan = 0;
for i = 1:fileinfo.maxchan
  chanType = CEDS64ChanType(fhand, i); % Read channel type
  switch chanType % Check type of the channel
    case {1,9} % ADC channels: read as signals
      iChan                             = iChan + 1;
      fileinfo.chaninfo(iChan).kind     = chanType;
      X                                 = GetCEDChanInfo(fhand, i);
      for fn = fieldnames(X)'; fileinfo.chaninfo(iChan).(fn{1}) = X.(fn{1}); end % transfer to fileinfo
      fileinfo.chaninfo(iChan).realRate = 1 ./ (fileinfo.timebase .* fileinfo.chaninfo(iChan).div);
    case {2,3,4,5,6,7,8} % Markers and events
      iChan = iChan + 1;
      fileinfo.chaninfo(iChan).kind     = chanType;
      X                                 = GetCEDChanInfo(fhand, i);
      for fn = fieldnames(X)'; fileinfo.chaninfo(iChan).(fn{1}) = X.(fn{1}); end % transfer to fileinfo
    otherwise
      iChan                             = iChan + 1;
      fileinfo.chaninfo(iChan).number   = i;
      fileinfo.chaninfo(iChan).kind     = 0;
      fileinfo.chaninfo(iChan).title    = '0';
  end
end
fileinfo.nchan = length(fileinfo.chaninfo);
% 2.4 Get maximum sampling rate
[~, ~] = max([fileinfo.chaninfo.idealRate]);
warning on;
%% 3 Extract individual channels
% 3.1 Loop through import jobs
for iImport = 1:numel(import)
  % 3.1.1 define channel number
  if import{iImport}.channel > 0
    channel = import{iImport}.channel;
  else
    channel = pspm_find_channel(fileinfo.chaninfo.kind,...
      import{iImport}.type);
    if channel < 1
      warning('ID:channel_not_contained_in_file', ...
        'Channel %02.0f not contained in file %s.\n', channel, datafile);
      return;
    end
  end
  if channel > fileinfo.nchan
    warning('ID:channel_not_contained_in_file', ...
      'Channel %02.0f not contained in file %s.\n', channel, datafile);
    return;
  end
  sourceinfo.channel{iImport, 1} = sprintf('Channel %02.0f: %s', channel, fileinfo.chaninfo.title);
  % 3.1.2 convert to waveform or get sample rate for wave channel types
  if strcmpi(settings.channeltypes(import{iImport}.typeno).data, 'wave')
    switch fileinfo.chaninfo(channel).kind
      case 1 % waveform
        % Use CED64ReadWaveF
        [nRead_waveform, Fchan_waveform] = CEDS64ReadWaveF(fhand, ...
          channel, ...
          floor(fileinfo.maxtime/fileinfo.chaninfo(channel).div), ...
          1);
        import{iImport}.data      = Fchan_waveform;
        import{iImport}.length    = nRead_waveform;
        import{iImport}.sr        = fileinfo.chaninfo(channel).realRate;
        import{iImport} = InheritFields(import{iImport}, fileinfo.chaninfo(channel));
      case 3 % time stamps
        % waiting for test data
        disp('Feature of reading time stamps has not been available.');
      case 4 % up and down time stamps
        % waiting for test data
        disp('Feature of reading time stamps has not been available.');
      otherwise
        warning('ID:feature_unsupported', ...
          'The imported waveform channel has not been currently supported. \n');
        return
    end
  elseif strcmpi(settings.channeltypes(import{iImport}.typeno).data, 'events')
    switch fileinfo.chaninfo(channel).kind
      case 1 % Events
        [nRead_events, Fchan_events] = CEDS64ReadEvents(fhand, ...
          channel, ...
          floor(fileinfo.maxtime/fileinfo.chaninfo(channel).div), ...
          1);
        % import{iImport}.marker  = 'continuous';
        import{iImport}.data      = Fchan_events;
        import{iImport}.length    = nRead_events;
        import{iImport} = InheritFields(import{iImport}, fileinfo.chaninfo(channel));
      case 3 % time stamps
        % waiting for test data
        disp('Feature of reading time stamps has not been available.');
      case 4 % For events and type 4 channel, to read as marker channels
        [nRead_markers, Fchan_markers] = CEDS64ReadMarkers(fhand, ...
          channel, ...
          floor(fileinfo.maxtime * fileinfo.timebase * fileinfo.chaninfo(iChan).idealRate), ... % this is the length of data points
          1);
        % import{iImport}.marker  = 'continuous';
        import{iImport}.data      = Fchan_markers;
        import{iImport}.length    = nRead_markers;
        import{iImport} = InheritFields(import{iImport}, fileinfo.chaninfo(channel));
      otherwise
        warning('ID:feature_unsupported', 'The imported event channel has not been currently supported. \n');
        return
    end
  end
end
%% 4 Clear path and return
rmpath(pspm_path('Import','CEDS64ML'));
sts = 1;
return
function Y = InheritFields(Y, X)
% ● Description
%   InheritFields reads fields from X and transfer to Y.
%   The fields read include number, comment div, ideal rate, title,
%   comment, units, and gain.
% ● History
%   Written in 2024 by Teddy
if isfield(X, 'div')
  Y.div = X.div;
end
if isfield(X, 'gain')
  Y.gain = X.gain;
end
if isfield(X, 'idealRate')
  Y.idealRate = X.idealRate;
end
if isfield(X, 'number')
  Y.number = X.number;
end
if isfield(X, 'realRate')
  Y.realRate = X.realRate;
end
if isfield(X, 'title')
  Y.title = X.title;
end
if isfield(X, 'units')
  Y.units = X.units;
end
function Y = GetCEDChanInfo(fhand, i)
% ● Description
%   GetCEDChanInfo reads information from the raw file into output.
%   If the information is not available, read as an empty field.
%   This function can be used by waveform and event channels.
%   The fields read include number, comment div, ideal rate, title,
%   comment, units, and gain.
% ● History
%   Written in 2024 by Teddy
Y.number = i;
Y.div           = CEDS64ChanDiv(fhand, i);
Y.idealRate     = CEDS64IdealRate(fhand, i);
[~, chTitle]    = CEDS64ChanTitle(fhand, i);
% chTitle = str_remove_spec_chars(chTitle);
if ~isempty(chTitle)
  Y.title = chTitle;
else
  Y.title = num2str(i);
end
[~, Y.comment]  = CEDS64ChanComment(fhand, i);
[~, Y.units]    = CEDS64ChanUnits(fhand, i); % Convert units to gain
chUnits = lower(strtrim(Y.units));
if ~isempty(chUnits)
  if contains(chUnits, 'μ') || contains(chUnits, 'micro')
    Y.gain = 1e-6;
  elseif contains(chUnits, 'milli') || contains(chUnits, 'mv')
    Y.gain = 1e-3;
  else
    Y.gain = 1;
  end
end