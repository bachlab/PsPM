function [sts, import, sourceinfo] = pspm_get_smrx(datafile, import)
% ● Description
%   pspm_get_smrx is the main function for importting spike-smr files
% ● Format
%   [sts, import, sourceinfo] = pspm_get_smr(datafile, import);
% ● Arguments
%     import: [struct]
% ● History
%   Introduced in PsPM 6.1
%   Written in 2023 by Teddy

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];
addpath(pspm_path('Import','CEDS64ML'));
if ~strcmpi(computer('arch'), 'win64')
  error('The MATCED library for reading .smrx files is available only on Windows 64bit.');
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
iMarkerChan = [];
MarkerChanName = {};
for i = 1:fileinfo.maxchan
  chanType = CEDS64ChanType(fhand, i); % Read channel type
  switch chanType % Check type of the channel
    case {1,9} % ADC channels: read as signals
      iChan = iChan + 1;
      fileinfo.chaninfo(iChan).number        = i;
      fileinfo.chaninfo(iChan).kind          = chanType;
      [~, fileinfo.chaninfo(iChan).title]    = CEDS64ChanTitle(fhand, i);
      % [~, fileinfo.chaninfo(iChan).comment]= CEDS64ChanComment(fhand, i);
      fileinfo.chaninfo(iChan).div           = CEDS64ChanDiv(fhand, i);
      fileinfo.chaninfo(iChan).idealRate     = CEDS64IdealRate(fhand, i);
      fileinfo.chaninfo(iChan).realRate      = 1 ./ (fileinfo.timebase .* fileinfo.chaninfo(iChan).div);
      [~, fileinfo.chaninfo(iChan).units]    = CEDS64ChanUnits(fhand, i); % Convert units to gain
      chUnits = lower(strtrim(fileinfo.chaninfo(iChan).units));
      if ~isempty(chUnits)
        if contains(chUnits, 'μ') || contains(chUnits, 'micro')
          fileinfo.chaninfo(iChan).gain = 1e-6;
        elseif contains(chUnits, 'milli') || contains(chUnits, 'mv')
          fileinfo.chaninfo(iChan).gain = 1e-3;
        else
          fileinfo.chaninfo(iChan).gain = 1;
        end
      end
    case {2,3,4,5,6,7,8} % Markers and events
      iMarkerChan(end+1) = i;
      [~, chTitle] = CEDS64ChanTitle(fhand, i);
      % chTitle = str_remove_spec_chars(chTitle);
      if ~isempty(chTitle)
        MarkerChanName{end+1} = chTitle;
      else
        MarkerChanName{end+1} = num2str(i);
      end
  end
end
fileinfo.nchan = length(fileinfo.chaninfo);
% 2.4 Get maximum sampling rate
[sfreq, chMax] = max([fileinfo.chaninfo.idealRate]);
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
        [nRead, Fchan] = CEDS64ReadWaveF(fhand, ...
                                         channel, ...
                                         floor(fileinfo.maxtime/fileinfo.chaninfo(channel).div), ...
                                         1);
        import{iImport}.data      = Fchan;
        import{iImport}.div       = fileinfo.chaninfo(channel).div;
        import{iImport}.gain      = fileinfo.chaninfo(channel).gain;
        import{iImport}.length    = nRead;
        import{iImport}.idealRate = fileinfo.chaninfo(channel).idealRate;
        import{iImport}.number    = fileinfo.chaninfo(channel).number;
        import{iImport}.realRate  = fileinfo.chaninfo(channel).realRate;
        import{iImport}.sr        = fileinfo.chaninfo(channel).realRate;
        import{iImport}.title     = fileinfo.chaninfo(channel).title;
        import{iImport}.units     = fileinfo.chaninfo(channel).units;
      otherwise
        warning('ID:feature_unsupported', 'Only waveforms are currently supported. \n');
        return
    end
  elseif strcmpi(settings.channeltypes(import{iImport}.typeno).data, 'events')
    switch fileinfo.chaninfo(channel).kind
      case 1 % waveform
        % import{iImport}.marker  = 'continuous';
        % import{iImport}.?    = fileinfo.chaninfo(channel).div;
        % import{iImport}.?    = fileinfo.chaninfo(channel).idealRate;
        % import{iImport}.?    = fileinfo.chaninfo(channel).realRate;
        % import{iImport}.?    = fileinfo.chaninfo(channel).kind;
        warning('ID:feature_unsupported', 'Only waveforms are currently supported. \n');
      otherwise
        warning('ID:feature_unsupported', 'Only waveforms are currently supported. \n');
        return
    end
  end
end
%% 4 Clear path and return
rmpath(pspm_path('Import','CEDS64ML'));
sts = 1;
return