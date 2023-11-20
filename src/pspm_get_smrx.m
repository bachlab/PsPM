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
%% 2 Get external file
% 2.1 Open file
fhand = CEDS64Open(datafile, 1);
if (fhand < 0); error('Could not open file.'); end
% 2.2 Read file info
hdr.timebase      = CEDS64TimeBase(fhand);
hdr.maxchan       = CEDS64MaxChan(fhand);
hdr.maxtime       = CEDS64MaxTime(fhand);
[~, hdr.timedate] = CEDS64TimeDate(fhand);
hdr.timedate = double(hdr.timedate);
% 2.3 Get list of channels
iChan = 0;
iMarkerChan = [];
MarkerChanName = {};
for i = 1:hdr.maxchan
  chanType = CEDS64ChanType(fhand, i); % Read channel type
  switch chanType % Check type of the channel
    case {1,9} % ADC channels: read as signals
      iChan = iChan + 1;
      hdr.chaninfo(iChan).number = i;
      hdr.chaninfo(iChan).kind = chanType;
      [~, hdr.chaninfo(iChan).title] = CEDS64ChanTitle(fhand, i);
      % [isOk, hdr.chaninfo(iChan).comment] = CEDS64ChanComment(fhand, i);
      hdr.chaninfo(iChan).div = CEDS64ChanDiv(fhand, i);
      hdr.chaninfo(iChan).idealRate = CEDS64IdealRate(fhand, i);
      hdr.chaninfo(iChan).realRate = 1 ./ (hdr.timebase .* hdr.chaninfo(iChan).div);
      % Convert units to gain
      [~, hdr.chaninfo(iChan).units] = CEDS64ChanUnits(fhand, i);
      chUnits = lower(strtrim(hdr.chaninfo(iChan).units));
      if ~isempty(chUnits)
        if contains(chUnits, 'μ') || contains(chUnits, 'micro')
          hdr.chaninfo(iChan).gain = 1e-6;
        elseif contains(chUnits, 'milli') || contains(chUnits, 'mv')
          hdr.chaninfo(iChan).gain = 1e-3;
        else
          hdr.chaninfo(iChan).gain = 1;
        end
      end
    case {2,3,4,5,6,7,8} % Markers and events
      iMarkerChan(end+1) = i;
      [~, chTitle] = CEDS64ChanTitle(fhand, i);
      chTitle = str_remove_spec_chars(chTitle);
      if ~isempty(chTitle)
        MarkerChanName{end+1} = chTitle;
      else
        MarkerChanName{end+1} = num2str(i);
      end
  end
end
hdr.nchan = length(hdr.chaninfo);
% 2.4 Get maximum sampling rate
[sfreq, chMax] = max([hdr.chaninfo.idealRate]);


return