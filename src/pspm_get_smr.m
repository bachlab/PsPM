function [sts, import, sourceinfo] = pspm_get_smr(datafile, import)
% ● Description
%   pspm_get_smr is the main function for importting spike-smr files
% ● Format
%   [sts, import, sourceinfo] = pspm_get_smr(datafile, import);
% ● Arguments
%     import: [struct]
%   .denoise: for marker channels in CED spike format (recorded as 'level'),
%             filters out markers duration longer than the value given here (in
%             ms).
% ● History
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Update in 2023 by Teddy

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];
addpath(pspm_path('Import','SON'));
%% 2 Get external file
% using SON library
warning off;
% 2.1 Open file
fid = fopen(datafile);
% 2.2 Get channel list
chanlist = SONChanList(fid);
% preallocate memory for speed
chandata = cell(numel(chanlist), 1);
errorflag = [];
% read channels
for channel = 1:numel(chanlist)
  try
    [chandata{channel}, chanhead{channel}] = SONGetChannel(fid, chanlist(channel).number, 'milliseconds');
  catch
    errorflag(channel)=1;
    chandata{channel}=[];
    chanhead{channel}.title='';
  end
end
fclose(fid);
% delete empty channels
if ~isempty(errorflag)
  ind=find(errorflag);
  for channel=ind(end:-1:1)
    chandata(channel)=[];
    chanhead(channel)=[];
  end
end
warning on;
%% 3 extract individual channels
% loop through import jobs
for k = 1:numel(import)
  % define channel number ---
  if import{k}.channel > 0
    channel = import{k}.channel;
  else
    channel = pspm_find_channel(arrayfun(@(i) chanhead{i}.title, 1:numel(chanhead), 'UniformOutput', 0), ...
      import{k}.type); % bring channel names into a cell array
    if channel < 1, return; end
  end
  if channel > numel(chandata)
    warning('ID:channel_not_contained_in_file', ...
      'Channel %02.0f not contained in file %s.\n', channel, datafile); 
    return; 
  end
  sourceinfo.channel{k, 1} = sprintf('Channel %02.0f: %s', channel, chanhead{channel}.title);
  % convert to waveform or get sample rate for wave channel types
  if strcmpi(settings.channeltypes(import{k}.typeno).data, 'wave')
    if chanhead{channel}.kind == 1 % waveform
      import{k}.data = chandata{channel};
      import{k}.sr   = 1./chanhead{channel}.sampleinterval;
    elseif chanhead{channel}.kind == 3 % timestamps
      % get minimum frequency for reporting resolution
      import{k}.minfreq = min(1./diff(chandata{channel}))*1000;
      % convert pulse to waveform
      import{k}.data = pspm_pulse_convert(chandata{channel}, settings.import.rsr, settings.import.sr);
      import{k}.sr   = settings.import.sr;
      import{k}.minfreq = min(import{k}.data);
    elseif chanhead{channel}.kind == 4 % up and down timestamps
      pulse = chandata{channel};
      % start with low to high
      if chanhead{channel}.initLow==0
        pulse(1)=[];
      end
      pulse = pulse(1:2:end);
      import{k}.data = pspm_pulse_convert(pulse, settings.import.rsr, settings.import.sr);
      import{k}.sr = settings.import.sr;
      import{k}.minfreq = min(import{k}.data);
    else
      warning('Unknown channel format in CED spike file for import job %02.0f', k);  return;
    end
    % extract, and possibly denoise event channels
  elseif strcmpi(settings.channeltypes(import{k}.typeno).data, 'events')
    if chanhead{channel}.kind == 1 % waveform
      import{k}.marker = 'continuous';
      import{k}.data = chandata{channel};
      import{k}.sr   = 1./chanhead{channel}.sampleinterval;
    elseif chanhead{channel}.kind == 4 && strcmpi(import{k}.type, 'marker') 
      % for TTL marker channels with up AND down timestamps
      kbchan = pspm_find_channel(arrayfun(@(i) chanhead{i}.title, 1:numel(chanhead), 'UniformOutput', 0), ...
        {'keyboard'}); % keyboard channel doesn't exist by default but is needed for denoising
      if kbchan > 0
        kbdata = chandata{kbchan}; 
      else 
        kbdata = []; 
      end
      if isfield(import{k}, 'denoise') && ~isempty(import{k}.denoise) && import{k}.denoise > 0
        import{k}.data = pspm_denoise_spike(chandata{channel}, chanhead{channel}, kbdata, import{k}.denoise);
      else
        pulse = chandata{channel};
        % start with low to high
        if chanhead{channel}.initLow==0
          pulse(1)=[];
        end
        import{k}.data = pulse(1:2:end);
      end
      import{k}.sr = 0.001; % milliseconds import for marker channels, see above
      import{k}.marker = 'timestamp';
    else        % for TTL channels with up OR down timestamps
      import{k}.data = chandata{channel};
      import{k}.sr = 0.001; % milliseconds import for marker channels, see above
      import{k}.marker = 'timestamp';
    end
  end
end
%% 4 Clear path and return
rmpath(pspm_path('Import','SON'));
sts = 1;
return