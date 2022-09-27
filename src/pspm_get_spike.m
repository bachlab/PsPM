function [sts, import, sourceinfo] = pspm_get_spike(datafile, import)
% ● Description
%   pspm_get_spike is the main function for import of spike files
% ● Format
%   [sts, import, sourceinfo] = pspm_get_spike(datafile, import);
% ● Arguments
%     import: [struct]
%   .denoise: for marker channels in CED spike format (recorded as 'level'), 
%             filters out markers duration longer than the value given here (in
%             ms).
% ● History
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
sourceinfo = [];
addpath(pspm_path('Import','SON'));

% get external file, using SON library
% -------------------------------------------------------------------------
warning off;

fid = fopen(datafile);
chanlist = SONChanList(fid);

% preallocate memory for speed
chandata = cell(numel(chanlist), 1);

errorflag = [];
% read channels
for chan = 1:numel(chanlist)
  try
    [chandata{chan}, chanhead{chan}]=SONGetChannel(fid, chanlist(chan).number, 'milliseconds');
  catch
    errorflag(chan)=1;
    chandata{chan}=[];
    chanhead{chan}.title='';
  end;
end;
fclose(fid);

% delete empty channels
if ~isempty(errorflag)
  ind=find(errorflag);
  for chan=ind(end:-1:1)
    chandata(chan)=[];
    chanhead(chan)=[];
  end;
end;

warning on;

% extract individual channels
% -------------------------------------------------------------------------
% loop through import jobs
for k = 1:numel(import)
  % define channel number ---
  if import{k}.channel > 0
    chan = import{k}.channel;
  else
    chan = pspm_find_channel(arrayfun(@(i) chanhead{i}.title, 1:numel(chanhead), 'UniformOutput', 0), ...
      import{k}.type); % bring channel names into a cell array
    if chan < 1, return; end;
  end;

  if chan > numel(chandata), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;

  sourceinfo.chan{k, 1} = sprintf('Channel %02.0f: %s', chan, chanhead{chan}.title);

  % convert to waveform or get sample rate for wave channel types
  if strcmpi(settings.chantypes(import{k}.typeno).data, 'wave')
    if chanhead{chan}.kind == 1 % waveform
      import{k}.data = chandata{chan};
      import{k}.sr   = 1./chanhead{chan}.sampleinterval;
    elseif chanhead{chan}.kind == 3 % timestamps
      % get minimum frequency for reporting resolution
      import{k}.minfreq = min(1./diff(chandata{chan}))*1000;
      % convert pulse to waveform
      import{k}.data = pspm_pulse_convert(chandata{chan}, settings.import.rsr, settings.import.sr);
      import{k}.sr   = settings.import.sr;
      import{k}.minfreq = min(import{k}.data);
    elseif chanhead{chan}.kind == 4 % up and down timestamps
      pulse = chandata{chan};
      % start with low to high
      if chanhead{chan}.initLow==0
        pulse(1)=[];
      end;
      pulse = pulse(1:2:end);
      import{k}.data = pspm_pulse_convert(pulse, settings.import.rsr, settings.import.sr);
      import{k}.sr = settings.import.sr;
      import{k}.minfreq = min(workdata);
    else
      warning('Unknown channel format in CED spike file for import job %02.0f', k);  return;
    end;
    % extract, and possibly denoise event channels
  elseif strcmpi(settings.chantypes(import{k}.typeno).data, 'events')
    if chanhead{chan}.kind == 1 % waveform
      import{k}.marker = 'continuous';
      import{k}.data = chandata{chan};
      import{k}.sr   = 1./chanhead{chan}.sampleinterval;
    elseif chanhead{chan}.kind == 4 && strcmpi(import{k}.type, 'marker') % for TTL marker channels with up AND down timestamps
      kbchan = pspm_find_channel(arrayfun(@(i) chanhead{i}.title, 1:numel(chanhead), 'UniformOutput', 0), ...
        {'keyboard'}); % keyboard channel doesn't exist by default but is needed for denoising
      if kbchan > 0, kbdata = chandata{kbchan}; else kbdata = []; end;
      if isfield(import{k}, 'denoise') && ~isempty(import{k}.denoise) && import{k}.denoise > 0
        import{k}.data = pspm_denoise_spike(chandata{chan}, chanhead{chan}, kbdata, import{k}.denoise);
      else
        pulse = chandata{chan};
        % start with low to high
        if chanhead{chan}.initLow==0
          pulse(1)=[];
        end;
        import{k}.data = pulse(1:2:end);
      end;
      import{k}.sr = 0.001; % milliseconds import for marker channels, see above
      import{k}.marker = 'timestamp';
    else        % for TTL channels with up OR down timestamps
      import{k}.data = chandata{chan};
      import{k}.sr = 0.001; % milliseconds import for marker channels, see above
      import{k}.marker = 'timestamp';
    end;
  end;
end;

% clear path and return
% -------------------------------------------------------------------------
rmpath(pspm_path('Import','SON'));
sts = 1;
return;
